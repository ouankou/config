# GitHub MFA Protected JupyterLab on mona.ouankou.com

This guide sets up a fresh VPS so that only the GitHub user `ouankou` can access JupyterLab at:

```text
https://mona.ouankou.com
```

The final shape is:

```text
Browser
  -> https://mona.ouankou.com
  -> nginx on ports 80/443
  -> oauth2-proxy on 127.0.0.1:4180
  -> GitHub login/MFA for user ouankou
  -> JupyterLab on 127.0.0.1:8888
```

JupyterLab will listen only on `127.0.0.1`, so it is not directly reachable from the public internet. Public users only reach nginx, and nginx asks oauth2-proxy whether the request is authenticated before forwarding it to JupyterLab.

## Assumptions

This guide assumes:

- The VPS runs Debian 13 stable, also called `trixie`.
- You can SSH into the VPS as a user with `sudo`.
- `nginx` is already installed.
- DNS is managed in GoDaddy and must stay there.
- The public hostname is `mona.ouankou.com`.
- The only allowed GitHub username is `ouankou`.

If your VPS provider has a cloud firewall, open inbound TCP ports `22`, `80`, and `443` there too.

## Verified Debian 13 Details

I verified the nginx auth feature on Debian 13.4 without root access. Debian's `nginx` package version `1.26.3-3+deb13u2` is built with:

```text
--with-http_auth_request_module
```

This is the feature nginx needs for the `auth_request /oauth2/auth;` line later in the guide.

Important: on Debian, the nginx binary is usually `/usr/sbin/nginx`. For a non-root shell, `/usr/sbin` may not be in `PATH`, so `nginx -V` may look like nginx is missing. Use the full path:

```bash
/usr/sbin/nginx -V 2>&1 | tr ' ' '\n' | grep -- 'with-http_auth_request_module'
```

Expected output:

```text
--with-http_auth_request_module
```

If that prints nothing, do these non-root checks:

```bash
cat /etc/os-release
apt-cache policy nginx
dpkg -S /usr/sbin/nginx
/usr/sbin/nginx -V 2>&1 | sed -n '1,8p'
```

If `dpkg -S /usr/sbin/nginx` does not say the file belongs to Debian's `nginx` package, you may be using an nginx.org package, a custom build, or a container image. In that case, either install Debian's `nginx` package or rebuild nginx with `--with-http_auth_request_module`.

Do not install `libnginx-mod-http-auth-pam` for this guide. That is a different PAM authentication module. The feature used here is nginx's built-in `auth_request` module.

The command above only checks compile flags; it does not test your config file. Later, after certificates and config files exist, use `sudo nginx -t` because nginx must read root-owned files such as TLS private keys.

## 0. Rootless Preflight Checks

Run these before changing the server. None of these commands need `sudo`.

Confirm the OS:

```bash
cat /etc/os-release
```

Expected important lines:

```text
PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
VERSION_ID="13"
VERSION_CODENAME=trixie
```

Confirm CPU architecture. The oauth2-proxy install commands later support `amd64` and `arm64` directly.

```bash
dpkg --print-architecture
```

Confirm nginx package origin and version:

```bash
apt-cache policy nginx
dpkg -l 'nginx*' 'libnginx*' 2>/dev/null | sed -n '1,120p'
```

For Debian 13 stable, `apt-cache policy nginx` should show a Debian `trixie` package such as:

```text
1.26.3-3+deb13u2
```

Confirm the nginx binary and auth module:

```bash
ls -l /usr/sbin/nginx
/usr/sbin/nginx -V 2>&1 | tr ' ' '\n' | grep -- 'with-http_auth_request_module'
```

Confirm DNS after you add the GoDaddy record:

```bash
getent ahosts mona.ouankou.com
```

Confirm current listening ports:

```bash
ss -ltn
```

Before setup, it is normal to see SSH and nginx. After setup, you should see local-only listeners for oauth2-proxy and JupyterLab:

```text
127.0.0.1:4180
127.0.0.1:8888
```

Confirm Debian has the Certbot packages used later:

```bash
apt-cache policy certbot python3-certbot-nginx
```

Expected Debian 13 stable package version:

```text
4.0.0-2
```

Confirm oauth2-proxy is not available from Debian apt:

```bash
apt-cache policy oauth2-proxy
apt-cache search oauth2-proxy
```

On Debian 13 stable, this should not find a web gateway package named `oauth2-proxy`.

## What GitHub MFA Will Feel Like

There are two sessions:

- Your GitHub browser session on `github.com`.
- Your oauth2-proxy session cookie on `mona.ouankou.com`.

If both are already valid, you may go directly to JupyterLab with no visible MFA prompt. That is expected. GitHub MFA protects your GitHub login session; oauth2-proxy trusts GitHub's result.

If the oauth2-proxy cookie is expired or missing, you will be redirected to GitHub. If that browser is already logged into GitHub as `ouankou`, GitHub may immediately redirect back without asking for MFA again. If the browser is logged into a different GitHub account, access should be denied.

If you want a fresh OTP challenge every single visit, use Authelia instead of GitHub OAuth.

## 1. Point DNS at the VPS

In GoDaddy DNS, create or update:

```text
Type: A
Name: mona
Value: <your VPS public IPv4 address>
TTL: 600 seconds or default
```

If there is an old `CNAME`, `A`, or `AAAA` record for `mona`, remove or fix it. A stale `AAAA` record is a common problem because browsers may try IPv6 first.

On your laptop, check DNS:

```bash
dig +short mona.ouankou.com
```

You want it to print your VPS public IP. DNS may take a few minutes.

## 2. Create a GitHub OAuth App

In GitHub:

1. Go to `https://github.com/settings/developers`.
2. Open `OAuth Apps`.
3. Click `New OAuth App`.
4. Use these values:

```text
Application name: mona-jupyterlab
Homepage URL: https://mona.ouankou.com
Authorization callback URL: https://mona.ouankou.com/oauth2/callback
```

After creating it:

1. Copy the `Client ID`.
2. Generate a `Client Secret`.
3. Keep both ready. You will paste them into the VPS config later.

Also verify that your GitHub account `ouankou` has MFA enabled:

```text
GitHub -> Settings -> Password and authentication -> Two-factor authentication
```

## 3. Prepare the VPS

SSH into the VPS.

```bash
ssh <your-user>@<your-vps-ip>
```

Install basic packages:

```bash
sudo apt update
sudo apt install -y curl ca-certificates tar openssl python3-venv python3-pip ufw
```

Check that nginx has the auth request module. Debian 13's `nginx` package should have it. Use `/usr/sbin/nginx`, not just `nginx`, because `/usr/sbin` may not be in a normal user's `PATH`.

```bash
/usr/sbin/nginx -V 2>&1 | tr ' ' '\n' | grep -- 'with-http_auth_request_module'
```

If that prints `--with-http_auth_request_module`, you are good. If it does not, stop and read the `Verified Debian 13 Details` section above.

Set a basic firewall. If you use a custom SSH port, adjust the `OpenSSH` rule before enabling UFW.

```bash
sudo ufw allow OpenSSH
sudo ufw allow "Nginx Full"
sudo ufw enable
sudo ufw status
```

## 4. Create a Temporary nginx Site

This lets Let's Encrypt verify that you control `mona.ouankou.com`.

```bash
sudo tee /etc/nginx/sites-available/mona.ouankou.com >/dev/null <<'EOF'
server {
    listen 80;
    server_name mona.ouankou.com;

    root /var/www/html;
    index index.nginx-debian.html index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/mona.ouankou.com /etc/nginx/sites-enabled/mona.ouankou.com
sudo nginx -t
sudo systemctl reload nginx
```

Test from your laptop browser:

```text
http://mona.ouankou.com
```

At this point it is okay if you see the nginx default page. Authentication is not enabled yet.

## 5. Install HTTPS Certificate

Install Certbot from Debian packages. This avoids snap completely.

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
certbot --version
```

Request the certificate:

```bash
sudo certbot --nginx -d mona.ouankou.com
```

Choose the redirect-to-HTTPS option if Certbot asks.

Check renewal:

```bash
sudo certbot renew --dry-run
systemctl list-timers 'certbot*' --no-pager
```

Debian's `certbot` package installs `/usr/bin/certbot` and a `certbot.timer`. The timer handles automatic renewal.

## 6. Install oauth2-proxy

Debian 13 stable does not currently package oauth2-proxy as `oauth2-proxy`.

You can confirm without root:

```bash
apt-cache policy oauth2-proxy
apt-cache search oauth2-proxy
```

If these print no package, that is expected. Do not install `email-oauth2-proxy`; it is for IMAP/POP/SMTP email clients and is unrelated to this web login gateway.

The upstream oauth2-proxy installation docs list prebuilt binary, Go install, Docker, and Kubernetes as install methods. This guide uses the upstream prebuilt binary and verifies its SHA256 checksum.

As of 2026-05-04, the current oauth2-proxy release is `v7.15.2`. These commands install the official prebuilt Linux binary.

```bash
VERSION=v7.15.2
ARCH="$(dpkg --print-architecture)"

case "$ARCH" in
  amd64|arm64)
    ;;
  *)
    echo "Unsupported architecture for this quick guide: $ARCH"
    exit 1
    ;;
esac

cd /tmp
curl -LO "https://github.com/oauth2-proxy/oauth2-proxy/releases/download/${VERSION}/oauth2-proxy-${VERSION}.linux-${ARCH}.tar.gz"
curl -LO "https://github.com/oauth2-proxy/oauth2-proxy/releases/download/${VERSION}/oauth2-proxy-${VERSION}.linux-${ARCH}.tar.gz-sha256sum.txt"
sha256sum -c "oauth2-proxy-${VERSION}.linux-${ARCH}.tar.gz-sha256sum.txt"
tar -xzf "oauth2-proxy-${VERSION}.linux-${ARCH}.tar.gz"
sudo install -o root -g root -m 0755 "oauth2-proxy-${VERSION}.linux-${ARCH}/oauth2-proxy" /usr/local/bin/oauth2-proxy

/usr/local/bin/oauth2-proxy --version
```

Create a system user and config directory:

```bash
sudo useradd --system --home /var/lib/oauth2-proxy --shell /usr/sbin/nologin oauth2-proxy
sudo install -d -o oauth2-proxy -g oauth2-proxy -m 0750 /var/lib/oauth2-proxy
sudo install -d -o root -g oauth2-proxy -m 0750 /etc/oauth2-proxy
```

Create the oauth2-proxy config. Paste your GitHub OAuth app values when prompted.

```bash
read -r -p "GitHub Client ID: " GITHUB_CLIENT_ID
read -r -s -p "GitHub Client Secret: " GITHUB_CLIENT_SECRET
echo
COOKIE_SECRET="$(openssl rand -base64 32 | tr -- '+/' '-_')"

sudo tee /etc/oauth2-proxy/oauth2-proxy.cfg >/dev/null <<EOF
provider = "github"
client_id = "$GITHUB_CLIENT_ID"
client_secret = "$GITHUB_CLIENT_SECRET"
cookie_secret = "$COOKIE_SECRET"

http_address = "127.0.0.1:4180"
redirect_url = "https://mona.ouankou.com/oauth2/callback"

email_domains = [ "*" ]
github_users = [ "ouankou" ]

reverse_proxy = true
trusted_proxy_ips = [ "127.0.0.1/32", "::1/128" ]
set_xauthrequest = true
pass_user_headers = true
skip_provider_button = true
whitelist_domains = [ "mona.ouankou.com" ]

cookie_secure = true
cookie_httponly = true
cookie_samesite = "lax"
cookie_expire = "8h"

upstreams = [ "static://202" ]
EOF

sudo chown root:oauth2-proxy /etc/oauth2-proxy/oauth2-proxy.cfg
sudo chmod 0640 /etc/oauth2-proxy/oauth2-proxy.cfg
unset GITHUB_CLIENT_ID GITHUB_CLIENT_SECRET COOKIE_SECRET
```

Why the important options matter:

- `github_users = [ "ouankou" ]` means only GitHub user `ouankou` is allowed.
- `email_domains = [ "*" ]` is required because GitHub users may have many email domains. The username allowlist is the real gate.
- `http_address = "127.0.0.1:4180"` keeps oauth2-proxy private to the VPS.
- `trusted_proxy_ips = [ "127.0.0.1/32", "::1/128" ]` means only local nginx is trusted to send forwarded proxy headers.
- `whitelist_domains = [ "mona.ouankou.com" ]` keeps post-login redirects on your domain.
- `cookie_expire = "8h"` means the local `mona.ouankou.com` login lasts 8 hours. Shorten it if you want more frequent GitHub rechecks.
- `upstreams = [ "static://202" ]` means oauth2-proxy is only used as an auth service. nginx will proxy JupyterLab itself.

Validate the config:

```bash
sudo -u oauth2-proxy /usr/local/bin/oauth2-proxy --config=/etc/oauth2-proxy/oauth2-proxy.cfg --config-test
```

Create the systemd service:

```bash
sudo tee /etc/systemd/system/oauth2-proxy.service >/dev/null <<'EOF'
[Unit]
Description=oauth2-proxy for mona.ouankou.com
After=network-online.target
Wants=network-online.target

[Service]
User=oauth2-proxy
Group=oauth2-proxy
ExecStart=/usr/local/bin/oauth2-proxy --config=/etc/oauth2-proxy/oauth2-proxy.cfg
Restart=always
RestartSec=5

NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict
ReadWritePaths=/var/lib/oauth2-proxy

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now oauth2-proxy
sudo systemctl status oauth2-proxy --no-pager
```

Confirm it is listening only locally:

```bash
ss -ltnp | grep 4180
```

You should see `127.0.0.1:4180`.

## 7. Install JupyterLab

This guide runs JupyterLab as your normal Linux user, `ouankou`, and uses `/home/ouankou/Projects` as the workspace.

Security tradeoff: this is convenient because JupyterLab can access your normal project files directly. It also means that if someone gets into JupyterLab, they can access anything the `ouankou` Linux user can access. For a personal VPS behind GitHub auth, this is a reasonable setup. A separate `jupyter` user would provide stronger file isolation.

Confirm you are logged in as `ouankou`:

```bash
whoami
```

Expected output:

```text
ouankou
```

Create the workspace and install JupyterLab into a Python virtual environment:

```bash
mkdir -p ~/Projects ~/.jupyter ~/venvs
python3 -m venv ~/venvs/jupyterlab
source ~/venvs/jupyterlab/bin/activate
pip install --upgrade pip
pip install jupyterlab
```

Create the Jupyter server config:

```bash
cat > ~/.jupyter/jupyter_server_config.py <<'EOF'
c.ServerApp.ip = "127.0.0.1"
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
c.ServerApp.trust_xheaders = True

# Authentication is handled by nginx + oauth2-proxy + GitHub.
# Keep this safe by binding JupyterLab to 127.0.0.1 only.
c.ServerApp.token = ""
c.ServerApp.password = ""
EOF
```

Create a systemd service:

```bash
sudo tee /etc/systemd/system/jupyterlab.service >/dev/null <<'EOF'
[Unit]
Description=JupyterLab private backend
After=network-online.target
Wants=network-online.target

[Service]
User=ouankou
Group=ouankou
WorkingDirectory=/home/ouankou/Projects
Environment="PATH=/home/ouankou/venvs/jupyterlab/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/home/ouankou/venvs/jupyterlab/bin/jupyter lab --config=/home/ouankou/.jupyter/jupyter_server_config.py
Restart=always
RestartSec=5

NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now jupyterlab
sudo systemctl status jupyterlab --no-pager
```

Confirm JupyterLab is local-only:

```bash
ss -ltnp | grep 8888
curl -I http://127.0.0.1:8888
```

You should see `127.0.0.1:8888`, not `0.0.0.0:8888`.

Optional stricter mode: if you want a second login after GitHub, run `jupyter server password` as `ouankou` and remove the blank `token` and `password` lines from `~/.jupyter/jupyter_server_config.py`.

## 8. Replace nginx With the Protected Reverse Proxy

Now replace the temporary nginx site with the real protected configuration.

```bash
sudo tee /etc/nginx/sites-available/mona.ouankou.com >/dev/null <<'EOF'
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 80;
    server_name mona.ouankou.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name mona.ouankou.com;

    ssl_certificate /etc/letsencrypt/live/mona.ouankou.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mona.ouankou.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 1g;
    proxy_read_timeout 86400;
    proxy_send_timeout 86400;

    location /oauth2/ {
        proxy_pass http://127.0.0.1:4180;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Auth-Request-Redirect $request_uri;
    }

    location = /oauth2/auth {
        proxy_pass http://127.0.0.1:4180;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Uri $request_uri;
        proxy_set_header Content-Length "";
        proxy_pass_request_body off;
    }

    location / {
        auth_request /oauth2/auth;
        error_page 401 = @oauth2_signin;

        auth_request_set $user $upstream_http_x_auth_request_user;
        auth_request_set $email $upstream_http_x_auth_request_email;
        proxy_set_header X-User $user;
        proxy_set_header X-Email $email;

        proxy_pass http://127.0.0.1:8888;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_buffering off;
    }

    location @oauth2_signin {
        return 302 /oauth2/sign_in?rd=$scheme://$host$request_uri;
    }
}
EOF

sudo nginx -t
sudo systemctl reload nginx
```

## 9. End-to-End Test

Open a private/incognito browser window and go to:

```text
https://mona.ouankou.com
```

Expected result:

1. You are sent to GitHub.
2. You log in as `ouankou`.
3. GitHub may ask for MFA, depending on your GitHub session state.
4. GitHub asks you to authorize the `mona-jupyterlab` OAuth app the first time.
5. You land in JupyterLab.

If you are already logged into GitHub as `ouankou`, GitHub may quickly redirect back without showing MFA. That is normal.

To test denial, try another browser profile logged into a different GitHub account. It should not get access.

## 10. Useful Operations

Restart services:

```bash
sudo systemctl restart oauth2-proxy
sudo systemctl restart jupyterlab
sudo systemctl reload nginx
```

Read logs:

```bash
sudo journalctl -u oauth2-proxy -f
sudo journalctl -u jupyterlab -f
sudo tail -f /var/log/nginx/error.log
```

Check service status:

```bash
systemctl status oauth2-proxy --no-pager
systemctl status jupyterlab --no-pager
systemctl status nginx --no-pager
```

Renew certificate manually:

```bash
sudo certbot renew --dry-run
```

Change the local login duration:

```bash
sudo nano /etc/oauth2-proxy/oauth2-proxy.cfg
```

Edit:

```text
cookie_expire = "8h"
```

Then:

```bash
sudo systemctl restart oauth2-proxy
```

## Troubleshooting

### Browser shows nginx default page without GitHub login

nginx is probably still serving the temporary/default site.

```bash
ls -l /etc/nginx/sites-enabled
sudo nginx -T | grep -n "server_name mona.ouankou.com" -A40
```

Make sure only the protected `mona.ouankou.com` site is enabled.

### GitHub says callback URL mismatch

The GitHub OAuth app callback must be exactly:

```text
https://mona.ouankou.com/oauth2/callback
```

Also check:

```bash
grep redirect_url /etc/oauth2-proxy/oauth2-proxy.cfg
```

### oauth2-proxy says missing GitHub user

Check the allowlist:

```bash
grep github_users /etc/oauth2-proxy/oauth2-proxy.cfg
```

It should be:

```text
github_users = [ "ouankou" ]
```

Then restart:

```bash
sudo systemctl restart oauth2-proxy
```

### 502 Bad Gateway after login

nginx reached authentication, but JupyterLab is not reachable.

```bash
sudo systemctl status jupyterlab --no-pager
curl -I http://127.0.0.1:8888
sudo journalctl -u jupyterlab -n 100 --no-pager
```

### JupyterLab opens but kernels or terminals do not connect

This is usually a WebSocket proxy issue. Confirm the nginx `location /` block includes:

```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;
proxy_buffering off;
```

### Certificate request fails

Check DNS and port 80:

```bash
dig +short mona.ouankou.com
sudo ufw status
sudo ss -ltnp | grep ':80'
```

Also check your VPS provider firewall.

## Security Notes

- Do not run JupyterLab on `0.0.0.0`.
- Do not open port `8888` in UFW or the VPS provider firewall.
- JupyterLab runs as Linux user `ouankou`, so notebooks and terminals can read and write files that `ouankou` can access.
- Keep the GitHub client secret private.
- If the GitHub client secret leaks, rotate it in GitHub and update `/etc/oauth2-proxy/oauth2-proxy.cfg`.
- Keep your GitHub account `ouankou` protected with MFA and recovery codes.
- Consider `cookie_expire = "2h"` if this will be used from shared or untrusted devices.

## References

- oauth2-proxy installation: https://oauth2-proxy.github.io/oauth2-proxy/installation/
- oauth2-proxy GitHub provider: https://oauth2-proxy.github.io/oauth2-proxy/configuration/providers/github/
- oauth2-proxy nginx integration: https://oauth2-proxy.github.io/oauth2-proxy/configuration/integrations/nginx/
- oauth2-proxy config options: https://oauth2-proxy.github.io/oauth2-proxy/configuration/overview/
- Debian package search for oauth2-proxy: https://packages.debian.org/search?keywords=oauth2-proxy&searchon=names&suite=trixie&section=all
- GitHub OAuth app flow: https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps
- Debian certbot package: https://packages.debian.org/trixie/certbot
- Debian certbot file list: https://packages.debian.org/trixie/all/certbot/filelist
- Debian python3-certbot-nginx package: https://packages.debian.org/trixie/python3-certbot-nginx
- NGINX auth_request check: https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-subrequest-authentication/
- Debian 13 nginx package: https://packages.debian.org/trixie/nginx
- Debian 13 nginx build flags: https://sources.debian.org/src/nginx/1.26.3-3%2Bdeb13u2/debian/rules/
