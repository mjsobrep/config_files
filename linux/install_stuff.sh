set -e

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt install -y git curl build-essential autoconf cmake

# fasd for fast jumping and searching
sudo add-apt-repository -y ppa:aacebedo/fasd
sudo apt-get update -y
sudo apt-get install -y fasd

./zsh/install_zsh.sh 
./nvim/install_neovim.sh 
./tmux/install_tmux.sh

sudo apt autoremove -y

sudo reboot
