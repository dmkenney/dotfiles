# Dotfiles

Arch Linux + i3 setup, applied with [`mise bootstrap`](https://mise.jdx.dev/bootstrap.html).

| File | What it holds |
|---|---|
| `mise/config.toml` | Packages (pacman + AUR), tools, dotfile links, services, hooks. Linked to `~/.config/mise/config.toml`. |
| `mise/machines/<host>.toml` | Per-machine packages (GPU driver, CPU microcode). Linked to `~/.config/mise/conf.d/machine.toml`. |
| `personal/mise.toml` | Private submodule: ssh, git, aws configs, sshd. Linked to `~/.config/mise/conf.d/personal.toml`. |

Daily use:

```sh
mise bootstrap status          # what differs from the config
mise bootstrap --dry-run       # preview
mise bootstrap                 # apply
mise dot add ~/.config/foo     # move a config into this repo and link it back
sudo pacman -Syu               # system upgrades (not `mise bootstrap packages upgrade`)
```

## New machine

1. Install Arch with archinstall: btrfs with the default subvolumes, GRUB, `linux` + `linux-lts`,
   user `dylan` in `wheel`, NetworkManager.
2. Base tools and yay:
   ```sh
   sudo pacman -S --needed git base-devel mise openssh
   git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && (cd /tmp/yay-bin && makepkg -si)
   ```
3. GitHub SSH access (the `personal` submodule is private): copy `~/.ssh` from the old machine,
   or install 1Password and enable its SSH agent. Check with `ssh -T git@github.com`.
4. Clone and link the mise config:
   ```sh
   git clone --recursive git@github.com:dmkenney/dotfiles.git ~/dotfiles
   mkdir -p ~/.config/mise/conf.d
   ln -sf ~/dotfiles/mise/config.toml ~/.config/mise/config.toml
   ln -sf ~/dotfiles/personal/mise.toml ~/.config/mise/conf.d/personal.toml
   ln -sf ~/dotfiles/mise/machines/<host>.toml ~/.config/mise/conf.d/machine.toml
   ```
   For a new host, copy a file in `mise/machines/` and adjust it.
5. Apply. Conflicting default files (`~/.zshrc`, `~/.config/i3/config`, ...) need `--force-dotfiles`:
   ```sh
   mise bootstrap --dry-run
   mise bootstrap --force-dotfiles
   chsh -s /usr/bin/zsh
   ```
6. Firewall: from the infrastructure repo, `environments/home/nftables/install-failsafe.sh`, then
   `apply.sh`. Update the interface name in its `nftables.conf` first (`ip -br link`).
7. Logins: `sudo tailscale up`, `netbird up`, 1Password, `gh auth login`, `aws sso login`,
   Claude Code (`curl -fsSL https://claude.ai/install.sh | bash`).
8. Brave profiles: `~/dotfiles/personal/brave/setup-profiles.sh` (overwrites profile settings, run once).
9. Copy data that is not in git: `~/.ssh`, `~/.claude`, Postgres databases, unpushed repos.
10. Reboot (new kernel modules, snapper, display manager).
