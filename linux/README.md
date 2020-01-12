# Useful general linux tweaks

## FASD
jump around with shortcuts
sudo add-apt-repository ppa:aacebedo/fasd
sudo apt-get update
sudo apt-get install fasd


## remapping keyboard on linux
This is all coming from: https://wiki.archlinux.org/index.php/X_keyboard_extension

There is a list of available keysyms that seem to work here: http://docs.ev3dev.org/projects/grx/en/ev3dev-stretch/c-api/input_keysyms.html

This is being done manually to allow you to start with the configuration that is already there on your computer to prevent compatibility issues with different keyboards.
Examples of prior runs of this are seen in `config_files/linux/keyboards`


Begin by running `xkbcomp $DISPLAY output.xkb` to get your current keyboard
settings.
Then add:
```c
    interpret osfLeft{
        repeat= True;
        action = RedirectKey(keycode=<LEFT>, clearmodifiers=Lock);
    };
    interpret osfRight{
        repeat= True;
        action = RedirectKey(keycode=<RGHT>, clearmodifiers=Lock);
    };
    interpret osfDown{
        repeat= True;
        action = RedirectKey(keycode=<DOWN>, clearmodifiers=Lock);
    };
    interpret osfUp{
        repeat= True;
        action = RedirectKey(keycode=<UP>, clearmodifiers=Lock);
    };
    interpret osfEndLine{
        repeat= True;
        action = RedirectKey(keycode=<END>, clearmodifiers=Lock);
    };
    interpret osfBeginLine{
        repeat= True;
        action = RedirectKey(keycode=<HOME>, clearmodifiers=Lock);
    };
    interpret osfEscape{
        repeat=True;
        action = RedirectKey(keycode=<ESC>, clearmodifiers=Lock);
    };
```
to the compatibility section of the generated file.

To the bottom of the types section, add:
```c
   type "CUST_CAPSLOCK" {
       modifiers= Shift+Lock;
       map[Shift] = Level2;            // Note that this maps Shift only of {Shift,Lock} to Level2. Alt+Shift will be mapped to Level2
       map[Shift+Lock] = Level3;       // but Lock+Shift won't map to Level2 even without this line.
       map[Lock] = Level3;
       level_name[Level1]= "Base";
       level_name[Level2]= "Shift";
       level_name[Level3]= "Lock";
   };
   interpret osfDelete{
       repeat=True;
       action = RedirectKey(keycode=<DELE>, clearmodifiers=Lock);
   };
```

Search for `interpret Caps_Lock` and change the `LockMods` to `SetMods`
so that caps lock only sets the modifier, doesn't lock it.


To allow capslock + WASD to work as arrow keys: edit the keys `<AD02>`, `<AC01>`, `<AC02>`, `<AC03>` to have type `CUST_CAPSLOCK` and have respectively `osfUp`, `osfLeft`, `osfDown`, `osfRight` in the third position.

To allow capslock + HJKL to work as arrow keys: edit the keys `<AC06>`, `<AC07>`, `<AC08>`, `<AC09>` to have type `CUST_CAPSLOCK` and have respectively `osfLeft`, `osfDown`, `osfUp`, `osfRight` in the third position.

To allow capslock + 0 to register as home and capslock + $ to register as end: edit the keys `<AE04>` and `<AE10>` to have type `CUST_CAPSLOCK` and have respectively `osfEndLine` and `osfBeginLine` in the the third position.

To allow capslock + space bar to register as escape (handy for vim) edit the key `<SPCE>` to have type `CUST_CAPSLOCK`, have `space` in the second position and `osfEscape` in the third position.

To turn the numlock key into a delete key and make capslock + numlock make the `<NMLK>` have type `CUST_CAPSLOCK`, have position one and two have `osfDelete` and posiition three have `Num_Lock`

Now upload the changed file back into the server with: `xkbcomp output.xkb $DISPLAY`.
If everything works, put file somewhere, `~/.Xkeymap` works and add to `~/.xinitrc`: `test -f ~/.Xkeymap && xkbcomp ~/.Xkeymap $DISPLAY`

### Old Way:

edit `/usr/share/X11/xkb/symbols/us` to have Up in the third place for key AD02, Left in third place for AC01, Down for AC02, and Right for AC03
Add a new key:
`key <SPCE> { [ space, space, Escape]};`
`key <NMLK> { [ Delete, Num_Lock] };`
after the backslash key

Now done in bashrc:
Make a new file called ~/.Xmodmap and put in it:
clear Lock
keycode 66 = ISO_Level3_Shift

#### Make it start when you login:
Whenever a shell is opened, this will get started, so just open a shell at some point

## Remote control
Can use mintty+x11 window manager on windows. Works well but maybe slow

Can use NX: gives you all of your windows, which sucks

Can use xrdp with xrdp.xorg : Will need to use MATE, XFCE4, or LXDE
once the other wm manager has been installed, you will need to tell XRDP to use it. Then restart xrdp and maybe you are good to go.
TO tell it what to use: `echo xfce4-sesion >~/.xsession` which is used to determine which x server to launch, but maybe not used by lightdm?
To tell it to restart xrdp: `sudo service xrdp restart`
Follow these instructions here: https://github.com/neutrinolabs/xrdp/wiki/Compiling-and-using-xorgxrdp
