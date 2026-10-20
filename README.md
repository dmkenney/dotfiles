# Dotfiles

Arch Linux setup (Omarchy, or i3 on older machines), applied with [`mise bootstrap`](https://mise.jdx.dev/bootstrap.html).

| File | What it holds |
|---|---|
| `mise/config.toml` | Packages (pacman + AUR), tools, dotfile links, services, hooks. Linked to `~/.config/mise/config.toml`. |
| `mise/machines/<machine>.toml` | Per-machine packages (GPU driver, CPU microcode) and, on Omarchy, the monitor layout (`omarchy/hypr/monitors/<machine>.lua`). A `# host:` line maps a hostname to the file. Linked to `~/.config/mise/conf.d/machine.toml`. |
| `mise/desktops/<i3\|omarchy>.toml` | Desktop: i3/X11 (archinstall, GRUB, lightdm, zsh, snapper setup) or Omarchy overrides (`omarchy/hypr/`, `omarchy/bash/.bashrc`, tmux). Linked to `~/.config/mise/conf.d/desktop.toml`. |
| `personal/mise.toml` | Private submodule: ssh, git, aws configs, sshd. Linked to `~/.config/mise/conf.d/personal.toml`. |

Daily use:

```sh
mise bootstrap status          # what differs from the config
mise bootstrap --dry-run       # preview
mise bootstrap                 # apply
mise dot add ~/.config/foo     # move a config into this repo and link it back
sudo pacman -Syu               # system upgrades (not `mise bootstrap packages upgrade`)
```

## New Omarchy machine

1. Install from the Omarchy ISO.
2. GitHub SSH access: copy `~/.ssh` from another machine, or sign in to 1Password and enable
   its SSH agent. Check with `ssh -T git@github.com`.
3. Put a `# host: <hostname>` line in the machine's file in `mise/machines/` (or pass the
   machine name to the script), then:
   ```sh
   git clone --recursive git@github.com:dmkenney/dotfiles.git ~/dotfiles
   ~/dotfiles/omarchy/setup.sh            # or: ~/dotfiles/omarchy/setup.sh laptop
   ```
   It links mise to this repo (Omarchy's `mise use -g` pins move to the untracked
   `~/.config/mise/conf.d/local-tools.toml`) and runs `mise bootstrap --force-dotfiles`.
   Safe to re-run.
4. Logins and data: steps 7 and 9 below. Printer (optional): step 10.

Omarchy updates replace `/usr/share/omarchy` only; the files here are thin overrides loaded
after Omarchy's defaults. After `omarchy update`, `git status` here and `mise bootstrap status`
show anything an Omarchy migration changed. `omarchy refresh <x>` replaces a file on purpose.

### Omarchy plugins, themes and roles

- Plugins and themes installed from git (`omarchy plugin add`, `omarchy theme install`) are recorded in `mise/addons.toml` by `omarchy/bin/sync-addons` (deleting one drops its entry), and `mise bootstrap` clones them on every Omarchy machine. The current theme goes to `omarchy/theme`, which `setup.sh` applies. The script runs on theme change, after `omarchy update`, and at the start of `mise bootstrap`; commit what `git status` shows.
- Roles limit things to some machines: a `# roles: laptop` line in `mise/machines/<machine>.toml` makes `setup.sh` link `mise/roles/laptop.toml`. Move an add-on's line from `addons.toml` into a role file to keep it off other machines. Rerun `setup.sh` after changing a machine's roles.

## New i3 machine

1. Install the base system, one of:
   - **i3:** archinstall with btrfs (default subvolumes), GRUB, `linux` + `linux-lts`,
     user `dylan` in `wheel`, NetworkManager.
   - **Omarchy:** the Omarchy ISO (UEFI, limine, btrfs + snapper, Hyprland).
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
   ln -sf ~/dotfiles/mise/desktops/<i3|omarchy>.toml ~/.config/mise/conf.d/desktop.toml
   ```
   For a new host, copy a file in `mise/machines/` and adjust it.
5. Apply. Conflicting default files (`~/.zshrc`, `~/.config/i3/config`, ...) need `--force-dotfiles`:
   ```sh
   mise bootstrap --dry-run
   mise bootstrap --force-dotfiles
   chsh -s /usr/bin/zsh
   ```
6. Firewall:
   - **i3:** from the infrastructure repo, `environments/home/nftables/install-failsafe.sh`, then
     `apply.sh`. Update the interface name in its `nftables.conf` first (`ip -br link`).
   - **Omarchy:** nothing to do. `mise bootstrap` runs `personal/system/ufw-rules.sh`, the ufw
     version of the same rules. Check with `sudo ufw status verbose`.
7. Logins: `netbird up`, 1Password, `gh auth login`, `aws sso login`,
   Claude Code (`curl -fsSL https://claude.ai/install.sh | bash`).
8. Brave profiles: `~/dotfiles/personal/brave/setup-profiles.sh` (overwrites profile settings, run once).
9. Copy data that is not in git from the old machine (it must be on and reachable over SSH):
   ```sh
   copy-from-old-machine <old-host>   # or name parts: brave claude documents tmux home postgres
   ```
   Copies Brave profiles plus the keyring key that decrypts their cookies and passwords,
   `~/.claude`, `~/Documents` (projects; same paths, so Claude history still matches),
   tmux-resurrect saves (restore with prefix + Ctrl-r), CLI logins,
   app data (DBeaver, Zen, Cursor, ...), claude-squad/flow2 worktrees, and
   all Postgres databases (dump kept in `~/backups`). Copying Brave replaces step 8.
   Not covered: unpushed repos outside `~/Documents`.
10. Optional, at home: `~/dotfiles/bin/setup-printer` adds the Lexmark CX331adwe and makes
    it the default printer.
11. Reboot (new kernel modules, snapper, display manager).
12. On Omarchy, keybindings keep the i3 layout on top of Omarchy's; see
    `omarchy/hypr/bindings.lua`. Super+F1 lists them all.
