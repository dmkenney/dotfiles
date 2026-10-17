-- Two 1080p monitors side by side, no scaling. Workspaces pinned like i3:
-- 1-6 on the left monitor, 7-10 on the right.
-- Get output names with `hyprctl monitors all` and fill them in.
-- The right monitor is not connected yet; "DP-1" is a placeholder.
local left = "HDMI-A-1"
local right = "DP-1"

hl.env("GDK_SCALE", "1")
hl.monitor({ output = left, mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = right, mode = "preferred", position = "1920x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

for ws = 1, 10 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = ws <= 6 and left or right, default = (ws == 1 or ws == 7) })
end
