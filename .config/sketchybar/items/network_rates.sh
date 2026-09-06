#!/bin/bash

source "$CONFIG_DIR/settings.sh"

if is_dark_mode; then
    ICON_COLOR=$ACCENT_COLOR
else
    ICON_COLOR=$BACKGROUND
fi

down=(
    icon=􁾯
    icon.color=$ICON_COLOR
    icon.padding_right=5
    script="$PLUGIN_DIR/network_rates.sh"
    update_freq=10
)
sketchybar \
    --add item net_down right \
    --set net_down "${down[@]}"
