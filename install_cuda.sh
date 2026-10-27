#!/bin/bash

NVHPC_PKG=nvhpc_2024_243_$(uname -s)_$(uname -m)_cuda_12.3
wget https://developer.download.nvidia.com/hpc-sdk/24.3/$NVHPC_PKG.tar.gz
tar xpzf $NVHPC_PKG.tar.gz
sudo $NVHPC_PKG/install
