#!/usr/bin/env bash
ID="$1"
DIR="/tmp/quickshell-cliphist"
mkdir -p "$DIR"
OUT="$DIR/$ID.png"

if [ ! -f "$OUT" ]; then
    cliphist decode "$ID" > "$OUT"
fi

echo "$OUT"
