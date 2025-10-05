#!/bin/sh

systemctl --user set-environment DISPLAY="$DISPLAY"
systemctl --user set-environment PATH="/run/current-system/sw/bin:$PATH"

# Set Polish keyboard layout for X11
setxkbmap pl -option ""

# NVIDIA settings
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

picom -f --backend glx &
feh --bg-fill --randomize /etc/nixos/home/misc/Wallps
sxhkd -m 1 &
unclutter --start-hidden --timeout=1 &
exec bspwm
