# Add Java lib path
prepend_path() {
    local var_name="$1"
    local value="$2"
    if [ -z "$value" ] || [ ! -d "$value" ]; then
        return
    fi

    local current_value="${!var_name:-}"
    case ":$current_value:" in
        *":$value:"*) ;;
        *)
            if [ -z "$current_value" ]; then
                export "$var_name=$value"
            else
                export "$var_name=$value:$current_value"
            fi
            ;;
    esac
}

remove_path_entry() {
    local var_name="$1"
    local value="$2"
    local current_value="${!var_name:-}"
    local rebuilt=""
    local entry=""

    if [ -z "$current_value" ] || [ -z "$value" ]; then
        return
    fi

    IFS=':' read -r -a _path_entries <<< "$current_value"
    for entry in "${_path_entries[@]}"; do
        if [ -z "$entry" ] || [ "$entry" = "$value" ]; then
            continue
        fi
        if [ -z "$rebuilt" ]; then
            rebuilt="$entry"
        else
            rebuilt="$rebuilt:$entry"
        fi
    done

    if [ -n "$rebuilt" ]; then
        export "$var_name=$rebuilt"
    else
        unset "$var_name"
    fi
}

export JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
prepend_path LD_LIBRARY_PATH "$JAVA_HOME/lib/server"

# Add REX compiler path
export REX_ROOT=$HOME
prepend_path LD_LIBRARY_PATH "$REX_ROOT/rex_install/lib"
prepend_path PATH "$REX_ROOT/rex_install/bin"
export BOOST_LIB=/usr/lib/x86_64-linux-gnu
prepend_path PATH /snap/bin

# Add LLVM path
export LLVM=$HOME/Projects/llvm-22
export LLVM_SYSTEM_PATH=/usr/lib/llvm-22
if [ -d "$LLVM" ]; then
    export LLVM_PATH=$LLVM/llvm_install
else
    export LLVM_PATH=$LLVM_SYSTEM_PATH
fi
export LLVM_SRC=$LLVM/llvm_src
export LLVM_BUILD=$LLVM/llvm_build

remove_path_entry C_INCLUDE_PATH "$LLVM_PATH/include"
remove_path_entry C_INCLUDE_PATH "$LLVM_SYSTEM_PATH/include"
remove_path_entry CPLUS_INCLUDE_PATH "$LLVM_PATH/include"
remove_path_entry CPLUS_INCLUDE_PATH "$LLVM_SYSTEM_PATH/include"
remove_path_entry CPATH "$LLVM_PATH/include"
remove_path_entry CPATH "$LLVM_SYSTEM_PATH/include"
remove_path_entry LIBRARY_PATH "$LLVM_PATH/libexec"
remove_path_entry LIBRARY_PATH "$LLVM_PATH/lib"
remove_path_entry LIBRARY_PATH "$LLVM_PATH/lib/x86_64-linux-gnu"
remove_path_entry LIBRARY_PATH "$LLVM_PATH/lib/x86_64-unknown-linux-gnu"
remove_path_entry LIBRARY_PATH "$LLVM_SYSTEM_PATH/libexec"
remove_path_entry LIBRARY_PATH "$LLVM_SYSTEM_PATH/lib"
remove_path_entry LIBRARY_PATH "$LLVM_SYSTEM_PATH/lib/x86_64-linux-gnu"
remove_path_entry LIBRARY_PATH "$LLVM_SYSTEM_PATH/lib/x86_64-unknown-linux-gnu"

export LLVM_OPENMP_INSTALL=$LLVM_PATH
export LLVM_BINDIR=$LLVM_PATH/bin
prepend_path PATH "$LLVM_PATH/bin"
prepend_path LD_LIBRARY_PATH "$LLVM_PATH/lib"
prepend_path LD_LIBRARY_PATH "$LLVM_PATH/lib/x86_64-unknown-linux-gnu"
prepend_path LD_LIBRARY_PATH "$LLVM_PATH/lib/x86_64-linux-gnu"
prepend_path MANPATH "$LLVM_PATH/share/man"

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
prepend_path PATH "$NVCOMPILERS/$NVARCH/${NVIDIA_HPC_VERSION}/compilers/bin"

# WSL
prepend_path PATH /usr/lib/wsl/lib

# Intel OneAPI compiler
# Emulate FP64 on Intel GPUs (Xe, Arc, ...)
# Disabled since it may slow down clpeak significantly.
# export OverrideDefaultFP64Settings=1
# export IGC_EnableDPEmulation=1
# export ZET_ENABLE_PROGRAM_DEBUGGING=1

export OMP_TARGET_OFFLOAD=MANDATORY

export RUSTICL_ENABLE=radeonsi,iris
