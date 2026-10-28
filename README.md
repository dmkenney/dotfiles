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

1. Install from the Omarchy ISO. No Wi-Fi option joins a hidden network; use a cable or
   `nmcli connection add type wifi con-name <name> ssid <ssid> wifi.hidden yes wifi-sec.key-mgmt wpa-psk wifi-sec.psk <password>`.
2. GitHub SSH access: `omarchy-install-service-1password`, sign in, then in 1Password turn on
   Settings → Developer → Use the SSH agent and Integrate with 1Password CLI. Check with
   `ssh -T git@github.com`.
3. Put a `# host: <hostname>` line and the CPU's microcode package in the machine's file in
   `mise/machines/` (or pass the machine name to the script), then:
   ```sh
   git clone --recursive git@github.com:dmkenney/dotfiles.git ~/dotfiles
   ~/dotfiles/omarchy/setup.sh            # or: ~/dotfiles/omarchy/setup.sh laptop
   ```
   It switches Omarchy to the dev channel (clones the `local` branch of dmkenney/omarchy to
   `~/omarchy`; asks to confirm), links mise to this repo (Omarchy's `mise use -g` pins move
   to the untracked `~/.config/mise/conf.d/local-tools.toml`), runs
   `mise bootstrap --force-dotfiles`, installs the browsers, saves the 1Password service
   account token and joins NetBird (`bin/netbird-enroll`). Safe to re-run. Reboot after the
   first run.
4. Data from the old machine (it must be on and reachable over SSH; close Brave on both):
   ```sh
   copy-from-old-machine <old-host>
   ```
   See step 9 below for what it copies. It also logs in the GitHub CLI with the old
   machine's token. Printer (optional): step 10.

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
7. Logins: `~/dotfiles/bin/netbird-enroll` (or `netbird up` to log in by browser), 1Password.
   Claude Code: `curl -fsSL https://claude.ai/install.sh | bash` (Omarchy installs it already).
8. Brave profiles: `~/dotfiles/personal/brave/setup-profiles.sh` (overwrites profile settings, run once).
9. Copy data that is not in git from the old machine (it must be on and reachable over SSH):
   ```sh
   copy-from-old-machine <old-host>   # or name parts: brave claude documents projects tmux home gh postgres
   ```
   Copies Brave profiles plus the keyring key that decrypts their cookies and passwords
   (close Brave on both machines first), `~/.claude` and `~/.claude.json`, `~/Documents` and
   `~/Projects` (same paths, so Claude history still matches; build folders such as
   `node_modules`, `target`, `_build`, `deps` and `.venv` are skipped), tmux-resurrect saves
   (restore with prefix + Ctrl-r), CLI logins including the GitHub CLI, app data (DBeaver,
   Zen, Cursor, ...), claude-squad/flow2 worktrees, and Postgres databases (dumps kept in
   `~/backups`). Copying Brave replaces step 8. To leave things out:
   ```sh
   COPY_EXCLUDE=/projects/ksquared-marketing/video-studio/ copy-from-old-machine <old-host> documents
   PG_DBS='^brightsite_' copy-from-old-machine <old-host> postgres
   ```
   Not covered: unpushed repos outside `~/Documents` and `~/Projects`.
10. Optional, at home: `~/dotfiles/bin/setup-printer` adds the Lexmark CX331adwe and makes
    it the default printer.
11. Reboot (new kernel modules, snapper, display manager).
12. On Omarchy, keybindings keep the i3 layout on top of Omarchy's; see
    `omarchy/hypr/bindings.lua`. Super+F1 lists them all.
