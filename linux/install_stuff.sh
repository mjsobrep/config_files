#!/bin/bash

set -e
shopt -s expand_aliases

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install -y git curl build-essential autoconf cmake python3-pip

VERSION_ID=$(cat /etc/os-release | grep VERSION_ID|grep -o '".*"' | sed 's/"//g' | cut -c1-2 )

case $VERSION_ID in
  20|22)
    alias pip="pip3"
    ;;
  *)
    sudo apt-get install -y python-pip
    ;;
esac

pip install --user pipenv pylint autopep8
pip install --user yamllint

# fasd for fast jumping and searching
if(($(cat /etc/os-release | grep VERSION_ID|grep -o '".*"' | sed 's/"//g' | cut -c1-2 )==16))
    then
        sudo add-apt-repository -y ppa:aacebedo/fasd
fi
sudo apt-get update -y
sudo apt-get install -y fasd

### LATEX ###
if [[ $(type latex) ]]; then
    echo "texlive installed, not re-installing"
else
    echo "texlive is not installed, installing now"
    prior=$(pwd)
    mkdir -p ~/Downloads
    cd ~/Downloads
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
    tar -xzf install-tl-unx.tar.gz
    rm install-tl-unx.tar.gz
    cd install-tl-*
    read tex_dir <<< $(ls .. | grep install-tl-)
    year=${tex_dir:11:4}
    export TEXLIVE_INSTALL_PREFIX=/home/$USER/texlive
    export TEXLIVE_INSTALL_TEXDIR=/home/$USER/texlive/$year
    ./install-tl
    cd $prior
fi
# Get the four-digit number directory in ~/texlive (version year)
FOUR_DIGIT_DIR=$(find ~/texlive -maxdepth 1 -type d -regex "^.*[0-9][0-9][0-9][0-9]$" | sort -n | tail -1)
# Create the path to the bin directory (to add to path in profiles)
BIN_DIR="$FOUR_DIGIT_DIR/bin/x86_64-linux"
# Check if the path is added to the path in .bashrc
if grep -q "$BIN_DIR" ~/.bashrc; then
    echo "The path $BIN_DIR is already added to the path in .bashrc."
else
    echo "The path $BIN_DIR is not added to the path in .bashrc. Adding it now..."
    echo "" >> ~/.bashrc
    echo "export PATH=\$PATH:$BIN_DIR" >> ~/.bashrc
fi

./zsh/install_zsh.sh
./node/install_node.sh
./nvim/install_neovim.sh
./tmux/install_tmux.sh

sudo ubuntu-drivers autoinstall

sudo apt autoremove -y

sudo reboot
