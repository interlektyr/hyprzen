#!/bin/bash

terminalOpt=$1
cmString=$2
cmStringArg=$3

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
