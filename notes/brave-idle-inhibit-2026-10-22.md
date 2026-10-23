# Brave kept the monitors on (2026-10-22)

The screensaver, lock and monitor-off stopped firing. Hyprland showed a Brave
window with `inhibitingIdle: true`. The cause is a Chromium bug, not a tab.

## Result

- Chromium bug [570067499](https://issues.chromium.org/issues/570067499):
  `PowerSaveBlocker` on Linux suspended the screensaver for every wake lock
  type, including `kPreventAppSuspension`, the "keep the system awake, let the
  display sleep" lock any tab takes for audio-only playback, WebRTC or a
  download. On Wayland that creates a `zwp_idle_inhibitor_v1` on the focused
  window. Fixed on main 2026-10-07, commit `4dd9a00`. In Chromium 157 (stable
  2026-11-03), not 156. Brave Release, Beta and Nightly were all on 156.
- Workaround: `ignore_wayland_inhibit = true` in `hypridle.conf` (commit
  `2c9aba9`). Monitor-off works again. hypridle still honors Chromium's D-Bus
  locks, so real video still holds the display on. Roll back once
  `brave --version` is 157 or later.
- Still blocked until then: the shell's screensaver (150 s) and lock (300 s).
  Its `IdleMonitor` hardcodes `respectInhibitors: true`
  (`shell/plugins/services/idle/Service.qml:274`).
- Posted the root cause on omacom/omarchy#5092 and anthropics/claude-code#99362.
  Same bug hits Cursor and Claude Desktop (Electron `prevent-app-suspension`).

## How it was found

- Brave's real display locks (video, Screen Wake Lock API) also go over D-Bus
  to hypridle, which logs them: `journalctl --user -u hypridle | grep
  'ScreenSaver inhibit'` shows "Video Wake Lock" / "Blink Wake Lock" with
  timestamps. The Wayland flag was on for long stretches with no D-Bus entry,
  which ruled out every page-level lock.
- Chromium's commit history for `power_save_blocker_linux.cc` had the fix with
  the full explanation in its message.
- Confirmed on Brave 1.97.59 (Chromium 155): 6 s of quiet audio in a fresh
  window, no video, no wake lock. `inhibitingIdle` went true, hypridle logged
  nothing, cleared a few seconds after the audio ended.

## Things learned on the way

- **The window title is misleading.** The inhibitor lands on whichever
  Chromium window has keyboard focus when the lock starts and stays there
  until release. Switching tabs, blank tabs and closing tabs cannot move it.
- **Hyprland rules cannot veto a client inhibitor.** On 0.56.2
  `recheckIdleInhibitorStatus()` returns on the first protocol inhibitor
  before window rules run, and `isWindowInhibiting()` only adds
  (`src/managers/input/IdleInhibitor.cpp`). The `idle_inhibit = "none"` rule
  suggested on the Omarchy issue does nothing.
- **Brave over CDP.** Launch `brave --remote-debugging-port=9222` and
  `curl 127.0.0.1:9222/json` lists every tab with its URL; Node 22+ has a
  built-in `WebSocket` for `Runtime.evaluate`. `Page.setWebLifecycleState
  {state: "frozen"}` releases a page's Screen Wake Lock (checked), so freezing
  tabs one by one finds a page-level holder without closing anything.
- **Hyprland Lua dispatch.** `hyprctl dispatch 'hl.dsp.focus({ window =
  "address:0x..." })'`; the old `focuswindow` syntax errors.
- `brave://media-internals` player entries named `N:M` use the renderer client
  id; `pgrep -f -- '--renderer-client-id=N'` maps them to a process.
- `basecamp/omarchy` redirects to `omacom/omarchy`.
