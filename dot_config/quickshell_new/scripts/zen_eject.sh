#!/bin/bash

gum spin --spinner pulse --title "Syncing..." --show-output -- sync

truncate -s 0 /tmp/ejectlist.txt

if [ -z "$(ls /run/media/$(whoami)/)" ]; then
  echo "No mounted devices/filesystems fond in path /run/media/$(whoami)/"
  sleep 2
  exit
fi

for unit in $(ls -1 /run/media/$(whoami)/); do
  echo $unit >>/tmp/ejectlist.txt
done

echo "Cancel" >>/tmp/ejectlist.txt

sel=$(gum filter --header "Eject external devices mounted on /run/media/$(whoami)/" </tmp/ejectlist.txt)

if [ "$sel" = "Cancel" ]; then
  exit
else
  gum confirm && sudo umount /run/media/$(whoami)/$sel || exit
fi
