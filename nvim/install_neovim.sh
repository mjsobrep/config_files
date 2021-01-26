set -e
shopt -s expand_aliases

# Instal neovim
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt-get update -y
sudo apt-get install -y neovim
sudo apt-get install -y python3-dev python3-pip

pip3 install pynvim
if(($(cat /etc/os-release | grep VERSION_ID|grep -o '".*"' | sed 's/"//g' | cut -c1-2 )<=18))
    then
    	sudo apt-get install -y python-pip python-dev
	pip2 install pynvim
    else
    	alias pip="pip3"
fi


# bring in neovim config
mkdir -p ~/.config/nvim
ln -s -f ~/Documents/git/config_files/nvim/init.vim ~/.config/nvim/init.vim

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
cd ..
rm -rf ctags
cd $prior

# powerline fonts
sudo apt install -y fonts-powerline

# vim remote
pip3 install --user neovim-remote

# prose lint for linting text
pip install --user proselint

# Alex for insensitive writing
npm install alex --global

#silver searcher
sudo apt install -y silversearcher-ag

# tex dependencies
# sudo apt install texlive-full
sudo apt install -y xdotool zathura

# hop into vim and install everything
nvim +PlugInstall +qall > /dev/null

# A better, faster version of find, runs all of the searching:
prior=$(pwd)
cd ~/Downloads
curl -s https://api.github.com/repos/sharkdp/fd/releases/latest|grep "browser_download_url.*fd_.*amd64\.deb" | cut -d : -f 2,3 | tr -d \" | wget -i -
sudo dpkg -i fd_*_amd64.deb
rm fd_*_amd64.deb
cd $prior

# install lsp
pip install jedi --user
pip install python-language-server --user

# nerd fonts
prior=$(pwd)
cd ~/Downloads
git clone https://github.com/ryanoasis/nerd-fonts.git --depth=1
cd nerd-fonts
./install.sh
cd ..
rm -rf nerd-fonts
cd $prior

# C++ linters/fixers
sudo apt-get install -y clang-tidy
sudo apt install -y clang-format

# ripgrep
prior=$(pwd)
cd ~/Downloads
curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest|grep "browser_download_url.*ripgrep_.*amd64\.deb" | cut -d : -f 2,3 | tr -d \" | wget -i -
sudo dpkg -i ripgrep_*_amd64.deb
rm ripgrep_*_amd64.deb
cd $prior
