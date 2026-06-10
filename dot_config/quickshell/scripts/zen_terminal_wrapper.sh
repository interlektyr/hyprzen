#!/bin/bash

terminalOpt=$1
cmString=$2
cmStringArg=$3

get_connections() {

  # Initiera variabler
  wifi="disconnected"
  ssid=""
  ethernet="disconnected"
  wireguard="disconnected"

  # Läs av nmcli i "terse"-format (enhet:typ:status:anslutning)
  while IFS=: read -r dev type state conn; do
    case "$type" in
    "wifi")
      wifi="$state"
      if [ "$state" = "connected" ]; then
        ssid="$conn"
      fi
      ;;
    "ethernet")
      # Om du har flera ethernet-portar sparar vi den som faktiskt är igång
      if [ "$state" = "connected" ] || [ "$ethernet" != "connected" ]; then
        ethernet="$state"
      fi
      ;;
    "wireguard")
      if [ "$state" = "connected" ] || [ "$wireguard" != "connected" ]; then
        wireguard="$state"
      fi
      ;;
    esac
  done < <(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device)

  # Returnera som ett rent JSON-objekt för QML
  cat <<EOF
{
  "wifi": "$wifi",
  "ssid": "$ssid",
  "ethernet": "$ethernet",
  "wireguard": "$wireguard"
}
EOF

}

#COMMANDS FOR APPCOMMANDER

if [[ $terminalOpt == "kitty" ]]; then

  if [[ $cmString == "zen_mirrors" ]]; then

    kitty --title yazi -e ~/.config/quickshell/scripts/zen_power_menu_wrapper.sh mirrors
    exit

  fi

  kitty --title yazi -e $cmString $cmStringArg

fi

#COMMANDS FOR POWER-MENU

if [[ $terminalOpt == "shutdown" ]]; then

  #hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'
  shutdown -P 0

fi

if [[ $terminalOpt == "exit" ]]; then

  #hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'
  #hyprctl dispatch exit
  hyprctl dispatch 'hl.dsp.exit()'

fi

if [[ $terminalOpt == "reboot" ]]; then

  #hyprshutdown -t 'Restarting...' --post-cmd 'reboot'
  reboot

fi

if [[ $terminalOpt == "firmware" ]]; then

  #hyprshutdown -t 'Restarting...' --post-cmd 'systemctl reboot --firmware-setup'
  systemctl reboot --firmware-setup

fi

#COMMANDS FOR WORKSPACE-WIDGET (UNTIL I FIX USINGLUA-STRANGNESS)

if [[ $terminalOpt == "wc_next" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "+1" }))'

fi

if [[ $terminalOpt == "wc_prev" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "-1" }))'

fi

if [[ $terminalOpt == "wc_1" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "1" }))'

fi

if [[ $terminalOpt == "wc_2" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "2" }))'

fi

if [[ $terminalOpt == "wc_3" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "3" }))'

fi

if [[ $terminalOpt == "wc_4" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "4" }))'

fi

if [[ $terminalOpt == "wc_5" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "5" }))'

fi

if [[ $terminalOpt == "wc_6" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "6" }))'

fi

if [[ $terminalOpt == "wc_7" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "7" }))'

fi

if [[ $terminalOpt == "wc_8" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "8" }))'

fi

if [[ $terminalOpt == "wc_9" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "9" }))'

fi

if [[ $terminalOpt == "wc_10" ]]; then

  hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "10" }))'

fi

# COMMANDS FOR STASHER

if [[ $terminalOpt == "stasher" ]]; then

  activ_ws=$(hyprctl activeworkspace | grep 'workspace' | awk '{print $3}')

  hyprctl dispatch "hl.dsp.window.move({ workspace = \"$activ_ws\", window = \"address:$cmString\" })"

fi

# COMMANDS FOR NOTIFICATION WIDGET

if [[ $terminalOpt == "toggledonotdisturbon" ]]; then

  notify-send "Do not disturb: on" "The notification widget has been set to do not disturb. Notifications will not pop up on screen when sent, but they are still saved to history."

fi

if [[ $terminalOpt == "toggledonotdisturboff" ]]; then

  notify-send "Do not disturb: off" "The do not disturb-mode has been toggled off. Notifications will pop up on screen when emitted."

fi

# COMMANDS FOR CONNECTION WIDGET

if [[ $terminalOpt == "getconnections" ]]; then

  get_connections

fi
