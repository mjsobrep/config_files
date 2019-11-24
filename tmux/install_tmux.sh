set -e

sudo apt remove -y tmux

sudo apt install -y libevent-dev libncurses5-dev libncursesw5-dev

sudo apt install -y make autoconf automake pkg-config

sudo apt install -y xclip

prior=$(pwd)
cd ~/Downloads
wget https://github.com/tmux/tmux/releases/download/2.9a/tmux-2.9a.tar.gz
tar -xzf tmux-2.9a.tar.gz
cd tmux-2.9a
./configure && make
sudo make install
cd ..
rm -rf tmux-2.9a
cd $prior

ln -s -f ~/Documents/git/config_files/tmux/tmux.conf ~/.tmux.conf
