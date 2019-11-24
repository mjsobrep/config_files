#!/bin/bash

set -e

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt install -y git curl build-essential autoconf cmake

# fasd for fast jumping and searching
if(($(cat /etc/os-release | grep VERSION_ID|grep -o '".*"' | sed 's/"//g' | cut -c1-2 )==16))
    then
        sudo add-apt-repository -y ppa:aacebedo/fasd
fi
sudo apt-get update -y
sudo apt-get install -y fasd

### LATEX ###
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

./zsh/install_zsh.sh
./nvim/install_neovim.sh
./tmux/install_tmux.sh

sudo apt autoremove -y

sudo reboot
