-- i3 muscle memory on top of Omarchy's defaults. See all bindings: Super+F1 or Super+Shift+Ctrl+K.
-- Unchanged from Omarchy (already match i3): Super+Return, Super+F, Super+arrows,
-- Super+comma notification keys. Super+1..0 are per monitor; a machine's monitors.lua
-- may map them across monitors i3-style.

-- Focus and move with H/J/K/L. Omarchy uses J (split), K (help), L (layout).
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
o.bind("SUPER + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Move window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Move window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + F1", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + SHIFT + CTRL + K", "Keybindings", "omarchy-menu-keybindings")

-- Split direction (i3 Super+C/V). Super+C/V stay Omarchy's universal copy/paste.
o.bind("SUPER + E", "Toggle window split", hl.dsp.layout("togglesplit"))

-- Window basics
o.bind("SUPER + SHIFT + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + D", "Apps menu", "omarchy-menu toggle apps")
hl.unbind("SUPER + SHIFT + SPACE")
o.bind("SUPER + SHIFT + SPACE", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

-- Super+Tab: previous workspace (i3 back_and_forth). Omarchy uses it for "next".
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))

-- Resize mode (i3 Super+R)
o.bind("SUPER + R", "Resize mode", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  local step = 40
  for _, k in ipairs({ { "h", -step, 0 }, { "l", step, 0 }, { "k", 0, -step }, { "j", 0, step },
                       { "left", -step, 0 }, { "right", step, 0 }, { "up", 0, -step }, { "down", 0, step } }) do
    hl.bind(k[1], hl.dsp.window.resize({ x = k[2], y = k[3], relative = true }), { repeating = true })
  end
  hl.bind("return", hl.dsp.submap("reset"))
  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("SUPER + R", hl.dsp.submap("reset"))
end)

-- Session (i3 Super+Shift+E exit). Config reloads automatically on save.
-- Replaces Omarchy's HEY email webapp binding.
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "System menu", "omarchy-menu toggle system")

-- Screenshots like i3: Print = full screen, Super+Print = region.
-- Omarchy's color picker moves to Super+Shift+Print.
hl.unbind("PRINT")
hl.unbind("SUPER + PRINT")
o.bind("PRINT", "Screenshot full screen", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + PRINT", "Screenshot region", "omarchy-capture-screenshot region")
o.bind("SUPER + SHIFT + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")

-- File manager: Yazi (vim keys, image/video previews) instead of Nautilus.
hl.unbind("SUPER + SHIFT + F")
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { tui = "yazi" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", "omarchy-launch-terminal yazi")

-- Spotify keys on the keyboard. Play toggles Spotify, or launches it and starts playing.
hl.unbind("XF86AudioPlay")
o.bind("XF86AudioPlay", "Spotify play/pause",
  "playerctl --player=spotify play-pause 2>/dev/null || { spotify & for i in $(seq 40); do sleep 0.5; playerctl --player=spotify status >/dev/null 2>&1 && break; done; sleep 1; playerctl --player=spotify play; }",
  { locked = true })
o.bind("XF86Launch5", "Spotify previous", "playerctl --player=spotify previous")
o.bind("XF86Launch6", "Spotify next", "playerctl --player=spotify next")

-- Bar panels by letter (Super+Ctrl+1..9 also open them, but by bar position).
o.bind("SUPER + CTRL + ALT + P", "Proton VPN", { panel = "io.github.grichard99.omaproton-vpn" })
o.bind("SUPER + CTRL + ALT + N", "NetBird", { panel = "mikebenner.netbird" })
o.bind("SUPER + CTRL + ALT + O", "Pigeon notifications", { panel = "xyzlab.pigeon" })
o.bind("SUPER + CTRL + ALT + H", "Bluetooth", { panel = "omarchy.bluetooth" })
o.bind("SUPER + CTRL + ALT + I", "Internet", { panel = "omarchy.network" })
o.bind("SUPER + CTRL + ALT + S", "Sound", { panel = "omarchy.audio" })
o.bind("SUPER + CTRL + ALT + A", "Agents", { panel = "omarchy.agents" })
o.bind("SUPER + CTRL + ALT + M", "Hardware monitor", { panel = "meviusisback.hw-monitor" })
o.bind("SUPER + CTRL + ALT + Y", "Syncthing", { panel = "io.github.ilyazar.syncthing" })

-- Voxtype meeting transcript; press again to stop (see bin/meeting-toggle).
o.bind("SUPER + CTRL + M", "Meeting transcript", "meeting-toggle")
o.bind("SUPER + CTRL + SHIFT + M", "Meeting transcript + screen recording", "meeting-toggle --screen")

-- Flockr instead of Herdr (was: omarchy-launch-terminal-herdr).
o.rebind("SUPER + CTRL + RETURN", "Flockr", "omarchy-launch-terminal flockr")
