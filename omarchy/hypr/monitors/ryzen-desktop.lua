-- Ryzen desktop: 1080p monitors side by side, no scaling. Linked as
-- ~/.config/hypr/monitors.lua by mise/machines/ryzen-desktop.toml.
-- Workspaces like i3: 1-6 on the primary monitor, 7-10 on the second one,
-- whichever port it is plugged into. With one monitor, all ten stay on the primary.
local primary = "HDMI-A-1"
local split = 6

hl.env("GDK_SCALE", "1")
hl.monitor({ output = primary, mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })

local function place_workspaces()
  local second
  for _, m in ipairs(hl.get_monitors()) do
    if m.name ~= primary then second = m.name end
  end

  for ws = 1, 10 do
    local name = tostring(ws)
    local monitor = (ws > split and second) or primary
    -- Calling workspace_rule again for a workspace replaces its rule.
    local default = ws == 1 or (ws == split + 1 and second ~= nil)
    hl.workspace_rule({ workspace = name, monitor = monitor, default = default })
    if hl.get_workspace(name) then
      hl.dispatch(hl.dsp.workspace.move({ workspace = name, monitor = monitor }))
    end
  end

  -- A newly plugged-in monitor opens on a fresh workspace (11+). Show 7 there instead,
  -- then give focus back to the monitor that had it.
  if second then
    local active = hl.get_active_workspace(second)
    if not (active and active.id > split and active.id <= 10) then
      local focused = hl.get_active_monitor()
      hl.dispatch(hl.dsp.focus({ workspace = tostring(split + 1) }))
      if focused then hl.dispatch(hl.dsp.focus({ monitor = focused.name })) end
    end
  end
end

place_workspaces()
hl.on("hyprland.start", place_workspaces)
hl.on("monitor.added", place_workspaces)
hl.on("monitor.removed", place_workspaces)
