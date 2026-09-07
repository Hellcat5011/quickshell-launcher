#!/bin/bash
COVER="/tmp/eww_cover.jpg"

playerctl metadata mpris:artUrl --follow | while read -r url; do
  if [[ -z "$url" ]]; then
    echo ""
  elif [[ "$url" == http* ]]; then
    curl -s "$url" -o "$COVER"
    echo "$COVER"
  elif [[ "$url" == file://* ]]; then
    echo "${url#file://}"
  else
    echo "$url"
  fi
done
