#!/bin/bash

gum style \
  --foreground 212 --border-foreground 212 --border double \
  --align center --width 50 --margin "1 2" --padding "2 4" \
  'zenctrl'

gum choose "update system" "dynamic wallpapers" "terminal emulator" "clock widget" "notifications"
