#!/bin/bash
# Set up an Omarchy machine from this repo. Run after the Omarchy ISO install, once
# GitHub SSH access works and the repo is cloned to ~/dotfiles:
#
#   ~/dotfiles/omarchy/setup.sh [machine]
#
# [machine] names mise/machines/<machine>.toml. Without it, the file whose
# "# host:" line matches this hostname is used. Safe to re-run.
set -euo pipefail

dotfiles=~/dotfiles
machines=$dotfiles/mise/machines

machine=${1:-}
if [[ -z $machine ]]; then
  match=$(grep -lx "# host: $(hostname)" "$machines"/*.toml | head -n1 || true)
  [[ -n $match ]] && machine=$(basename "$match" .toml)
fi
if [[ -z $machine || ! -f $machines/$machine.toml ]]; then
  echo "No machine file for host '$(hostname)'. Pass one of:" >&2
  ls "$machines" | sed 's/\.toml$//; s/^/  /' >&2
  echo "or add a '# host: $(hostname)' line to the right file." >&2
  exit 1
fi
echo "setup: machine $machine"

# personal/ is a private submodule with ssh, git and aws configs.
git -C "$dotfiles" submodule update --init --recursive

# Omarchy creates its own ~/.config/mise/config.toml (`mise use -g`). Keep its tool
# pins in the untracked per-machine file our config sends `mise use -g` to.
conf=~/.config/mise
mkdir -p "$conf/conf.d"
if [[ -f $conf/config.toml && ! -L $conf/config.toml ]]; then
  if [[ -e $conf/conf.d/local-tools.toml ]]; then
    mv "$conf/config.toml" "$conf/config.toml.omarchy-$(date +%Y%m%d%H%M%S)"
  else
    mv "$conf/config.toml" "$conf/conf.d/local-tools.toml"
  fi
fi
ln -sfn "$dotfiles/mise/config.toml" "$conf/config.toml"
ln -sfn "$dotfiles/mise/desktops/omarchy.toml" "$conf/conf.d/desktop.toml"
ln -sfn "$machines/$machine.toml" "$conf/conf.d/machine.toml"
ln -sfn "$dotfiles/personal/mise.toml" "$conf/conf.d/personal.toml"
mise trust "$dotfiles/mise/config.toml"

# --force-dotfiles replaces Omarchy's stock copies (~/.bashrc, ~/.config/hypr/*.lua,
# ~/.config/tmux/tmux.conf) with links into this repo. The stock versions stay in
# /usr/share/omarchy/config/ if they are ever needed.
mise bootstrap --force-dotfiles

if command -v hyprctl >/dev/null && hyprctl version >/dev/null 2>&1; then
  hyprctl reload >/dev/null
  hyprctl configerrors
fi
echo "setup: done. Open a new terminal to load ~/.bashrc."
