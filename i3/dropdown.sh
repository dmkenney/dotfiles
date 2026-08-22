#!/bin/sh
# Toggle the dropdown scratchpad terminal; relaunch it if the window is gone.
# Bound to $mod+grave and run at i3 startup (~/dotfiles/i3/config).
# tmux session "scratch" starts in ~ with claude (yolo alias) in window 1.
i3-msg '[instance="dropdown"] scratchpad show' >/dev/null 2>&1 && exit 0
tmux has-session -t scratch 2>/dev/null \
  || tmux new-session -d -s scratch -c ~ \; send-keys -t scratch 'yolo' C-m
exec alacritty --class Alacritty,dropdown -e tmux attach -t scratch
