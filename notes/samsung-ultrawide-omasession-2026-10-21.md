# Samsung 57" ultrawide and OmaSession (2026-10-21)

Set up the Samsung Odyssey G95NC (7680x2160) as the only monitor, added custom
Lua layouts, and forked OmaSession so a login brings the desktop back as it was.

## Monitor

- `omarchy/hypr/monitors/ryzen-desktop.lua`: matched by description,
  7680x2160@60, scale 1.5, `GDK_SCALE=2`. Super+1..0 are all on it.
- **DisplayPort blacks out** at 120Hz on the RTX 5070 Ti (driver 615.78, DP 2.1
  link). A new cable did not help. Running on HDMI at 60Hz, no flicker.
- **Mouse lag:** mostly fixed by turning on Adaptive-Sync in the monitor's menu.
  Also the hardware cursor (`no_hardware_cursors = 0`) and speed 0.46 through
  the mouse-settings plugin (`omarchy/hypr/input.lua`). A raw event test showed
  the wireless receiver dropping reports; a front port helped a little.

## Layouts and bindings

- `omarchy/hypr/layouts.lua`: Lua layouts center (30%), center-40, columns,
  thirds, grid, spiral, stack, main-dwindle. Default is `lua:center`.
- Super+Alt+L cycles them plus master, dwindle and scrolling
  (`bin/workspace-layout-toggle`); Shift goes back. Quick presses are serialized.
- Resize mode (Super+R) shows a notice; any other key leaves it. In Lua layouts
  H/L grow or shrink the layout's split. Being stuck in resize mode was why
  Super seemed dead.
- Shift+Print: screenshot of the focused window to the clipboard, with a 10s
  omasnap preview, nothing saved (`bin/screenshot-active-window`).
- Webcam desktop entry: mpv 1920x1080 MJPEG.

## OmaSession fork

[dmkenney/omasession](https://github.com/dmkenney/omasession), branch `dylan`
(the fork's default), checked out at `~/Projects/omasession` and installed as
`brenoperucchi.omasession`. Five commits on upstream 0.4.1:

1. Windows come back in their slots on Lua layouts. `layouts.lua` exports
   `window_slot_order()`; restore parks windows on a hidden workspace, then
   places them in order.
2. Terminals relaunch the program they ran (`terminalPrograms=flockr,herdr,btop`).
   flockr resumes its Claude agents with their saved flags.
3. Every Brave profile and app window (X, web apps) comes back, not only
   Default. Tested: 3/3 in 8s, against 1/3 in 42s before.
4. History of `last` (every change for 15 min, then per 15 min, hour, day, up to
   a week) and `omasession list`.
5. Panel tabs: Layout (screens drawn to scale) and Saved (Save as, history,
   Preview, Restore).

A "hold a smaller save until the next tick" guard was built and dropped as too
fragile; history covers that case.

Two adversarial review rounds (Claude agent and Codex each time) found real
bugs, all fixed: a named restore racing the timer save, windows left hidden
after a killed restore, unchecked profile names, programs matched to the wrong
terminal, and others. Upstream PR: brenoperucchi/omasession#5. The old commit
history is on `backup/dylan-before-cleanup`.

Named layouts are backed up to `personal/omasession/<machine>/` by
`bin/omasession-layouts` (timer every 15 min, commits and pushes the private
repo). Each machine has its own folder; `omasession-layouts restore <machine>`
copies in the missing ones.

## Things found on the way

- **A test closed every real window.** A nested-Hyprland test ran against the
  real session after a reboot wiped its `/tmp` harness. Recovered from Brave's
  session backups. Test scripts now assert they target the nested instance.
- **All Brave logins vanished once.** The Safe Storage key was only in the
  keyring's memory. See the memory note on the Brave keyring.
- **Restore order is the layout's, not open order.** Hyprland's client list
  keeps creation order after a swap, so the slot order has to come from the
  layout.

## Not done

- A real logout/login test of the restore.
- omasnap preview windows can get saved and relaunched; no delete for named
  layouts.
- Wallpapers: B3 (calm edges) is set; the other nine Higgsfield variants are
  undecided, and `test-*` files are left in `backgrounds/event-horizon/`.
- DisplayPort 120Hz and the mouse receiver dropouts.
