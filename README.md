# Config

Some shell scripts and system configurations.

# Guide
Put the SSH key in `.ssh` folder.
Append `bashrc` to the end of `.bashrc`. 

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

## Git Configuration

Import a key:

```bash
gpg2 --import FILENAME
```

List all secret keys:

```bash
gpg2 --list-secret-keys --keyid-format LONG
```

Edit key setting:

```bash
gpg2 --edit-key KEYCODE
```

#### Global

```bash
git config --global user.name ""
git config --global user.email ""
git config --global user.signingkey
git config --global commit.gpgsign true
git config --global gpg.program gpg2

```

#### Local

```bash
git config user.name ""
git config user.email ""
git config user.signingkey
```

## SSH Reverse Tunnel

```
# crontab -e
@reboot sleep 30 && flock -n /tmp/create-tunnel.lock /home/ouankou/Projects/config/create-tunnel >>/home/ouankou/.create-tunnel.log 2>&1
* * * * * flock -n /tmp/create-tunnel.lock /home/ouankou/Projects/config/create-tunnel >>/home/ouankou/.create-tunnel.log 2>&1
```

## Server Guides

- [GitHub MFA protected JupyterLab](github-oauth2-jupyterlab.md)

## Misc

#### Fix the keyboard not responding on login screen

```bash
# before install ubuntu budgie desktop
sudo apt install xserver-xorg-input-all
```

https://askubuntu.com/questions/1033767/keyboard-not-working-after-update-to-18-04/1033871
