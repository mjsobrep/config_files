# ZSH

## Installing:
Follow [these instructions](https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH)


Install some more fonts:
sudo apt install ttf-ancient-fonts

run:
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


Install the bullet line theme:
wget http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -P $ZSH_CUSTOM/themes

Link in the config file here:
ln -s ~/Documents/git/config_files/zsh ~/.zshrc 
