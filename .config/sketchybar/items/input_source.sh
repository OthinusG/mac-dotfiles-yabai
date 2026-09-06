#!/bin/bash

input_source=(
  icon.drawing=off
  label="?"
  label.font="SF Pro:Bold:13.0"
  label.color="$ACCENT_COLOR"
  label.padding_left=6
  label.padding_right=6
  padding_left=0
  padding_right=0
  background.drawing=off
  script="$PLUGIN_DIR/input_source.sh"
)

sketchybar --add item input_source right \
           --set input_source "${input_source[@]}" \
           --subscribe input_source input_source_changed
