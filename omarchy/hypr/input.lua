-- Caps Lock is Super (was ~/.Xmodmap on i3). Replaces Omarchy's compose:caps.
hl.config({
  input = {
    kb_options = "caps:super",
  },
})

-- Mouse pointer like unclutter on i3: hide after 5s without mouse movement.
-- Omarchy's hide_on_key_press made the pointer flash: typing hid it, then each
-- keyboard focus change (Super+H/J/K/L) showed it again over the window under it.
hl.config({
  cursor = {
    hide_on_key_press = false,
    inactive_timeout = 5,
    -- Hardware cursor on NVIDIA; "auto" picked software, which felt laggy at 7680x2160.
    no_hardware_cursors = 0,
  },
})

-- [[ OMARCHY_MOUSE_SETTINGS_START ]]
hl.config({
  input = {
    sensitivity = 0.46,
    accel_profile = "adaptive",
    follow_mouse = 1,
    natural_scroll = false,
    touchpad = {
      natural_scroll = false,
    },
    left_handed = false,
    scroll_factor = 1.00,
    scroll_method = "",
    scroll_button = 0,
    scroll_button_lock = false,
    mouse_refocus = true,
  },
})
-- [[ OMARCHY_MOUSE_SETTINGS_END ]]
