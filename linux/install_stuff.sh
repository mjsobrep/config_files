sudo apt-get update -y && sudo apt-get upgrade -y

# fasd for fast jumping and searching
sudo add-apt-repository ppa:aacebedo/fasd
sudo apt-get update
sudo apt-get install fasd

./zsh/install_zsh.sh 
./nvim/install_neovim.sh 
./tmux/install_tmux.sh