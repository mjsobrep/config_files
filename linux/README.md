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
after the backslash key

Make a new file called ~/.Xmodmap and put in it:
clear Lock
keycode 66 = ISO_Level3_Shift

### Make it start when you login:
search for startup application preferences (from launcher)
add a new one
make the command: `xmodmap ~/.Xmodmap`
