#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH
# virtualenv -p python3 venv
# pip install -r jupyterhub_requirements.txt
cd venv
. ./bin/activate
nohup jupyterhub --no-ssl &
