set -e 

sudo apt install -y zsh
chsh -s $(which zsh)

# pull down antigen somewhere, lets say to `~`:
curl -L git.io/antigen > ~/antigen.zsh

# Install some more fonts:
sudo apt install -y ttf-ancient-fonts

# Link in the config file here:
ln -s -f ~/Documents/git/config_files/zsh/zshrc ~/.zshrc 
