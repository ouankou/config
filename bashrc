
# User specific aliases and functions
export LD_LIBRARY_PATH=/opt/intel/mkl/lib/intel64:$LD_LIBRARY_PATH
export PATH=/opt/intel/bin:$PATH
export LD_LIBRARY_PATH=~/Projects/rex/install/lib:$LD_LIBRARY_PATH
# Add Java lib path
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH
MKL_PATH=/opt/intel/mkl
export MKL_LIB_DIR=${MKL_PATH}/lib/intel64
export MKL_INC_DIR=${MKL_PATH}/include
# Add CUDA path
export PATH=/usr/local/cuda/bin:${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
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
