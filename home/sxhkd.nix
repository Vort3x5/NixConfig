{ layout ? "colemak", ... }:

let
  layoutKeys = {
    qwerty = {
      left = "h";
      down = "j"; 
      up = "k";
      right = "l";
    };
    
    colemak = {
      left = "m";
      down = "n";
      up = "e";
      right = "i";
    };
  };
  
  keys = layoutKeys.${layout} or layoutKeys.colemak;
in
{
  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + Escape" = "pkill -USR1 -x sxhkd";
      
      "super + a" = "rofi -show run";
      "super + b" = "firefox";
      "super + d" = "discord";
      "super + p" = "flameshot gui";
      "super + s" = "steam";
      "super + t" = "alacritty";
      
      "super + c" = "bspc node -{c,k}";
      "super + g" = "bspc node -s biggest.window";
      "super + ctrl + space" = "bspc node -p cancel";
      
      "super + ${keys.left}" = "bspc node -f west";
      "super + ${keys.down}" = "bspc node -f south";
      "super + ${keys.up}" = "bspc node -f north";
      "super + ${keys.right}" = "bspc node -f east";
      
      "super + shift + ${keys.left}" = "bspc node -s west";
      "super + shift + ${keys.down}" = "bspc node -s south";
      "super + shift + ${keys.up}" = "bspc node -s north";
      "super + shift + ${keys.right}" = "bspc node -s east";
      
      "super + alt + ${keys.left}" = "bspc node -z left -20 0";
      "super + alt + ${keys.down}" = "bspc node -z bottom 0 20";
      "super + alt + ${keys.up}" = "bspc node -z top 0 -20";
      "super + alt + ${keys.right}" = "bspc node -z right 20 0";
      
      "super + alt + shift + ${keys.left}" = "bspc node -z right -20 0";
      "super + alt + shift + ${keys.down}" = "bspc node -z top 0 20";
      "super + alt + shift + ${keys.up}" = "bspc node -z bottom 0 -20";
      "super + alt + shift + ${keys.right}" = "bspc node -z left 20 0";
      
      "super + ctrl + ${keys.left}" = "bspc node -p west";
      "super + ctrl + ${keys.down}" = "bspc node -p south";
      "super + ctrl + ${keys.up}" = "bspc node -p north";
      "super + ctrl + ${keys.right}" = "bspc node -p east";
      
      "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";
      
      "super + Tab" = "bspc node -f next.local.!hidden.window";
      "super + shift + Tab" = "bspc node -f prev.local.!hidden.window";
      
      "super + {1-9,0}" = "bspc desktop -f '^{1-9,10}'";
      "super + shift + {1-9,0}" = "bspc node -d '^{1-9,10}'";
      
      "super + q" = "bspc quit";
      "super + r" = "bspc wm -r";
      
      "super + alt + t" = "bspc node -t tiled";
      "super + alt + p" = "bspc node -t pseudo_tiled";
      "super + shift + s" = "bspc node -t floating";
      "super + f" = "bspc node -t fullscreen";
    };
  };
}
