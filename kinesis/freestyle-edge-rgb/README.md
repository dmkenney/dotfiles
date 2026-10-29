# Kinesis Freestyle Edge RGB

Copy of the keyboard's v-Drive config. Not installed anywhere; restore by hand.

Profile 3 (the startup profile) has the custom layout:

- Left space: Right Alt (Voxtype push-to-talk)
- F1-F6: mute, volume down, volume up, play/pause, previous, next; Fn + F1-F6 gives F1-F6
- HK0, HK1, HK2: F13, F14, F15, bound in `omarchy/hypr/bindings.lua` to Key Light on/off, dimmer, brighter

Edit with SmartSet RGB (`~/Projects/kinesis-gaming-rgb-linux`) or by hand:

1. SmartSet (gear) + F8 opens the v-Drive; udiskie mounts it.
2. Edit and save. Files need CRLF line endings.
3. Unmount (`udisksctl unmount -b /dev/sdX` or Eject in the app).
4. SmartSet + F8 closes the v-Drive and the keyboard reloads its files.

To restore, copy `layouts/`, `lighting/` and `settings/` onto the open v-Drive.
`firmware/version.txt` is written by the keyboard.
