-- Custom Lua layouts for the 57" ultrawide. Each is used as "lua:<name>": the
-- default is set in looknfeel.lua, and Super+Alt+L cycles through them
-- (bin/workspace-layout-toggle). Windows fill in the order they opened.
-- Lua layouts ignore Hyprland's window resize, so center, spiral and stack take
-- "grow"/"shrink" layout messages instead (Super+R then H/L, in bindings.lua).
-- https://wiki.hypr.land/Configuring/Layouts/ (hl.layout.register)

-- A layout_msg handler that grows or shrinks one ratio in 5% steps.
local function ratio_msg(get, set, min, max)
  return function(_, msg)
    local step = ({ grow = 0.05, shrink = -0.05 })[msg]
    if not step then return false end
    set(math.max(min, math.min(max, get() + step)))
    return true
  end
end

-- Slot order per workspace, as JSON ({"31": ["0x...", ...]}). Hyprland can't
-- report it, and these layouts place windows by it, so session restore
-- (OmaSession) reads it to reopen windows in the same slots.
local slot_order = {}

function window_slot_order()
  local parts = {}
  for ws, addresses in pairs(slot_order) do
    parts[#parts + 1] = string.format('"%d":["%s"]', ws, table.concat(addresses, '","'))
  end
  return "{" .. table.concat(parts, ",") .. "}"
end

-- hl.layout.register, also recording each workspace's slot order.
local function register(name, provider)
  local recalculate = provider.recalculate
  provider.recalculate = function(ctx)
    local ws, addresses = nil, {}
    for _, target in ipairs(ctx.targets) do
      local window = target.window
      if window then
        ws = ws or (window.workspace and window.workspace.id)
        addresses[#addresses + 1] = window.address
      end
    end
    if ws then slot_order[ws] = addresses end
    return recalculate(ctx)
  end
  hl.layout.register(name, provider)
end

-- Place targets as equal rows inside one column box.
local function stack(targets, x, y, w, h)
  for j, target in ipairs(targets) do
    target:place({ x = x, y = y + h * (j - 1) / #targets, w = w, h = h / #targets })
  end
end

-- center: first window in a fixed middle column, then left, then right, later
-- ones stacking on alternate sides.
local center_width = 0.30

register("center", {
  recalculate = function(ctx)
    local area = ctx.area
    if #ctx.targets == 0 then return end

    local middle_w = area.w * center_width
    local side_w = (area.w - middle_w) / 2
    local left, middle, right = {}, {}, {}
    for i, target in ipairs(ctx.targets) do
      table.insert(i == 1 and middle or (i % 2 == 0 and left or right), target)
    end

    stack(left, area.x, area.y, side_w, area.h)
    stack(middle, area.x + side_w, area.y, middle_w, area.h)
    stack(right, area.x + side_w + middle_w, area.y, side_w, area.h)
  end,

  layout_msg = ratio_msg(function() return center_width end, function(v) center_width = v end, 0.15, 0.8),
})

-- columns: every window gets an equal-width column.
register("columns", {
  recalculate = function(ctx)
    for i, target in ipairs(ctx.targets) do
      target:place(ctx:column(i, #ctx.targets))
    end
  end,
})

-- thirds: three fixed equal columns, filled left, middle, right, then stacking.
register("thirds", {
  recalculate = function(ctx)
    local area = ctx.area
    local columns = { {}, {}, {} }
    for i, target in ipairs(ctx.targets) do
      table.insert(columns[(i - 1) % 3 + 1], target)
    end
    for c, targets in ipairs(columns) do
      stack(targets, area.x + area.w * (c - 1) / 3, area.y, area.w / 3, area.h)
    end
  end,
})

-- grid: an even grid, with more columns than rows to suit the wide screen.
register("grid", {
  recalculate = function(ctx)
    local n, area = #ctx.targets, ctx.area
    if n == 0 then return end

    local cols = math.min(n, math.ceil(math.sqrt(n * area.w / area.h)))
    local rows = math.ceil(n / cols)
    for i, target in ipairs(ctx.targets) do
      target:place(ctx:grid_cell(i, cols, rows))
    end
  end,
})

-- spiral: each window takes 58% of the space left, turning clockwise
-- (from Hyprland's example/layouts/spiral.lua).
local spiral_ratio = 0.58
local spiral_sides = { "left", "top", "right", "bottom" }
local spiral_opposite = { left = "right", right = "left", top = "bottom", bottom = "top" }

register("spiral", {
  recalculate = function(ctx)
    local n, area = #ctx.targets, ctx.area
    for i, target in ipairs(ctx.targets) do
      if i == n then
        target:place(area)
      else
        local side = spiral_sides[(i - 1) % 4 + 1]
        target:place(ctx:split(area, side, spiral_ratio))
        area = ctx:split(area, spiral_opposite[side], 1 - spiral_ratio)
      end
    end
  end,

  layout_msg = ratio_msg(function() return spiral_ratio end, function(v) spiral_ratio = v end, 0.2, 0.8),
})

-- stack: first window on the left at 70%, the rest stacked in the right column.
-- Alone, it takes the whole screen.
local stack_main = 0.70

register("stack", {
  recalculate = function(ctx)
    local area, n = ctx.area, #ctx.targets
    if n == 0 then return end
    if n == 1 then
      ctx.targets[1]:place(area)
      return
    end

    local main_w = area.w * stack_main
    ctx.targets[1]:place({ x = area.x, y = area.y, w = main_w, h = area.h })
    stack({ table.unpack(ctx.targets, 2) }, area.x + main_w, area.y, area.w - main_w, area.h)
  end,

  layout_msg = ratio_msg(function() return stack_main end, function(v) stack_main = v end, 0.3, 0.85),
})

-- main-dwindle: first window on the left at 35%, the rest of the screen filled
-- like dwindle (each new window halves the last space along its longer side).
-- Alone, it takes the whole screen.
local main_dwindle_main = 0.35

register("main-dwindle", {
  recalculate = function(ctx)
    local area, n = ctx.area, #ctx.targets
    if n == 0 then return end
    if n == 1 then
      ctx.targets[1]:place(area)
      return
    end

    ctx.targets[1]:place(ctx:split(area, "left", main_dwindle_main))
    local rest = ctx:split(area, "right", 1 - main_dwindle_main)
    for i = 2, n do
      if i == n then
        ctx.targets[i]:place(rest)
      else
        local wide = rest.w >= rest.h
        ctx.targets[i]:place(ctx:split(rest, wide and "left" or "top", 0.5))
        rest = ctx:split(rest, wide and "right" or "bottom", 0.5)
      end
    end
  end,

  layout_msg = ratio_msg(function() return main_dwindle_main end, function(v) main_dwindle_main = v end, 0.2, 0.8),
})
