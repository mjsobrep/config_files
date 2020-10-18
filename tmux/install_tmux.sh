set -e

sudo apt remove -y tmux

sudo apt install -y libevent-dev libncurses5-dev libncursesw5-dev

sudo apt install -y make autoconf automake pkg-config

sudo apt install -y xclip

prior=$(pwd)
cd ~/Downloads
curl -s https://api.github.com/repos/tmux/tmux/releases/latest|grep "browser_download_url.*gz" | cut -d : -f 2,3 | tr -d \" | wget -i -
tar -xzf tmux-*.tar.gz
cd tmux-*/
./configure 
make && sudo make install
cd ..
rm -rf tmux-*
cd $prior

ln -s -f ~/Documents/git/config_files/tmux/tmux.conf ~/.tmux.conf
