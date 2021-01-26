#!/bin/sh
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <2>}]"
gsettings set org.gnome.desktop.interface scaling-factor 2
xrandr --output USB-C-0 --off --output HDMI-0 --mode 1600x900 --scale 2x2 --pos 0x0 --rotate left --output DP-5 --mode 1920x1080 --scale 2x2 --pos 6600x764 --rotate normal --output DP-4 --off --output DP-3 --mode 1920x1080 --pos 6600x764 --scale 2x2 --rotate normal --output DP-2 --off --output DP-1 --off --output DP-0 --primary --mode 3840x2160 --scale 1.25x1.25 --pos 1800x324 --rotate normal
