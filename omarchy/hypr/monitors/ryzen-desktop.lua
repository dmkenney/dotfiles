-- Ryzen desktop: one Samsung Odyssey G95NC (57" 7680x2160 ultrawide). Linked as
-- ~/.config/hypr/monitors.lua by mise/machines/ryzen-desktop.toml.
-- Super+1..0 all stay on this monitor (Omarchy's per-monitor workspaces).
--
-- The monitor reports 3840x1080@60 as its preferred mode, so name the native one.
-- 60Hz, not 120: at 120 the screen kept going black for a few seconds.
-- Scale 1.5 gives a 5120x1440 desktop. GDK_SCALE is the nearest whole number.

hl.env("GDK_SCALE", "2")
hl.monitor({ output = "desc:Samsung Electric Company Odyssey G95NC", mode = "7680x2160@60", position = "0x0", scale = 1.5 })
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })
