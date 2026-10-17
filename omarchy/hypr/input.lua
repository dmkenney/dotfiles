-- Caps Lock is Super (was ~/.Xmodmap on i3). Replaces Omarchy's compose:caps.
hl.config({
  input = {
    kb_options = "caps:super",
  },
})

-- Mouse pointer like unclutter on i3: hide after 5s without mouse movement.
-- Omarchy's hide_on_key_press made the pointer flash: typing hid it, then each
-- keyboard focus change (Super+H/J/K/L) showed it again over the window under it.
-- no_warps: focus moves leave the pointer where it is (Hyprland otherwise jumps it
-- to the center of the newly focused window).
hl.config({
  cursor = {
    hide_on_key_press = false,
    inactive_timeout = 5,
    no_warps = true,
  },
})
