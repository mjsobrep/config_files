# config_files

Start by installing linux, then git `sudo apt install -y git`

Then setup a credential manager:
- Ubuntu 16
    - `sudo apt-get install libgnome-keyring-dev`
    - `sudo make --directory=/usr/share/doc/git/contrib/credential/gnome-keyring`
    - `git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring`
- Ubuntu 18
    - `sudo apt install -y libsecret-1-0 libsecret-1-dev`
    - `cd /usr/share/doc/git/contrib/credential/libsecret`
    - `sudo make`
    - `git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret`

If you are on windows, then just install git and it works.
If you are in WSL, then install git in windows and type into wsl:
`git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"`

Then get a new auth key from github MAKE SURE TO GET REPO PERMISSIONS.

To install on linux, pull this to ~/Documents/git/config_files
the scripts are dumb af, they won't work anywhere else.
Then from the root of this repo, run ./linux/install_stff.sh
currently the scripts print a lot.

Once it is done, log out and back in.

One thing to note when working with ROS is that things that
you install to python normally might not be available in ROS
For example, flake. So it is best to source all of the ros stuff
before opening your text editor. You may find that you also need
to pip install flake8, etc. after sourcing ROS stuff.

## Display issues
Your display is being dynamic, but you have a desktop?
Install arandr, setup a config script, and then run it at startup

## Git credentials

Use [git credential manager core](https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/install.md)