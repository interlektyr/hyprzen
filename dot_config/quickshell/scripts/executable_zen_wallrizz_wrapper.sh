#!/bin/bash

FILE="/home/kristian/.config/quickshell/scripts/settings.json"
WS_NUM="1"

WallRizz -e -n -d /home/kristian/.config/quickshell/assets/wallpapers/

#echo "$newImg"

newImg="$(awww query | awk '{ print $9; }')"

jq --arg id "$WS_NUM" --arg path "$newImg" \
  '.[$id].img = $path' "$FILE" >tmp.json && mv tmp.json "$FILE"
