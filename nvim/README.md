# Neovim setup

## Install
Follow [instructions](https://github.com/neovim/neovim/wiki/Installing-Neovim#ubuntu)

## What terminal emulator should I use?
- Ubuntu Terminal : OK
- Terminator : BAD
- acritty : Need to try
- kitty : Need to try

## Configure

Use the init.vim stored here by doing this:
ln -s /home/mjsobrep/Documents/git/config_files/nvim/init.vim /home/mjsobrep/.config/nvim/init.vim

[install vim-plug](https://github.com/junegunn/vim-plug#neovim)

## Getting ctags to work
Follow the instructions here: https://askubuntu.com/questions/796408/installing-and-using-universal-ctags-instead-of-exuberant-ctags
you may need to change the binary location in the init.vim file

## Powerline symbols:
sudo apt install fonts-powerline

## Remote access to open files:
pip3 install neovim-remote -u

## Silver searcher
sudo apt install silversearcher-ag
