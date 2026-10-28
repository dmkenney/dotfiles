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
ln -sfn "$dotfiles/mise/addons.toml" "$conf/conf.d/addons.toml"

# Roles: a "# roles: laptop, work" line in the machine file links each
# mise/roles/<role>.toml as conf.d/role-<role>.toml. Links for dropped roles go.
roles=$(sed -n 's/^# roles:[[:space:]]*//p' "$machines/$machine.toml" | head -n1 | tr ',' ' ')
for link in "$conf"/conf.d/role-*.toml; do
  if [[ -L $link ]]; then
    rm -- "$link"
  fi
done
for role in $roles; do
  if [[ ! -f $dotfiles/mise/roles/$role.toml ]]; then
    echo "setup: $machine.toml names role '$role', but mise/roles/$role.toml doesn't exist" >&2
    exit 1
  fi
  ln -sfn "$dotfiles/mise/roles/$role.toml" "$conf/conf.d/role-$role.toml"
  echo "setup: role $role"
done

mise trust "$dotfiles/mise/config.toml"

# Omarchy's dev channel, from the dmkenney/omarchy fork's `local` branch (upstream
# PRs merged in). The Hyprland config here calls helpers only that branch has.
# Asks to confirm, upgrades every package, and needs a reboot to take effect.
channel=$( (source /etc/omarchy.conf 2>/dev/null; omarchy-channel-current) 2>/dev/null || true)
if [[ $channel != dev ]]; then
  [[ -d ~/omarchy/.git ]] || git clone --filter=blob:none -b local git@github.com:dmkenney/omarchy.git ~/omarchy
  git -C ~/omarchy remote get-url upstream &>/dev/null ||
    git -C ~/omarchy remote add upstream git@github.com:omacom/omarchy.git
  omarchy channel set dev
fi

# Read the recorded theme now. The bootstrap below runs sync-addons, which would
# otherwise record this machine's stock theme over it.
theme=$(cat "$dotfiles/omarchy/theme" 2>/dev/null || true)
export DOTFILES_SETUP=1

# --force-dotfiles replaces Omarchy's stock copies (~/.bashrc, ~/.config/hypr/*.lua,
# ~/.config/tmux/tmux.conf) with links into this repo. The stock versions stay in
# /usr/share/omarchy/config/ if they are ever needed.
mise bootstrap --force-dotfiles

# Apps Omarchy sets up beyond the package: browsers get its flags file, managed
# policy (theme color follows `omarchy theme set`) and copy-URL/yt-dlp hosts;
# 1Password gets its Chromium extension; sshd gets a rate-limited ufw rule and
# an authorized key. Each step is skipped once done, so re-runs stay quiet.
# brave-flags.conf is a link into this repo (desktops/omarchy.toml), so check the
# package. The installer copies Omarchy's stock flags through the link; keep ours.
if ! pacman -Q brave-bin &>/dev/null; then
  omarchy-install-browser brave
  git -C "$dotfiles" checkout -- omarchy/brave/brave-flags.conf
fi
[[ -f ~/.config/chrome-flags.conf ]] || omarchy-install-browser chrome
[[ -f ~/.config/environment.d/omarchy-firefox-wayland.conf ]] || omarchy-install-browser firefox
[[ -f /usr/share/chromium/extensions/aeblfdkhhhdcdjpifhhbdiojplfjncoa.json ]] || omarchy-install-service-1password
systemctl is-enabled --quiet sshd 2>/dev/null || omarchy-setup-security-sshd

# 1Password service account token, read once through the desktop app (one approval
# prompt). ~/.bashrc exports it as OP_SERVICE_ACCOUNT_TOKEN so `op` never prompts.
op_token=~/.config/op/service-account-token
if [[ ! -s $op_token ]]; then
  mkdir -p ~/.config/op
  if token=$(env -u OP_SERVICE_ACCOUNT_TOKEN op read --account fitnessbookinginc.1password.com \
      "op://K Squared Consulting/hmzoc4oce7bwwdi3htselgeg4y/credential") && [[ -n $token ]]; then
    (umask 077 && printf '%s' "$token" >"$op_token")
    echo "setup: saved 1Password service account token"
  else
    echo "setup: skipped 1Password service account token (sign in to the 1Password app, turn on CLI integration, re-run)" >&2
  fi
  unset token
fi

# NetBird mesh, with a setup key minted through the API (needs the token above).
if [[ -s $op_token ]]; then
  "$dotfiles/bin/netbird-enroll" || echo "setup: NetBird enrollment failed; rerun ~/dotfiles/bin/netbird-enroll" >&2
fi

if command -v hyprctl >/dev/null && hyprctl version >/dev/null 2>&1; then
  # The theme was cloned by the bootstrap (mise/addons.toml) if it isn't a stock one.
  if [[ -n $theme && $theme != "$(cat ~/.local/state/omarchy/current/theme.name 2>/dev/null)" ]]; then
    omarchy theme set "$theme"
  fi
  # Load plugins the bootstrap cloned.
  omarchy restart shell
  hyprctl reload >/dev/null
  hyprctl configerrors
fi
if [[ $channel != dev ]]; then
  echo "setup: done. Reboot to finish the switch to the dev channel."
else
  echo "setup: done. Open a new terminal to load ~/.bashrc."
fi
