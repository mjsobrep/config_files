#!/bin/bash
set -e

sudo apt install -y zsh
chsh -s $(which zsh)

# pull down antigen somewhere, lets say to `~`:
ANTIGEN_PATH="${ANTIGEN_PATH:-$HOME/.antigen.zsh}"
curl -L git.io/antigen > "$ANTIGEN_PATH"

# Install some more fonts:
sudo apt install -y ttf-ancient-fonts

# Link in the config file here:
ln -s -f ~/Documents/git/config_files/zsh/zshrc ~/.zshrc

sudo apt install -y xsel xclip
