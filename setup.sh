#!/bin/bash

# setup crontab
# */15 * * * * /etc/rc.local >/dev/null 2>&1

# setup autostart before login
# copy rc.local to /etc/

sudo apt update && \
sudo apt install -y openjdk-11-jdk && \
sudo apt install -y \
        antlr4 \
        autoconf \
        automake \
        autotools-dev \
        bc \
        binutils \
        bison \
        build-essential \
        cmake \
        cpufrequtils \
        curl \
        device-tree-compiler \
        dkms \
        doxygen \
        flex \
        gawk \
        g++-9 \
        gdb \
        gfortran-9 \
        ghostscript \
        git \
        gperf \
        graphviz \
        libantlr4-runtime-dev \
        libboost-all-dev \
        libgmp-dev \
        libhpdf-dev \
        libmpc-dev \
        libmpfr-dev \
        libtool \
        libxml2-dev \
        patchutils \
        perl-doc \
        python3-dev \
        sqlite3 \
        texinfo \
        unzip \
        vim \
        wget \
        zip \
        zlib1g \
        zlib1g-dev

sudo apt install -y \
        gnupg2 \
        htop \
        libelf-dev \
        libffi-dev \
        neofetch \
        ninja-build

# Packages not available on Arm
sudo apt install -y \
        g++-9-multilib \
        gcc-9-multilib

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install -y g++-11

cat bashrc >> $HOME/.bashrc

git config --global user.name "Anjia Wang"
git config --global user.email "anjiawang@gmail.com"
git config --global commit.gpgsign true
git config --global gpg.program gpg2
git config --global core.editor "vim"
#git config --global user.signingkey

sudo apt install -y \
        fcitx-rime \
        fonts-firacode \
        fonts-wqy-microhei \
        fonts-wqy-zenhei \
        intel-opencl-icd \
        libdrm2 \
        libxcb-dri3-0 \
        psensor \
        vim-gtk3

sudo add-apt-repository -y ppa:christian-boxdoerfer/fsearch-daily
sudo apt update
sudo apt install -y fsearch

