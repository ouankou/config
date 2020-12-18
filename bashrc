
# Add Java lib path
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH

# Add CUDA path
export PATH=/usr/local/cuda/bin:${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Add REX compiler path
export REX_ROOT=$HOME/Projects/rexcompiler
export LD_LIBRARY_PATH=$REX_ROOT/rex_install/lib:$LD_LIBRARY_PATH
export PATH=$REX_ROOT/rex_install/bin:$PATH

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
