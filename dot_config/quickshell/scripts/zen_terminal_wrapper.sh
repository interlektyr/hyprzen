#!/bin/bash

terminalOpt=$1
cmString=$2
cmStringArg=$3

get_connections() {

  # Initiera variabler
  wifi="disconnected"
  ssid=""
  wifi_ip=""
  eto=""
  ethernet="disconnected"
  ethernet_ip=""
  wireguard="DISABLED"
  wireguard_location=""
  wireguard_ip=""
  access="ONLINE"
  fw="DOWN"
  torrent_server="NOT RUNNING"
  torrent_downloading="false"
  torrent_seeding="false"
  bluetooth_power="OFF"
  bluetooth_devices="[]"

  if bluetoothctl show | grep -q "Powered: yes"; then
    bluetooth_power="ON"

    device_list=$(bluetoothctl devices Connected | cut -d' ' -f3- | sed 's/"/\\"/g' | awk '{print "\""$0"\""}' | paste -sd, -)

    if [ -n "$device_list" ]; then
      bluetooth_devices="[$device_list]"
    fi
  fi

  if pgrep -x "transmission-da" >/dev/null; then
    torrent_server="RUNNING"
    summary=$(transmission-remote -l 2>/dev/null | tail -n 1)
    if [ -n "$summary" ]; then
      all_torrents=$(transmission-remote -l 2>/dev/null)
      if echo "$all_torrents" | grep -q "Downloading"; then
        torrent_downloading="true"
      fi
      up_speed=$(echo "$summary" | awk '{print $(NF-3)}')
      down_speed=$(echo "$summary" | awk '{print $(NF-2)}')
      if [ "$down_speed" != "0.0" ] && [ "$down_speed" != "None" ]; then
        torrent_downloading="true"
      fi
      if [ "$up_speed" != "0.0" ] && [ "$up_speed" != "None" ]; then
        torrent_seeding="true"
      fi
    fi
  fi

  if [ "$(cat /etc/ufw/ufw.conf | grep ENABLED=yes)" = "ENABLED=yes" ]; then
    fw="UP"
  fi

  # Läs av nmcli i "terse"-format (enhet:typ:status:anslutning)
  while IFS=: read -r dev type state conn; do
    current_ip=$(ip -4 addr show dev "$dev" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
    #clean_ip="${ip%/*}"

    case "$type" in
    "wifi")
      wifi="$state"
      if [ "$state" = "connected" ]; then
        ssid="$conn"
        wifi_ip="$current_ip"
      fi
      ;;
    "ethernet")
      # Om du har flera ethernet-portar sparar vi den som faktiskt är igång
      if [ "$state" = "connected" ] || [ "$ethernet" != "connected" ]; then
        ethernet="$state"
        if [ "$ethernet" = "connected" ]; then
          eto="$conn"
          ethernet_ip="$current_ip"
        fi
      fi
      ;;
    "wireguard")
      if [ "$state" = "connected" ] || [ "$wireguard" != "connected" ]; then
        wireguard="ENABLED"
      fi
      ;;
    esac
  done < <(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device)

  if [ "$ethernet" = "disconnected" ] && [ "$wifi" = "disconnected" ]; then
    access="OFFLINE"
  fi

  if [ "$wireguard" = "ENABLED" ]; then
    wireguard_location="$(mullvad status | awk '/Visible location: / {print $3 $4}')"
    wireguard_ip="$(mullvad status | awk '/Visible location: / {print $6}')"
  fi

  # Returnera som ett rent JSON-objekt för QML
  cat <<EOF
{
  "access": "$access",
  "wifi": "$wifi",
  "ssid": "$ssid",
  "wifi_ip": "$wifi_ip",
  "eto": "$eto",
  "ethernet": "$ethernet",
  "ethernet_ip": "$ethernet_ip",
  "wireguard": "$wireguard",
  "wireguard_location": "$wireguard_location",
  "wireguard_ip": "$wireguard_ip",
  "fw": "$fw",
  "torrent_server": "$torrent_server",
  "torrent_downloading": "$torrent_downloading",
  "torrent_seeding": "$torrent_seeding",
  "bluetooth_power": "$bluetooth_power",
  "bluetooth_devices": $bluetooth_devices
}
EOF

}

#COMMANDS FOR APPCOMMANDER

if [[ $terminalOpt == "kitty" ]]; then

  if [[ $cmString == "zen_mirrors" ]]; then

    kitty --title yazi -e ~/.config/quickshell/scripts/zen_power_menu_wrapper.sh mirrors
    exit

  fi

  if [[ $cmString == "zen_connection_launch" ]]; then

    case $cmStringArg in
    0)
      kitty --title yazi -e nmtui
      ;;
    1)
      kitty --title yazi -e sudo tufw
      ;;
    2)
      mullvad-vpn
      ;;
    3)
      kitty --title yazi -e bluetui
      ;;
    esac
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
