#!/bin/sh
# Called by on-window-detected when a Whisky / wine window lands in workspace G.
# Keeps only the newest Whisky/wine window visible in G and minimizes the rest,
# so launching a game (or any follow-up window) tucks the original one away.
#
# Window IDs are allocated in increasing order, so the highest ID is the window
# that was just opened. Minimized windows drop out of `list-windows`, so already
# minimized windows are never touched again.

sleep 0.3  # let AeroSpace finish moving the new window into G

ids=$(aerospace list-windows --workspace G --format '%{window-id}|%{app-bundle-id}|%{app-name}' 2>/dev/null |
    awk -F'|' '$2 == "com.franke.Whisky" || $3 ~ /^wine/ { print $1 }' | sort -n)

newest=$(printf '%s\n' "$ids" | tail -n 1)
[ -z "$newest" ] && exit 0

for id in $ids; do
    [ "$id" = "$newest" ] && continue
    aerospace macos-native-minimize --window-id "$id" 2>/dev/null
done
