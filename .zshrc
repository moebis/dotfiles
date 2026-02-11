# Environment Variables
export PATH="/Users/moebis/.antigravity/antigravity/bin:$PATH"
#export GEMINI_API_KEY="ENTER_API_KEY_HERE"

# Aliases
alias ls="eza --icons --group-directories-first"
alias cat="bat -pp"
alias vim="nvim"
alias gemini='NODE_OPTIONS="--disable-warning=DEP0040" gemini'

# Tool Initializations
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# History Configuration
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# History Deduplication
grep -v -E "^(: [0-9]*:[0-9]*;)?(cd|ls|cat|awk|sed|rm|z|bat|btop|mv|mkdir|cp|eza|cmatrix|yazu|uptime|whoami|free|err|Y|a)( |$)" ~/.zsh$
mv ~/.zsh_history.tmp ~/.zsh_history
fc -R ~/.zsh_history

# Keybindings (History Search)
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Startup
fastfetch
