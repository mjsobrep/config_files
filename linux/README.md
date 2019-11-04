# Useful general linux tweaks

## FASD
jump around with shortcuts
sudo add-apt-repository ppa:aacebedo/fasd
sudo apt-get update
sudo apt-get install fasd


## remapping keyboard on linux
edit /usr/share/X11/xkb/symbols/us to have Up in the third place for key AD02, Left in third place for AC01, Down for AC02, and Right for AC03
Add a new key:
`key <SPCE> { [ space, space, Escape]};`
`key <NMLK> { [ Delete, Num_Lock] };`
after the backslash key

Now done in bashrc:
Make a new file called ~/.Xmodmap and put in it:
clear Lock
keycode 66 = ISO_Level3_Shift

### Make it start when you login:
Whenever a shell is opened, this will get started, so just open a shell at some point

## Remote control
Can use mintty+x11 window manager on windows. Works well but maybe slow

Can use NX: gives you all of your windows, which sucks

Can use xrdp with xrdp.xorg : Will need to use MATE, XFCE4, or LXDE
once the other wm manager has been installed, you will need to tell XRDP to use it. Then restart xrdp and maybe you are good to go.
TO tell it what to use: `echo xfce4-sesion >~/.xsession` which is used to determine which x server to launch, but maybe not used by lightdm?
To tell it to restart xrdp: `sudo service xrdp restart`
Follow these instructions here: https://github.com/neutrinolabs/xrdp/wiki/Compiling-and-using-xorgxrdp
