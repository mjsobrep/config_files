set -e

# Instal neovim
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install neovim
sudo apt-get install python-dev python-pip python3-dev python3-pip

# bring in neovim config
mkdir ~/.config/nvim
ln -s ~/Documents/git/config_files/nvim/init.vim ~/.config/nvim/init.vim

# install vim plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install ctags
prior=$(pwd)
cd ~/Downloads
git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh 
./configure
make
sudo make install
cd $prior

# powerline fonts
sudo apt install fonts-powerline

# vim remote
pip3 install --user neovim-remote

#silver searcher
sudo apt install silversearcher-ag

# tex dependencies
# sudo apt install texlive-full
sudo apt install xdotool
sudo apt install zathura

# hop into vim and install everything
nvim +PlugInstall +qall > /dev/null

# finish you complete me setup
python3 ~/.local/share/nvim/plugged/YouCompleteMe/install.py --clang-completer
