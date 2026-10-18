-- Ryzen desktop: 1080p monitors side by side, no scaling. Linked as
-- ~/.config/hypr/monitors.lua by mise/machines/ryzen-desktop.toml.
-- Workspaces like i3: Super+1..6 on the primary monitor, Super+7..0 on the second
-- one, whichever port it is plugged into. With one monitor, all ten are on the primary.
--
-- Omarchy gives each monitor its own workspaces 1-10 (ids 1-10 on the primary,
-- 11-20 on the second; see default/hypr/monitor-workspaces.lua), so Super+7 is
-- slot 7 of the second monitor, workspace 17.
local primary = "HDMI-A-1"
local split = 6

hl.env("GDK_SCALE", "1")
hl.monitor({ output = primary, mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })

local function second_monitor()
  -- pairs, not ipairs: the keybindings menu (omarchy-menu-keybindings) runs this file
  -- against a stub hl whose results never end an ipairs loop, which hung the menu.
  for _, m in pairs(hl.get_monitors()) do
    if m.name ~= primary then return m.name end
  end
end

-- The monitor and slot a workspace key goes to.
local function target(key)
  local second = second_monitor()
  if key > split and second then
    return second, key
  end
  return primary, key
end

for key = 1, 10 do
  local code = "code:" .. (key + 9)

  hl.unbind("SUPER + " .. code)
  hl.bind("SUPER + " .. code, function()
    local monitor, slot = target(key)
    o.workspaces.focus(slot, monitor)()
  end, { description = "Switch to workspace " .. key })

  hl.unbind("SUPER + SHIFT + " .. code)
  hl.bind("SUPER + SHIFT + " .. code, function()
    local monitor, slot = target(key)
    local window = hl.get_active_window()
    local m = hl.get_monitor(monitor)
    if not window or not m then return end
    local id = o.workspaces.workspace_id(m, slot)
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(id), window = "address:" .. window.address }))
  end, { description = "Move window to workspace " .. key })
end

-- A monitor plugged in shows its first workspace, which no key reaches here.
-- Show slot 7 on the second one instead, then give focus back.
local function show_split()
  local second = second_monitor()
  if not second then return end

  -- The catch-all rule above is not applied to a monitor plugged in while Hyprland
  -- runs (it comes up at 0x0, blank). A rule naming the output is.
  hl.monitor({ output = second, mode = "preferred", position = "auto-right", scale = 1 })

  local active = hl.get_active_workspace(second)
  local slot = active and active.id > 0 and (active.id - 1) % 10 + 1
  if not (slot and slot > split) then
    local focused = hl.get_active_monitor()
    o.workspaces.focus(split + 1, second)()
    if focused then hl.dispatch(hl.dsp.focus({ monitor = focused.name })) end
  end
end

hl.on("hyprland.start", show_split)
hl.on("monitor.added", show_split)
