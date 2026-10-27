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

# Remove entries matching a glob pattern, e.g. "/opt/foo/*"
remove_path_entry() {
    local var_name="$1"
    local pattern="$2"
    local current_value="${!var_name:-}"
    local rebuilt=""
    local entry=""

    if [ -z "$current_value" ] || [ -z "$pattern" ]; then
        return
    fi

    IFS=':' read -r -a _path_entries <<< "$current_value"
    for entry in "${_path_entries[@]}"; do
        if [ -z "$entry" ] || [[ $entry == $pattern ]]; then
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

# Add Java lib path, preferring the pinned JDK over the distro default
JAVA_VERSION=25
for dir in /usr/lib/jvm/java-$JAVA_VERSION-openjdk-* /usr/lib/jvm/default-java; do
    if [ -d "$dir" ]; then
        export JAVA_HOME=$dir
        break
    fi
done
unset dir
prepend_path LD_LIBRARY_PATH "$JAVA_HOME/lib/server"

# Add REX compiler path
export REX_ROOT=$HOME
prepend_path LD_LIBRARY_PATH "$REX_ROOT/rex_install/lib"
prepend_path PATH "$REX_ROOT/rex_install/bin"
prepend_path PATH /snap/bin

# Add LLVM path
LLVM_VERSION=23
export LLVM=$HOME/Projects/llvm-$LLVM_VERSION
export LLVM_SYSTEM_PATH=/usr/lib/llvm-$LLVM_VERSION
if [ -d "$LLVM" ]; then
    export LLVM_PATH=$LLVM/llvm_install
else
    export LLVM_PATH=$LLVM_SYSTEM_PATH
fi
export LLVM_SRC=$LLVM/llvm_src
export LLVM_BUILD=$LLVM/llvm_build
export LLVM_OPENMP_INSTALL=$LLVM_PATH
export LLVM_BINDIR=$LLVM_PATH/bin

# Keep LLVM headers and libs out of the default compiler search paths
for var in C_INCLUDE_PATH CPLUS_INCLUDE_PATH CPATH LIBRARY_PATH; do
    remove_path_entry "$var" "$LLVM/*"
    remove_path_entry "$var" "$LLVM_SYSTEM_PATH/*"
done

prepend_path PATH "$LLVM_PATH/bin"
prepend_path MANPATH "$LLVM_PATH/share/man"
# Runtimes may sit in a per-target dir such as lib/aarch64-unknown-linux-gnu
for dir in "$LLVM_PATH/lib" "$LLVM_PATH/lib/$HOSTTYPE"-*/; do
    prepend_path LD_LIBRARY_PATH "${dir%/}"
done
unset var dir

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
export NVARCH=`uname -s`_`uname -m`
export NVCOMPILERS=/opt/nvidia/hpc_sdk
NVHPC_ROOT=$NVCOMPILERS/$NVARCH/$NVIDIA_HPC_VERSION
export NVHPC_CUDA_HOME=$NVHPC_ROOT/cuda/$CUDA_VERSION
export CUDA_PATH=$NVHPC_CUDA_HOME
prepend_path PATH "$NVHPC_CUDA_HOME/bin"
prepend_path LD_LIBRARY_PATH "$NVHPC_CUDA_HOME/lib64"
# The target dir is per arch, e.g. x86_64-linux or sbsa-linux
for dir in "$NVHPC_ROOT/math_libs/$CUDA_VERSION/targets"/*/lib; do
    prepend_path LD_LIBRARY_PATH "$dir"
done
unset dir
prepend_path PATH "$NVHPC_ROOT/compilers/bin"

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
