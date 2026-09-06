#!/bin/bash

case "${LANGUAGE:-unknown}" in
  zh*) label="中" ;;
  en*) label="英" ;;
  ja*) label="日" ;;
  ko*) label="韩" ;;
  unknown|"") label="?" ;;
  *) label="${LANGUAGE%%-*}" ;;
esac

sketchybar --set "$NAME" label="$label"
