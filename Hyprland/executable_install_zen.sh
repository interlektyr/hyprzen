#sudo pacman -Syu --needed gum

pmpkg=(
  "egl-wayland"
  "grim"
  "hyprland"
  "hyprpolkitagent"
  "qt5-wayland"
  "qt6-wayland"
  "noto-fonts"
  "xdg-desktop-portal-hyprland"
  "xdg-desktop-portal-gtk"
  "xdg-utils"
  "smartmontools"
  "wireplumber"
  "udisks2"
  "udiskie"
  "uwsm"
  "hyprpicker"
  "wl-clipboard"
  "mako"
  "gum"
  "git"
  "wget"
  "grim"
  "slurp"
  "kitty"
  "networkmanager"
  "transmission-cli"
  "wireless_tools"
  "nano"
  "vim"
  "neovide"
  "bottom"
  "imv"
  "yazi"
  "ffmpeg"
  "7zip"
  "jq"
  "poppler"
  "fd"
  "ripgrep"
  "zoxide"
  "resvg"
  "imagemagick"
  "ouch"
  "qt6-5compat"
  "quickshell"
  "hyprshot"
  "sddm"
  "awww"
)

parpkg=(
  "hyprshutdown"
  "rose-pine-hyprcursor"
  "tremc"
  "tufw"
  "zen-browser-bin"
  "selectdefaultapplication-git"
  "dragon-drop"
  "asusctl"
  "hyprmoncfg"
  "rog-control-center"
)

case $(gum choose --header="What is your base OS?" "CachyOS" "Vanilla Arch" "Quit") in
"CachyOS")
  CO="yes"
  ;;
"Vanilla Arch")
  CO="no"
  ;;
"Quit")
  exit
  ;;
esac

case $(gum choose --header="What kind of computer do you have?" "ASUS Laptop" "Other Laptop" "Stationary" "Quit") in
"ASUS Laptop")
  ComT="ASUS"
  ;;
"Other Laptop")
  ComT="L"
  ;;
"Stationary")
  ComT="S"
  ;;
"Quit")
  exit
  ;;
esac

#You need to create the file /etc/asusd/ manually
#You need to set Throttle Policy for power state to Balanced for both on Battery och on AC

# if not on CachyOS:
# install paru
# install rate-mirrors
# install arch-update
# install starship (copy starship-conf)

# sudo pacman -Syu --needed ${pmpkg[@]}
paru -S --needed ${parpkg[@]}

# ya pkg add ndtoan96/ouch

# ya pkg add stelcodes/bunny

# ya pkg add uhs-robert/recycle-bin

# sudo curl -sL $(curl -s https://api.github.com/repos/5hubham5ingh/WallRizz/releases/latest | grep -Po '"browser_download_url": "\K[^"]+' | grep WallRizz) | tar -xz && sudo mv WallRizz /usr/bin/
