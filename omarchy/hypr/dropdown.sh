#!/bin/sh
# Toggle the dropdown terminal; relaunch it if the window is gone.
# Hyprland port of ~/dotfiles/i3/dropdown.sh, bound to Super+grave in bindings.lua.
# The window rule in hyprland.lua puts app-id "dropdown" on special:dropdown, top half.
# tmux session "scratch" starts in ~ with claude (yolo alias) in window 1.
if hyprctl clients -j | jq -e 'any(.[]; .class == "dropdown")' >/dev/null; then
  exec hyprctl dispatch 'hl.dsp.workspace.toggle_special("dropdown")'
fi
tmux has-session -t scratch 2>/dev/null \
  || tmux new-session -d -s scratch -c ~ \; send-keys -t scratch 'yolo' C-m
exec foot --app-id=dropdown tmux attach -t scratch
