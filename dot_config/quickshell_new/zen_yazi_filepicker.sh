#!/bin/bash

activ_ws=$(hyprctl activeworkspace | grep 'workspace' | awk '{print $3}')

#hyprctl clients -j | jq -r --arg WORKSPACE "$activ_ws" 'map(select(.workspace.id == ($WORKSPACE|tonumber)))' | grep "class" | awk '{print $2}' | sed 's|[",]||g'

check_here=$(hyprctl clients -j | jq -r --arg WORKSPACE "$activ_ws" 'map(select(.workspace.id == ($WORKSPACE|tonumber)))' | grep "yazi_filepicker")

if [[ -z $check_here ]]; then
  echo "yazi_filepicker is not on the current focused ws, check if it is somewhere else or not launched at all"

  somewhere_else=$(hyprctl clients | grep 'yazi_filepicker')

  if [[ -z $somewhere_else ]]; then

    echo "The yazi_filepicker is not launched, launch it"

    hyprctl dispatch "hl.dsp.exec_cmd(\"kitty --title yazi_filepicker -e yazi\")"

  else

    echo "The yazi_filepicker is on a nother ws, send it to the current focused ws"

    hyprctl dispatch "hl.dsp.window.move({ workspace = \"$activ_ws\", window = \"title:yazi_filepicker\" })"

  fi

else
  echo "yazi_filepicker is on the current focued wc, send it to the Stasher"

  hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:stash\", follow = false })"
fi
