#!/bin/bash

# setup crontab
# */15 * * * * /etc/rc.local >/dev/null 2>&1

# setup autostart before login
# copy rc.local to /etc/

git config --global user.name "Anjia Wang"
git config --global user.email "anjiawang@gmail.com"
git config --global commit.gpgsign true
git config --global gpg.program gpg2
git config --global core.editor "vim"
#git config --global user.signingkey
