#!/usr/bin/env bash

#bat_path=$(cat /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)

#if [ -d "$bat_path" ] && [ -f "$bat_path/capacity" ]; then
#  bat_name=$(basename "$bat_path")
#  capacity=$(cat "$bat_path/capacity")
#  echo "Battery found: $bat_name"
#else
#  echo "No battery found"
#  exit 1
#fi

bat_path=$(echo "/sys/class/power_supply/BAT"*)

if [ -d $bat_path ]; then
  echo "Yes. Battery"
  echo "$(basename $bat_path)"
else
  echo "No. No battery"
fi
