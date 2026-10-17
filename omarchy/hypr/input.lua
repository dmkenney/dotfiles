-- Caps Lock is Super (was ~/.Xmodmap on i3). Replaces Omarchy's compose:caps.
hl.config({
  input = {
    kb_options = "caps:super",
  },
})

-- Keyboard focus moves (Super+H/J/K/L) leave the mouse pointer where it is. Hyprland
-- otherwise warps it to the center of the newly focused window, where it flashes
-- visible until Omarchy's hide_on_key_press hides it again.
hl.config({
  cursor = {
    no_warps = true,
  },
})
