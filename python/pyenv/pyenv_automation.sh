#!/bin/bash


echo "The following command is recommended the first time executing this script:"
echo
echo "sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"
echo
echo

echo "type in [yY] to execute the above command. To cancel the script type in [nN]. To skip the command type [sS]"
echo

# USER INPUT #
while true; do
    read userInput
    case $userInput in
        [Yy])
            echo
            echo "Continue with command ..."
            sleep 1
            echo
            sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev curl \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
            break
            ;;
        [sS])
            echo
            echo "Skipping command ..."
            echo
            break
            ;;
        [Nn])
            echo
            echo "Cancel script."
            echo
            exit 0
            ;;
        *)
            echo "Unknown input. Please type in 'y' or 'Y' or 's' or 'S' or 'n' or 'N'."
            ;;
    esac
done

# 1. Execute initial command
# INFO: || true => Script continues even with WARNING message
curl -fs https://pyenv.run | bash || true

# 2. .bashrc extensions
# INFO: Checks if the lines have been already written to the file or not
if grep -Fxq 'export PYENV_ROOT="$HOME/.pyenv"' ~/.bashrc && \
   grep -Fxq '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' ~/.bashrc && \
   grep -Fxq 'eval "$(pyenv init -)"' ~/.bashrc; then
    echo "Pyenv lines are already present in .bashrc. Skipping addition."
else
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
fi


# 3. Load shell configuration again.
source ~/.bashrc

# XX. pyenv installs the newest versions of a specific version
# INFO: -v = verbose mode
# INFO: -s = skip existing python verions (Remove if you want to reinstall some versions.)
#pyenv install -v "$(pyenv latest -k 3.12)" "$(pyenv latest -k 3.11)" "$(pyenv latest -k 3.10)"

### CONTINUE HERE: ###

# Get all the available [2|3].XX.XX-dev/0a[0-9] versions: pyenv install -l | grep -E '^\s*(2\.[0-9]+(\.[0-9]+)?(-dev)?|3\.[0-9]+(\.[0-9]+)?(-dev|.0a[0-9])?)\s*$'

echo "Show available Python 2.X and Python 3.X versions."
echo "Type in either one to list the versions: 2 | 3 | 23 | 32"
echo "Type in [sS] to skip this step."
echo

# USER INPUT #
while true; do
    read userInput
    case $userInput in
        [2])
            echo
            echo "Executing: pyenv install -l | grep -E '^\s*2\.[0-9]+(\.[0-9]+)?(-dev)?\s*$'"
            echo
            pyenv install -l | grep -E '^\s*2\.[0-9]+(\.[0-9]+)?(-dev)?\s*$'
            echo
            break
            ;;
        [3])
            echo
            echo "Executing: pyenv install -l | grep -E '^\s*3\.[0-9]+(\.[0-9]+)?(-dev|.0a[0-9])?\s*$'"
            echo
            pyenv install -l | grep -E '^\s*3\.[0-9]+(\.[0-9]+)?(-dev|.0a[0-9])?\s*$'
            echo
            break
            ;;
        23|32)
            echo
            echo "Executing: pyenv install -l | grep -E '^\s*(2\.[0-9]+(\.[0-9]+)?(-dev)?|3\.[0-9]+(\.[0-9]+)?(-dev|.0a[0-9])?)\s*$'"
            echo
            pyenv install -l | grep -E '^\s*(2\.[0-9]+(\.[0-9]+)?(-dev)?|3\.[0-9]+(\.[0-9]+)?(-dev|.0a[0-9])?)\s*$'
            echo
            break
            ;;
        [sS])
            echo
            echo "Skipping."
            exit 0
            ;;
        *)
            echo "Unknown input. Please type in '2' or '3' or '23' or '32' or 's' or 'S'."
            ;;
    esac
done