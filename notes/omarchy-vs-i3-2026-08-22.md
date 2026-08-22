# Omarchy vs current i3 desktop — UX diff (2026-08-22)

Scope: Dylan's desktop (ASRock Z370, i7-8700K, GTX 960, 2x1080p) running Arch +
i3/X11, compared against Omarchy 4.0 "Quattro" (released 2026-08-14; `version`
file still says 4.0.0.alpha). Omarchy 3.8.5 differences noted where relevant.
Sources: this repo, live system, `basecamp/omarchy` repo (branch `quattro`
and `master`) and its in-repo manual.

## Current setup

- i3-wm 4.x on X11, lightdm, picom (inactive opacity 0.95, no fade/shadow/rounding),
  1px borders + `smart_borders`, no gaps, feh wallpaper, unclutter.
- Caps Lock remapped to Super_L via `~/.Xmodmap`.
- Launcher: dmenu (`Super+D`). Bar: i3bar + i3status (wifi, eth, CPU temp, disk,
  load, memory, clock). No notification daemon running. No clipboard manager.
  No idle auto-lock (xss-lock only locks on suspend). Flameshot screenshots.
- Terminal: alacritty (running) + ghostty config; CaskaydiaCove Nerd Font Mono 10,
  TokyoNight, no decorations. Shell: zsh + powerlevel10k. tmux prefix `C-Space`,
  vi copy mode, tmuxifier, resurrect, TokyoNight status.
- nvim: custom kickstart-style config, TokyoNight, `<Space>` leader, LazyVim-style
  window/buffer/tab maps, harpoon, telescope, neo-tree, oil, dap, neotest.
- Browser: Brave with 5 named profiles (1Password + Vimium extensions synced).
- GTK: Adwaita-dark, Cantarell 11.
- Workspaces 1-6 pinned to HDMI-0, 7-10 to DVI-I-0 (both 1920x1080, side by side).
- Disk: LUKS + btrfs (`@` subvolume), grub, **BIOS/CSM boot (not UEFI)**,
  zram swap. Installed 2024-06-07 via archinstall.
- GPU driver: `nvidia-470xx-dkms` (installed 2026-01-12 when `nvidia` moved
  to 590 and dropped Maxwell). 470xx is the wrong legacy branch for a GTX 960:
  Maxwell is supported by `nvidia-580xx-dkms`, and only >=495 has GBM, which
  Hyprland requires.

## Hard blockers before Omarchy (or any Hyprland) is even possible

1. **Driver.** 470xx has no GBM; wlroots/Hyprland will not start on it. Fix is
   independent of Omarchy and worth doing anyway: replace `nvidia-470xx-*` with
   `nvidia-580xx-dkms` + `nvidia-580xx-utils` (AUR). Alternative: move the
   monitors to the i7-8700K's UHD 630 iGPU and run Hyprland on Intel, which is
   the most trouble-free Wayland path; keep the 960 idle or for CUDA.
2. **Install model.** Omarchy 4.0 is ISO-only. `boot.sh` (install onto existing
   Arch) was removed. Even 3.x's guard script demanded vanilla Arch + limine +
   btrfs + no existing DE. Practically: Omarchy = wipe and reinstall.
3. **Firmware.** Omarchy ISO uses limine + UKI and assumes UEFI. The Z370 board
   supports UEFI but is currently booting CSM/legacy. A reinstall would mean
   switching the firmware to UEFI mode and repartitioning (GPT + ESP). LUKS +
   btrfs already match Omarchy's defaults.
4. **Freshness.** 4.0 shipped eight days ago and replaced waybar/walker/mako/
   hyprlock/hypridle with a single Quickshell "Omarchy shell" and moved Hyprland
   config to Lua. Expect churn; 3.8.5 is the settled release.

## Keybinding diff (the part that matters most)

Hyprland has no i3 container tree: no stacking/tabbed layouts, no "focus
parent", no split-direction pre-selection. Dwindle auto-splits; groups (`Super+G`)
are the tabbed substitute.

| Action | i3 (current) | Omarchy 4.0 | Notes |
|---|---|---|---|
| Modifier | Super (Caps Lock = Super via Xmodmap) | Super; Caps Lock = Compose (`compose:caps,shift:both_capslock_cancel`) | Set `kb_options = caps:super` in `~/.config/hypr/input.lua`; lose Omarchy's compose/emoji sequences |
| Terminal | `Super+Return` | `Super+Return` (xdg-terminal-exec, opens in cwd of focused terminal) | Same |
| Close window | `Super+Shift+Q` | `Super+W`, `Super+Q` | `Super+Shift+Q` is free in Omarchy; add it |
| Launcher | `Super+D` dmenu | `Super+Space` Omarchy menu (includes apps), `Super+Alt+Space` apps | `Super+D` is free (`Super+Shift+D` = lazydocker) |
| Focus | `Super+H/J/K/L` + arrows | `Super+arrows` only | Omarchy uses `Super+J` togglesplit, `Super+K` cheatsheet, `Super+L` dwindle/scrolling toggle; `Super+H` free. Must unbind J/K/L |
| Move window | `Super+Shift+H/J/K/L` + arrows | `Super+Shift+arrows` | `Super+Shift+H/J/K/L` free in Omarchy |
| Workspaces | `Super+1..0`, `Super+Shift+1..0` | Same, plus `Super+Shift+Alt+N` move silently | Same. Pin per monitor in `monitors.lua` (`workspace = 1, monitor:HDMI-A-1`) |
| Back-and-forth | `Super+Tab` | `Super+Ctrl+Tab` (`Super+Tab` = next workspace) | Conflict |
| Fullscreen | `Super+F` | `Super+F`; `Super+Ctrl+F` fullscreen-in-tile; `Super+Alt+F` maximize | Same |
| Float toggle | `Super+Shift+Space` | `Super+T` (`Super+Shift+Space` = toggle bar) | Conflict |
| Focus float/tile | `Super+Space` | n/a (`Super+Space` = menu) | Conflict |
| Split h / v | `Super+C` / `Super+V` | **`Super+C`/`Super+V`/`Super+X` = universal copy/paste/cut**; `Super+J` togglesplit | Direct conflict with Omarchy's signature feature; dwindle auto-splits so you mostly don't need it |
| Stacking / tabbed / toggle split | `Super+S` / `Super+W` / `Super+E` | `Super+S` scratchpad, `Super+W` close, `Super+E` free; tabbed = groups `Super+G` | Real loss if tabbed is used |
| Focus parent | `Super+A` | none | No equivalent |
| Resize | `Super+R` mode, hjkl | `Super+minus/equal` (x), `Super+Shift+minus/equal` (y), `Super+RMB` drag | `Super+R` free; Hyprland submaps can recreate the mode |
| Reload / restart / exit | `Super+Shift+C` / `Super+Shift+R` / `Super+Shift+E` | auto-reload; `Super+Escape` system menu; `Super+Shift+C` = HEY calendar, `Super+Shift+E` = HEY mail | Webapp binds disabled with `omarchy_preinstalled_bindings=false` |
| Screenshot | `Print` full, `Super+Print` region (flameshot) | `Print` smart region/window/monitor (grim+slurp, freeze, annotator); `Super+Print` color picker; `Alt+Print` record; `Super+Ctrl+Print` OCR | `Super+Print` conflict |
| Media | XF86 keys; `XF86Launch5/6` Spotify prev/next | XF86 keys; `Alt+Play`/`Alt+Shift+Play` next/prev | Playerctl via shell IPC |
| Lock | none (xss-lock on suspend) | `Super+Ctrl+L`; idle screensaver 150s, lock 300s | Gain |
| Clipboard history | none | `Super+Ctrl+V` | Gain |
| Emoji | none | `Super+Ctrl+E` | Gain |
| Cheatsheet | none | `Super+K` (generated from live binds) | Gain |
| Scratchpad / pop window | none | `Super+S` drop-down console, `Super+O` pop | Gain |
| Apps | none | `Super+Shift+Return/B` browser, `Super+Shift+F` files, `Super+Shift+N` editor, `Super+Shift+M` Spotify, `Super+Shift+/` 1Password, `Super+Alt+Return` tmux, … | Opinionated; all overridable |

Override mechanics (4.0): `~/.config/hypr/bindings.lua` loads after defaults;
`hl.unbind("SUPER + J")` then `o.bind(...)`. Setting
`omarchy_default_bindings = false` in `hyprland.lua` before
`require("default.hypr.omarchy")` drops every default and you bring your own.
Defaults improve on `omarchy update` without touching user files (user files are
thin overrides that `require` the defaults).

Minimum override set to keep current muscle memory:

- `caps:super` in input.
- Unbind `Super+J/K/L`; bind `Super+H/J/K/L` movefocus, `Super+Shift+H/J/K/L`
  movewindow.
- `Super+Shift+Q` killactive, `Super+D` apps menu, `Super+Tab` previous
  workspace, `Super+Shift+Space` togglefloating (rebind bar toggle), `Super+R`
  resize submap.
- Decide on `Super+C/V`: keep Omarchy copy/paste (and drop split binds) or
  rebind them to splits and lose universal clipboard.
- `omarchy_preinstalled_bindings = false` to drop webapp/app hotkeys.

## Look and feel

| | current | Omarchy 4.0 |
|---|---|---|
| Gaps | 0 | in 5 / out 10 (`Super+Shift+Backspace` toggles off) |
| Border | 1px, smart_borders | 2px, gradient active, grey inactive, rounding 0 |
| Opacity | inactive 0.95 (picom) | all windows 0.985 active / 0.96 inactive, browsers 1.0/0.985 (`Super+Backspace` toggles) |
| Shadow / blur | off | off in 4.0 (3.x: on) |
| Animations | none | on (easeOutQuint, popin; workspace animation off) |
| Theme | TokyoNight hand-applied in alacritty/tmux/nvim | tokyo-night default; 22 themes, one switch re-themes terminal, btop, nvim, chromium, obsidian, vscode, shell, wallpaper, boot unlock screen, keyboard RGB |
| Font | CaskaydiaCove NF Mono 10 (terminal), 12 (i3 titles) | JetBrainsMono NF 9, padding 14; Style > Font menu |
| Scale | 1x | assumes 2x (`GDK_SCALE=2`, `monitor=,preferred,auto,auto`); set scale 1 in `monitors.lua` for 2x1080p |
| Cursor | unclutter hides | `hide_on_key_press`, 24px |
| Workspaces | 10, pinned 1-6 / 7-10 per monitor | global 1-10, bar shows 1-5 persistent + occupied; per-workspace dwindle/scrolling layout persisted |
| Bar | i3status: wifi, eth, CPU temp, disk, load, memory, clock | shell bar: menu, workspaces, clock, weather, updates, tray, agents, bluetooth, network, audio, display, power. No CPU/memory/temp module by default; `Super+Ctrl+T` opens btop |
| Notifications | none | shell notifications + DND + history |
| Lock / idle | i3lock on suspend only | screensaver 150s, lock 300s, `Super+Ctrl+L` |
| Display manager | lightdm | sddm + plymouth |

## Terminal, shell, tmux, editor

- Terminal: Omarchy 4.0 defaults to foot (3.x alacritty); alacritty/ghostty/kitty
  installable from the menu and ship themed configs (JetBrainsMono 9, padding 14,
  Ctrl/Shift+Insert copy/paste, theme include from
  `~/.local/state/omarchy/current/theme/`). Your alacritty.toml and ghostty
  config carry over with font swapped and colors replaced by the theme include.
- Shell: Omarchy is bash + starship + zoxide + fzf + mise, with a large alias/
  function set (`default/bash/*`). zsh is not shipped but `chsh` to zsh works;
  you keep p10k and lose Omarchy's bash aliases/functions unless ported. Theme
  switching does not depend on the shell.
- tmux: Omarchy's config also uses prefix `C-Space` and vi copy mode; adds
  `Alt+Enter` splits, `Alt+1-9` windows. Your tmuxifier/resurrect setup is
  orthogonal and would carry over.
- nvim: Omarchy ships LazyVim (`omarchy-nvim`). Your config is already
  LazyVim-flavoured but custom; keep it. Theme switching writes a `neovim.lua`
  you can ignore or source.
- AI agents: Omarchy treats claude/codex/opencode as first-class (default agent,
  scratchpad seeded with agent, `Super+Shift+Ctrl+A`, bar usage panel, shipped
  Claude skill). Your dotfiles already centralize AGENTS.md; compatible.
- Browser: Omarchy defaults to plain Chromium; Brave is an install option and
  can be the default browser. Webapps are Chromium `--app` windows.
- 1Password: auto-installs on `Super+Shift+/`; SSH agent socket works on Wayland.

## What Omarchy adds that the current setup lacks

Notification daemon, clipboard history, idle lock, emoji picker, screen
recording, OCR, color picker, nightlight, drop-down scratchpad, window pop,
keybind cheatsheet, universal Super+C/V, system-wide theme switching, LocalSend
share menu, snapper snapshot before every update with limine rollback, ufw
default-deny, reminders, webapp launcher, monitor scale cycling, hooks
(`~/.config/omarchy/hooks/<event>.d`).

## What the current setup has that Omarchy lacks or breaks

i3 tabbed/stacking layouts and container tree (`focus parent`), `Super+C/V`
as splits, flameshot (X11; grim+slurp+annotator replaces), xrandr layout scripts
(replaced by `monitors.lua`), nvidia-settings, lightdm, zsh as the shipped
shell, i3status CPU-temp/disk/memory glanceables in the bar, X11 in general
(XWayland covers most apps; `xwayland force_zero_scaling` set).

## Paths

A. **Full Omarchy (ISO).** Wipe, switch firmware to UEFI, reinstall, restore
   `~/dotfiles`, apply the override set above. Biggest change, cleanest result,
   highest risk given 4.0's age. Do it on a spare SSD first.
B. **Hyprland without Omarchy.** Fix the driver (580xx or iGPU), install
   `hyprland` alongside i3, pick it from lightdm, port the i3 bindings, borrow
   Omarchy's theme files/configs piecemeal. Keeps the box, lets you test
   Wayland on this GPU before committing. Recommended first step.
C. **Stay on i3, steal the UX.** dunst, cliphist-equivalent (greenclip/
   clipmenu), rofi with emoji, xss-lock + xidlehook for idle lock, a theme
   switch script. No reinstall, no driver change.

Regardless of path: replace `nvidia-470xx` with `nvidia-580xx-dkms`. 470 is
Kepler's branch; Maxwell has a newer supported one.
