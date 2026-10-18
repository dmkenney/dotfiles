# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Personal additions, ported from zsh/.zshrc (i3 machines). Omarchy already provides
# ls, lt, ff, .., n, mise, zoxide and EDITOR; only what it lacks or does differently is here.

alias c='clear' # Omarchy: c = opencode --auto
alias f='flockr'
alias lg='lazygit'
alias ld='lazydocker'
alias ll='ls -lah'
alias l='ls -lah'
alias lt3='eza --tree --level=3 --long --icons=auto --git'
alias zr='zig build run'
alias zb='zig build --release=fast'
alias yolo='claude --dangerously-skip-permissions'
alias cyolo='codex --yolo'

# Inside flockr, run Codex without its shared app-server daemon. The daemon runs
# hooks with the env of whichever pane started it, so flockr can't tell which
# pane a session belongs to. agents, queue and --remote need the daemon, and
# codex rejects --no-daemon given twice.
codex() {
  if [[ ${FLOCKR_ENV:-} == 1 ]]; then
    local arg skip=
    for arg in "$@"; do
      case $arg in agents | queue | app-server | remote-control | --remote | --remote=* | --no-daemon) skip=1 ;; esac
    done
    [[ -z $skip ]] && set -- --no-daemon "$@"
  fi
  command codex "$@"
}

# Tmuxifier (plugin installed by tpm)
export PATH="$PATH:$HOME/.tmux/plugins/tmuxifier/bin"
export TMUXIFIER_LAYOUT_PATH="$HOME/dotfiles/tmux/tmux-layouts"
command -v tmuxifier &>/dev/null && eval "$(tmuxifier init -)"
alias tmux-ls-config='tmuxifier load-session setup-and-dotfiles'

# Private aliases (personal submodule; plain alias lines, valid in bash and zsh)
[[ -f ~/dotfiles/personal/zsh/aliases.zsh ]] && source ~/dotfiles/personal/zsh/aliases.zsh

# Tool paths
export PATH="$PATH:$HOME/.npm-global/bin:$HOME/go/bin:$HOME/.fly/bin:$HOME/.mix/escripts"

# 1Password service account (token kept outside the repo); stops desktop-app CLI prompts
[[ -r ~/.config/op/service-account-token ]] && export OP_SERVICE_ACCOUNT_TOKEN="$(< ~/.config/op/service-account-token)"
. "$HOME/.cargo/env"
