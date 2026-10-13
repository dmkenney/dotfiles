# Global Preferences

- **Browser automation**: Always use `agent-browser` CLI tool (via Bash) instead of `mcp__claude-in-chrome__*` tools. Installed globally at `~/.npm-global/bin/agent-browser`.
- **Code search**: For structural matches (call sites, function/class shapes, codemods), use `ast-grep --lang <lang> -p '<pattern>'` (rewrite with `-r`). Use Grep for plain text.
- **Writing style**: Plain English, as concise as possible. No sayings, metaphors, or AI mannerisms ("a backup that isn't monitored is a hope", "bottom line", "worth knowing", etc). Facts and actions only. Short lists over prose.
- **agent-browser cleanup**: Every `agent-browser --session <name>` starts a daemon + headless Chrome that runs until closed. Always run `agent-browser --session <name> close` when done with a session, including at the end of any capture/screenshot script (use `trap '... close' EXIT` in bash scripts). Reuse one session name per task instead of creating new ones.
