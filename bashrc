# Add Java lib path
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
if [ -z "${LD_LIBRARY_PATH}" ]
then
    export LD_LIBRARY_PATH=$JAVA_HOME/lib/server
else
    export LD_LIBRARY_PATH=$JAVA_HOME/lib/server:$LD_LIBRARY_PATH
fi

# Add REX compiler path
export REX_ROOT=$HOME/Projects/rexdev
export LD_LIBRARY_PATH=$REX_ROOT/rex_install/lib:$LD_LIBRARY_PATH
export PATH=$REX_ROOT/rex_install/bin:$PATH
export BOOST_LIB=/usr/lib/x86_64-linux-gnu
export PATH=/snap/bin:$PATH

# Add LLVM path
export LLVM=$HOME/Projects/llvm-20
if [ -d "$LLVM" ]; then
    export LLVM_PATH=$LLVM/llvm_install
else
    export LLVM_PATH=/usr/lib/llvm-19
fi
export LLVM_SRC=$LLVM/llvm_src
export LLVM_BUILD=$LLVM/llvm_build

export PATH=$LLVM_PATH/bin:$PATH
export LD_LIBRARY_PATH=$LLVM_PATH/libexec:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LLVM_PATH/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LLVM_PATH/lib/x86_64-unknown-linux-gnu:$LD_LIBRARY_PATH
if [ -z "${LIBRARY_PATH}" ]
then
    export LIBRARY_PATH=$LLVM_PATH/libexec
else
    export LIBRARY_PATH=$LLVM_PATH/libexec:$LIBRARY_PATH
fi

export LIBRARY_PATH=$LLVM_PATH/lib:$LIBRARY_PATH
export LIBRARY_PATH=$LLVM_PATH/lib/x86_64-linux-gnu:$LIBRARY_PATH
export MANPATH=$LLVM_PATH/share/man:$MANPATH
if [ -z "${C_INCLUDE_PATH}" ]
then
    export C_INCLUDE_PATH=$LLVM_PATH/include
else
    export C_INCLUDE_PATH=$LLVM_PATH/include:$C_INCLUDE_PATH
fi
if [ -z "${CPLUS_INCLUDE_PATH}" ]
then
    export CPLUS_INCLUDE_PATH=$LLVM_PATH/include
else
    export CPLUS_INCLUDE_PATH=$LLVM_PATH/include:$CPLUS_INCLUDE_PATH
fi

# Add GPG support
export GPG_TTY=$(tty)

# Add SSH key
eval $(ssh-agent -s) > /dev/null
added_keys=`ssh-add -l`
if [ ! $(echo $added_keys | grep -o -e id_rsa_contact) ]; then
    ssh-add "$HOME/.ssh/id_rsa_contact.key" &> /dev/null
fi
if [ ! $(echo $added_keys | grep -o -e id_rsa_llnl) ]; then
    ssh-add "$HOME/.ssh/id_rsa_llnl.key" &> /dev/null
fi

# Add CUDA path
NVIDIA_HPC_VERSION=24.3
CUDA_VERSION=12.3
export PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/${NVIDIA_HPC_VERSION}/cuda/${CUDA_VERSION}/bin:${PATH}
export LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/${NVIDIA_HPC_VERSION}/cuda/${CUDA_VERSION}/lib64:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/${NVIDIA_HPC_VERSION}/math_libs/${CUDA_VERSION}/targets/x86_64-linux/lib:${LD_LIBRARY_PATH}
export NVHPC_CUDA_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/${NVIDIA_HPC_VERSION}/cuda/${CUDA_VERSION}
export CUDA_PATH=${NVHPC_CUDA_HOME}

export NVARCH=`uname -s`_`uname -m`
export NVCOMPILERS=/opt/nvidia/hpc_sdk
export PATH=$NVCOMPILERS/$NVARCH/${NVIDIA_HPC_VERSION}/compilers/bin:${PATH}

# WSL
export PATH=${PATH}:/usr/lib/wsl/lib

# Intel OneAPI compiler
# Emulate FP64 on Intel GPUs (Xe, Arc, ...)
# Disabled since it may slow down clpeak significantly.
# export OverrideDefaultFP64Settings=1
# export IGC_EnableDPEmulation=1
export ZET_ENABLE_PROGRAM_DEBUGGING=1

export OMP_TARGET_OFFLOAD=MANDATORY

export RUSTICL_ENABLE=radeonsi
