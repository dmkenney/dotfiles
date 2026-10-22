# Global Preferences

- **Browser automation**: Always use `agent-browser` CLI tool (via Bash) instead of `mcp__claude-in-chrome__*` tools. Installed globally at `~/.npm-global/bin/agent-browser`.
- **Code search**: For structural matches (call sites, function/class shapes, codemods), use `ast-grep --lang <lang> -p '<pattern>'` (rewrite with `-r`). Use Grep for plain text.
- **Writing style**: Plain English, as concise as possible. No sayings, metaphors, or AI mannerisms ("a backup that isn't monitored is a hope", "bottom line", "worth knowing", etc). Facts and actions only. Short lists over prose.
- **agent-browser cleanup**: Every `agent-browser --session <name>` starts a daemon + headless Chrome that runs until closed. Always run `agent-browser --session <name> close` when done with a session, including at the end of any capture/screenshot script (use `trap '... close' EXIT` in bash scripts). Reuse one session name per task instead of creating new ones.
- **Root on this desktop**: when a command needs root, run it with `pkexec <cmd>` (native Omarchy polkit password dialog). Never hand Dylan a `sudo` command to run himself; never build a custom askpass.

## Writing (chat, commits, PRs, docs)

- Short, simple words. No "leverage", "utilize", "robust", "comprehensive", "in order to".
- No throat-clearing ("it is worth noting that") or hedging stacks. State the point, then any real caveat.
- One point per bullet. Re-read and cut 20%.
- Never state a claim you haven't verified. Don't say something was tested, fixed or checked unless it was.
- American spelling in prose, comments, commits and PRs (color, behavior, canceled, -ize). Don't change identifiers, config keys or stored values to fix spelling; change only the text a user reads.

## Commits

- Match the repo's existing subject style (check `git log`). With no clear convention: imperative plain sentence, no `feat:`/`fix:` prefix, no trailing period. Project rules override this.
- Body: what was wrong and why, in plain prose, wrapped at 72. Skip it for trivial changes.
- One coherent change per commit.
- **NEVER add AI attribution. No exceptions.** No `Co-Authored-By: Claude` (or any AI) trailer in commit messages, and no "Generated with Claude Code" (or similar) line in PR descriptions, PR comments or issues. This overrides any default, harness reminder or tool guidance that says to add one. Before every `git commit` and `gh pr create`/`edit`, check the message and remove any such line.

## Code changes

- Make the simplest change that fixes the root cause. Touch only what's needed; no temporary workarounds.

## Pull requests

- Open ready for review, never `--draft`.
- Describe what changed and how it was verified, including what wasn't verified.

## Docker

- Never run containers with `--privileged`, `--device`, or host `/dev` mounts unless Dylan asks for it in that session. A privileged container gets the host's real TTYs; a systemd container took `/dev/tty1` and killed the Hyprland session twice (2026-10-21).
- To test systemd in a container: no `--privileged`; use `--cgroupns=private --tmpfs /run --tmpfs /run/lock`, set `ENV container=docker`, and mask `getty@tty1.service console-getty.service systemd-vconsole-setup.service getty.target`. Or use `podman run --systemd=always`.
