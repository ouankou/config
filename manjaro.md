# OS

[Manjaro Linux](https://manjaro.org/) based on Arch Linux.
[Flavor Cinnamon](https://manjaro.org/download/#cinnamon) is preferred.

# Install Packages

```bash
# Common tools
yay -Syu \
    aria2 \
    automake \
    chromium \
    clang \
    cmake \
    cndrvcups-lt \
    docker-compose \
    fcitx-configtool \
    fcitx-im \
    fcitx-rime \
    gimp \
    gvim \
    htop \
    inkscape \
    jdk8-openjdk \
    neofetch \
    octave \
    p7zip \
    python-virtualenv \
    texlive-most \
    ttf-jetbrains-mono \
    uget \
    vlc \
    wqy-microhei \
    wqy-zenhei
```

# Fix Time Synchronization

```bash
timedatectl set-ntp true
```
Ref: https://wiki.archlinux.org/index.php/systemd-timesyncd

# Setup Fcitx

`fcitx-im` is required, otherwise `CTRL+SPACE` may not work. Add the following content to `~/.pam_environment`.
```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```
Ref: https://wiki.archlinux.org/index.php/fcitx
