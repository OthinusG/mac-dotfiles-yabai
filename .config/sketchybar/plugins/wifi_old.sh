#!/bin/bash

WIFI_DEVICE=$(/usr/sbin/networksetup -listallhardwareports \
  | awk '/Hardware Port: (Wi-Fi|AirPort)/ {getline; print $2; exit}')

if [[ -n "$WIFI_DEVICE" ]] \
  && /usr/sbin/ipconfig getsummary "$WIFI_DEVICE" 2>/dev/null \
    | grep -q ' SSID : '; then
  ICON="󰖩"
else
  ICON="󰖪"
fi

sketchybar --set "$NAME" icon="$ICON"
