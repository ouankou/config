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
    docker-compose \
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
