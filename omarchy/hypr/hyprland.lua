-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Dropdown terminal (Super+grave, hypr/dropdown.sh): top half of the screen.
o.window("dropdown", {
  workspace = "special:dropdown",
  float = true,
  size = { "monitor_w", "(monitor_h/2)" },
  move = { 0, 0 },
})

-- Smart borders, like i3's smart_borders: no border on a tiled window that is
-- alone on its workspace, so it sits flush against the bar.
-- hl.window_rule({
--   name = "smart-borders",
--   match = { float = false, workspace = "w[tv1]" },
--   border_size = 0,
-- })
