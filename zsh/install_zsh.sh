sudo apt install zsh
sudo chsh -s $(which zsh)

# pull down antigen somewhere, lets say to `~`:
curl -L git.io/antigen > ~/antigen.zsh

# Install some more fonts:
sudo apt install ttf-ancient-fonts

# Link in the config file here:
ln -s ~/Documents/git/config_files/zsh/zshrc ~/.zshrc 