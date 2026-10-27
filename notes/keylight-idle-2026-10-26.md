# The Key Light kept the desk awake (2026-10-26)

After the Brave workaround (`brave-idle-inhibit-2026-10-22.md`) the screensaver,
lock and monitor-off still never fired. The Omarchy shell's idle monitor had not
gone idle once in over a day.

## Result

- The Elgato Key Light Air MK.2's USB HID interface also registers as a
  keyboard (`elgato-key-light-air-mk.2`, KEY_UNKNOWN). Every reply to a
  `keylight` request arrives as a key event, and Hyprland counts it as
  activity. The bar widget reads the light every 2 minutes while its panel is
  closed (`refreshIntervalSec` 30 x 4), so idle reset every 2 minutes.
- Fix: `ENV{LIBINPUT_IGNORE_DEVICE}="1"` for the light's input device in
  keylight-usb's `70-elgato-keylight.rules` (dmkenney/keylight-usb `2a721cc`),
  installed in `/etc/udev/rules.d/`. Hyprland no longer lists the device; the
  `keylight` command still works over hidraw. Confirmed: the screensaver and
  lock fire again with nothing else changed.
- `hl.device({ name = "elgato-key-light-air-mk.2", enabled = false })` in
  `input.lua` also works. Not kept, since the udev rule covers it.
- Anyone who installed the rules file before `2a721cc` has to reinstall it.

## Still open

- The shell's screensaver and lock start over a playing video in a normal
  Brave window. Brave sends its "Video Wake Lock" only over D-Bus, which only
  hypridle honors; the shell's `IdleMonitor` only honors Wayland inhibitors.
  Monitor-off still waits for the video. Left as is.
- Brave is still on Chromium 156 (1.98.60); the bogus Wayland inhibitor from
  the 2026-10-22 note is still there until 157.

## How it was found

- A throwaway `hypridle -c` with a short timeout and `on-timeout`/`on-resume`
  that append `date` to a file shows exactly when the compositor sees
  activity. With hands off, resumes came every 120 s on the same second.
- Ruled out: window events (socket2 was silent), cursor movement
  (`hyprctl cursorpos` unchanged), Wayland and systemd inhibitors (none held).
- Reading `/dev/hidraw0` (user-readable through the `uaccess` rule) showed the
  widget's state read landing on each 2-minute mark. A manual `keylight state`
  then reset idle within a second, twice.
- To make libinput drop the device without replugging:
  `udevadm trigger --action=remove` then `--action=add` on
  `/sys/class/input/eventN`. A `change` event sets the udev property but
  Hyprland keeps the device.

## Things learned on the way

- hypridle logs D-Bus inhibits and lock/unlock, but not when its listeners
  fire. `hyprctl -j monitors` `dpmsStatus` shows whether the display is off.
- The Omarchy shell logs every idle step to the user journal:
  `journalctl --user | grep 'omarchy idle'`. `omarchy-shell idle status`
  gives the live state.
- `hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'` is the right Lua
  syntax on Hyprland 0.56.2; an unknown action still returns `ok`.
