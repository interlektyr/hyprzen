#!/bin/bash

systemOpt=$1

if [[ $systemOpt == "mirrors" ]]; then

  sudo cachyos-rate-mirrors
  clear

  case $(gum choose --header="Mirrors updated! Run cachy-update?" "Yes" "No") in
  "Yes")
    cachy-update
    ;;
  "No")
    exit
    ;;
  esac

fi
