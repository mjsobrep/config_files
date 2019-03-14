# TMUX
## Installing
Check that you have tmux > 2.3: `tmux -V`
If not, use apt to install dependencies, pull down the latest tmux, configure, make and isntall

## Getting tmux config
My tmux config is stored here. 
It should be linked into a .tmux.config file in the home directory, like this: 
ln -s ~/Documents/git/config_files/tmux/tmux.conf ~/.tmux.conf

## Working nice with vim

### Esc delay
There is a delay to the escape key introduced by tmux. This is fixed in the tmux config. 
