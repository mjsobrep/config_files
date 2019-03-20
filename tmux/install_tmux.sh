sudo apt remove tmux

sudo apt install libevent-dev
sudo apt install libncurses5-dev libncursesw5-dev

sudo apt install make autoconf automake pkg-config
prior=$(pwd)
cd ~/Downloads
wget https://github.com/tmux/tmux/releases/download/2.8/tmux-2.8.tar.gz
tar -xzf tmux-2.8.tar.gz
cd tmux-2.8
./configure && make
sudo make install
cd $prior

ln -s ~/Documents/git/config_files/tmux/tmux.conf ~/.tmux.conf