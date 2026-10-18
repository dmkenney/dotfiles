# flockr keybinds

Defaults are active now. **Old custom** is what `[keys]` in `config.toml`
had before 2026-10-18.

- To bring one back, add it under `[keys]` in `config.toml`, then run
  `flockr server reload-config` (or `prefix+R`).
- A custom value replaces the whole default for that action.
- `prefix` is the prefix key (default `ctrl+b`).
- *unbound* means no key by default.

Copy-paste source for the old lines: `keys-reference.toml` in this folder.

## General

| Action                     | Default          | Old custom       |
|----------------------------|------------------|------------------|
| `prefix`                   | `ctrl+b`         | `ctrl+space`     |
| `help`                     | `prefix+?`       | `prefix+?`       |
| `settings`                 | `prefix+s`       | `prefix+shift+s` |
| `detach`                   | `prefix+q`       | `prefix+d`       |
| `reload_config`            | `prefix+shift+r` | `prefix+r`       |
| `open_notification_target` | `prefix+o`       |                  |
| `goto`                     | `prefix+g`       |                  |
| `toggle_sidebar`           | `prefix+b`       |                  |
| `edit_scrollback`          | `prefix+e`       |                  |
| `copy_mode`                | `prefix+[`       | `prefix+[`       |
| `remote_image_paste`       | `ctrl+v`         |                  |

- `copy_mode` is missing from the sample config; vi keys inside it are built in.
- `remote_image_paste` only works in `flockr --remote`.

## Workspaces

| Action               | Default          | Old custom                                     |
|----------------------|------------------|------------------------------------------------|
| `workspace_picker`   | `prefix+w`       | `prefix+j`, `prefix+k`, `prefix+s`, `prefix+w` |
| `new_workspace`      | `prefix+shift+n` | `prefix+shift+c`                               |
| `rename_workspace`   | `prefix+shift+w` | `prefix+$`, `prefix+shift+r`                   |
| `close_workspace`    | `prefix+shift+d` | `prefix+shift+k`                               |
| `previous_workspace` | *unbound*        | `prefix+shift+p`, `alt+up`                     |
| `next_workspace`     | *unbound*        | `prefix+shift+n`, `alt+down`                   |
| `switch_workspace`   | *unbound*        | `ctrl+alt+1..9`                                |
| `new_worktree`       | `prefix+shift+g` |                                                |
| `open_worktree`      | *unbound*        |                                                |
| `remove_worktree`    | *unbound*        |                                                |

## Agents

| Action           | Default   | Old custom |
|------------------|-----------|------------|
| `previous_agent` | *unbound* | `alt+k`    |
| `next_agent`     | *unbound* | `alt+j`    |
| `focus_agent`    | *unbound* | `alt+1..9` |

## Tabs

| Action              | Default          | Old custom              |
|---------------------|------------------|-------------------------|
| `new_tab`           | `prefix+c`       | `prefix+c`              |
| `rename_tab`        | `prefix+shift+t` | `prefix+comma`          |
| `close_tab`         | `prefix+shift+x` | `prefix+ampersand`      |
| `previous_tab`      | `prefix+p`       | `prefix+p`, `alt+left`  |
| `next_tab`          | `prefix+n`       | `prefix+n`, `alt+right` |
| `move_tab_previous` | *unbound*        | `alt+shift+left`        |
| `move_tab_next`     | *unbound*        | `alt+shift+right`       |
| `switch_tab`        | `prefix+1..9`    | `prefix+1..9`           |

## Panes

| Action                | Default            | Old custom                                           |
|-----------------------|--------------------|------------------------------------------------------|
| `focus_pane_left`     | `prefix+h`         | `prefix+h`, `ctrl+h`, `ctrl+alt+left`, `ctrl+alt+h`  |
| `focus_pane_down`     | `prefix+j`         | `ctrl+j`, `ctrl+alt+down`, `ctrl+alt+j`              |
| `focus_pane_up`       | `prefix+k`         | `ctrl+k`, `ctrl+alt+up`, `ctrl+alt+k`                |
| `focus_pane_right`    | `prefix+l`         | `prefix+l`, `ctrl+l`, `ctrl+alt+right`, `ctrl+alt+l` |
| `cycle_pane_next`     | `prefix+tab`       | `prefix+o`                                           |
| `cycle_pane_previous` | `prefix+shift+tab` |                                                      |
| `last_pane`           | *unbound*          | `prefix+;`                                           |
| `split_vertical`      | `prefix+v`         | `prefix+%`, `prefix+v`, `alt+enter`                  |
| `split_horizontal`    | `prefix+minus`     | `prefix+"`, `prefix+minus`, `alt+shift+enter`        |
| `close_pane`          | `prefix+x`         | `prefix+x`, `alt+esc`                                |
| `zoom`                | `prefix+z`         | `prefix+z`                                           |
| `rename_pane`         | `prefix+shift+p`   | `prefix+shift+o`                                     |
| `clear_pane`          | *unbound*          |                                                      |

- `zoom` was called `fullscreen` in older configs.

## Resize

| Action              | Default    | Old custom                                                                    |
|---------------------|------------|-------------------------------------------------------------------------------|
| `resize_mode`       | `prefix+r` | `prefix+ctrl+left`, `prefix+ctrl+down`, `prefix+ctrl+up`, `prefix+ctrl+right` |
| `resize_pane_left`  | *unbound*  | `prefix+ctrl+h`, `ctrl+alt+shift+left`, `ctrl+alt+shift+h`                    |
| `resize_pane_down`  | *unbound*  | `prefix+ctrl+j`, `ctrl+alt+shift+down`, `ctrl+alt+shift+j`                    |
| `resize_pane_up`    | *unbound*  | `prefix+ctrl+k`, `ctrl+alt+shift+up`, `ctrl+alt+shift+k`                      |
| `resize_pane_right` | *unbound*  | `prefix+ctrl+l`, `ctrl+alt+shift+right`, `ctrl+alt+shift+l`                   |

## Navigate mode (no prefix; active inside navigate mode)

| Action                    | Default | Old custom  |
|---------------------------|---------|-------------|
| `navigate_workspace_up`   | `up`    | `k`, `up`   |
| `navigate_workspace_down` | `down`  | `j`, `down` |
| `navigate_pane_left`      | `h`     |             |
| `navigate_pane_down`      | `j`     | `shift+j`   |
| `navigate_pane_up`        | `k`     | `shift+k`   |
| `navigate_pane_right`     | `l`     |             |

- Left and right arrows always move to the pane on that side.
