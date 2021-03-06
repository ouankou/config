#!/bin/bash

# setup crontab
# */15 * * * * /etc/rc.local >/dev/null 2>&1

# setup autostart before login
# copy rc.local to /etc/

sudo apt update && \
sudo apt install -y openjdk-8-jdk && \
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
        gcc-multilib \
        gdb \
        gfortran \
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
        libomp-dev \
        libtool \
        libxml2-dev \
        patchutils \
        perl-doc \
        python3-dev \
        sqlite \
        texinfo \
        unzip \
        vim \
        wget \
        zip \
        zlib1g \
        zlib1g-dev

sudo apt install -y \
        fcitx-rime \
        fonts-firacode \
        fonts-wqy-microhei \
        fonts-wqy-zenhei \
        gnupg2 \
        htop \
        libelf-dev \
        libffi-dev \
        neofetch \
        ninja-build \
        psensor \
        vim-gtk3

sudo add-apt-repository -y ppa:christian-boxdoerfer/fsearch-daily
sudo apt update
sudo apt install -y fsearch-trunk

cat bashrc >> $HOME/.bashrc

git config --global user.name "Anjia Wang"
git config --global user.email "anjiawang@gmail.com"
git config --global commit.gpgsign true
git config --global gpg.program gpg2
git config --global core.editor "vim"
#git config --global user.signingkey
