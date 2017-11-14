sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install -y git gedit autojump terminator vim tmux
# stuff for service robots:
sudo apt-get install -y  openssh
# rcode
sudo wget -O /usr/local/bin/rcode https://raw.github.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/rcode

# git setu
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=7200'
git config --global user.name 'Michael Sobrepera'
git config --global user.email mjsobrep@live.com

mv ~/.bashrc ~/Documents/git/config_files/linux/bashrc-old
ln -s ~/Documents/git/config_files/linux/bashrc ~/.bashrc


