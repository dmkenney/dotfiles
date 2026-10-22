# Elgato Key Light Air MK.2 over USB (2026-10-21)

Reverse engineered Elgato Control Center's USB control and published a Linux
CLI and an Omarchy bar widget for the light, with no Wi-Fi.

## Result

- [dmkenney/keylight-usb](https://github.com/dmkenney/keylight-usb): `keylight`,
  a stdlib-only Python CLI, plus the udev rule and PROTOCOL.md.
  Checked out at `~/Projects/keylight-usb`; `~/.local/bin/keylight` links to it.
- [dmkenney/omarchy-keylight-usb](https://github.com/dmkenney/omarchy-keylight-usb):
  bar widget `io.github.dmkenney.keylight-usb`. `~/.config/omarchy/plugins/` links
  to `~/Projects/omarchy-keylight-usb`.
- Udev rule installed at `/etc/udev/rules.d/70-elgato-keylight.rules`.
- Marketplace submission: omacom/omarchy-plugin-marketplace#12546. Validation
  passed; the security baseline wants a maintainer to review the `sudo` lines
  in the README (udev rule install). Waiting on a maintainer.

## How the light talks

- No Linux tool controlled it over USB; all of them use Wi-Fi. The MK.2 over
  Wi-Fi also needs mutual TLS with keys from Control Center.
- Control Center 1.9.1 for Windows is .NET, so ilspycmd decompiled it nearly
  to source (`ControlCenter.Helper.Communication.Usb`).
- Over USB it is HID (VID 0fd9, PID 00bc, report ID 2, 512-byte reports). It
  takes the network API's requests as text (`PUT /elgato/lights {json}`), split
  into packets. No TLS or pairing. Details in PROTOCOL.md.
- Bluetooth is only for Wi-Fi setup and Elgato's remote, not control.
- Control Center's limits, now copied: brightness 3 up to the power cap,
  temperature in mireds (143-344) with kelvin labels, fades 0-2 s.
- The light ignores a `lights/settings` PUT missing any of its six keys.

## Things found on the way

- **60% cap.** The PC's USB-C ports offer 5 V / 3 A, so the light reports
  `maximumBrightness` 60. A PD brick gives 100% but then there is no USB data
  link, so control would need Wi-Fi. Front and back ports are the same.
- **First plug-in failed to enumerate.** Kernel saw a high-speed device but no
  descriptors; unplug and replug fixed it.
- **hidraw copies replies to every open fd.** Two `keylight` processes read
  each other's answers. Fixed by taking the lock before opening the device.
- **Shell plugin edits did not load.** A plugin folder symlinked from
  `~/Projects` is not hot-reloaded; only `omarchy restart shell` loads new QML.
  Dylan tested an old build for an hour because of this.
- **Disconnects at 20:05, 20:13 and 20:57** were Dylan switching the light off
  by hand, not the code.

## Reviews

Two adversarial reviews (a Claude agent, then Codex on the fixed code) found
25 issues, none high. All fixed: watch-sleep surviving a re-enumerating light,
orphaned gdbus children, lock timeouts and one lock path per user, one sleep
watcher per user, stale state reads, a Dropdown binding break, and others.

## Other desktop fixes this session

- Webcam launcher mirrors the picture (`--vf=hflip`).
- Workspaces: the Samsung was on block 3 (31-40) because the state file
  remembered two old Dells and FALLBACK. Reset
  `~/.local/state/omarchy/monitor-workspaces` to the Samsung on block 0 and
  renumbered open workspaces to 1-10 (backup next to it).
- Shell restarts jumped to workspace 10: Spotify asks for activation on every
  shell start and Omarchy's global `focus_on_activate` followed it. Turned off
  for Spotify in `omarchy/hypr/hyprland.lua`.
- Bar label for workspace 10 now says 10: clone `dylan.workspaces`.
- Display panel has a 1.5 scale preset: clone `dylan.monitor`. Scale is 1.5.
- The nille Elgato plugin was tried, removed, and UFW port 5353 closed again.

## Not checked

- A real suspend with the sleep setting on.
- Clicking the power-on dropdown and sliders, Rename and Blink in the panel
  (the CLI commands behind them are tested).
- Any light other than this one Key Light Air MK.2 on firmware 1.1.8.
