
# Add Java lib path
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
if [ -z "${LD_LIBRARY_PATH}" ]
then
    LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server
else
    LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH
fi

# Add REX compiler path
export REX_ROOT=$HOME/Projects/rexdev
export LD_LIBRARY_PATH=$REX_ROOT/rex_install/lib:$LD_LIBRARY_PATH
export PATH=$REX_ROOT/rex_install/bin:$PATH
export BOOST_LIB=/usr/lib/x86_64-linux-gnu
export PATH=/snap/bin:$PATH

# Add LLVM path
export LLVM=$HOME/Projects/llvm_gpu
export LLVM_SRC=$LLVM/llvm_src
export LLVM_PATH=$LLVM/llvm_install
export LLVM_BUILD=$LLVM/llvm_build

export PATH=$LLVM_PATH/bin:$PATH
export LD_LIBRARY_PATH=$LLVM_PATH/libexec:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LLVM_PATH/lib:$LD_LIBRARY_PATH
if [ -z "${LIBRARY_PATH}" ]
then
    LIBRARY_PATH=$LLVM_PATH/libexec
else
    LIBRARY_PATH=$LLVM_PATH/libexec:$LIBRARY_PATH
fi

export LIBRARY_PATH=$LLVM_PATH/lib:$LIBRARY_PATH
export MANPATH=$LLVM_PATH/share/man:$MANPATH
if [ -z "${C_INCLUDE_PATH}" ]
then
    C_INCLUDE_PATH=$LLVM_PATH/include
else
    C_INCLUDE_PATH=$LLVM_PATH/include:$C_INCLUDE_PATH
fi
if [ -z "${C_INCLUDE_PATH}" ]
then
    CPLUS_INCLUDE_PATH=$LLVM_PATH/include
else
    CPLUS_INCLUDE_PATH=$LLVM_PATH/include:$CPLUS_INCLUDE_PATH
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
NVIDIA_HPC_VERSION=22.1
export PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/${NVIDIA_HPC_VERSION}/cuda/bin:${PATH}
export LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/${NVIDIA_HPC_VERSION}/cuda/lib64:${LD_LIBRARY_PATH}
export CUDA_ARCH=sm_86

export NVARCH=`uname -s`_`uname -m`
export NVCOMPILERS=/opt/nvidia/hpc_sdk
export MANPATH=$MANPATH:$NVCOMPILERS/$NVARCH/${NVIDIA_HPC_VERSION}/compilers/man
export PATH=$NVCOMPILERS/$NVARCH/${NVIDIA_HPC_VERSION}/compilers/bin:${PATH}
export PATH=$NVCOMPILERS/$NVARCH/${NVIDIA_HPC_VERSION}/comm_libs/mpi/bin:${PATH}
export MANPATH=$MANPATH:$NVCOMPILERS/$NVARCH/${NVIDIA_HPC_VERSION}/comm_libs/mpi/man

# Add GCC path
export OPT_GCC=/opt/gcc/gcc-11.x-install
export PATH=${OPT_GCC}/bin:$PATH
export LD_LIBRARY_PATH=${OPT_GCC}/lib64:$LD_LIBRARY_PATH

