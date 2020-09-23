set -e

# Instal neovim
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt-get update -y
sudo apt-get install -y neovim
sudo apt-get install -y python-dev python-pip python3-dev python3-pip
pip3 install pynvim
pip2 install pynvim

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
wget https://github.com/sharkdp/fd/releases/download/v7.3.0/fd_7.3.0_amd64.deb
sudo dpkg -i fd_7.3.0_amd64.deb
rm fd_7.3.0_amd64.deb
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
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
sudo dpkg -i ripgrep_11.0.2_amd64.deb
rm ripgrep_11.0.2_amd64.deb
cd $prior
