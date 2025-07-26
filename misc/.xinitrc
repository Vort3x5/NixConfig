#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
	xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
	xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
	xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
	xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi
#
systemctl --user set-environment DISPLAY="$DISPLAY"
systemctl --user set-environment PATH="/run/current-system/sw/bin:$PATH"

# Set Polish keyboard layout for X11
setxkbmap pl -option compose:ralt

# NVIDIA settings
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

picom -f --backend glx &
emacs --daemon &
feh --bg-fill --randomize ~/Desktop/Wallps
sxhkd -m 1 &
unclutter --start-hidden --timeout=1 &
exec bspwm
