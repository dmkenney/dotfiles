HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt HIST_IGNORE_DUPS
setopt INC_APPEND_HISTORY

# Direnv setup
eval "$(direnv hook zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Tools
alias n="nvim"
alias lg="lazygit"
alias ld="lazydocker"

# File system
alias ls='eza -lh --group-directories-first --icons'
alias lt='eza --tree --level=2 --long --icons --git'
alias lt3='eza --tree --level=3 --long --icons --git'
alias ll='ls -lah'
alias l='ls -lah'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'" 

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Misc
alias c='clear'

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
export EDITOR="nvim"

# Tmuxifier stuff
alias tmux-ls-config='tmuxifier load-session setup-and-dotfiles'
export PATH="$PATH:$HOME/.tmux/plugins/tmuxifier/bin"
export TMUXIFIER_LAYOUT_PATH="$HOME/dotfiles/tmux/tmux-layouts"
eval "$(tmuxifier init -)"

# Zig commands
alias zr='zig build run'
alias zb='zig build --release=fast'

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PATH:$PNPM_HOME"

# npm global packages
export PATH="$PATH:$HOME/.npm-global/bin"

# Go binaries
export PATH="$PATH:$HOME/go/bin"

# Fly.io
export PATH="$PATH:$HOME/.fly/bin"

# asdf version manager
. "$HOME/.asdf/asdf.sh"

# Claude Code
alias yolo='claude --dangerously-skip-permissions'

