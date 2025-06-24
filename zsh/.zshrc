export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
export SUDO_EDITOR=nvim
export NVM_DIR="$HOME/.nvm"

eval "$(oh-my-posh init zsh --config ~/.dotfiles/zsh/.zsh/themes/craver.omp.json)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Conda toggle function
function conda_toggle_env() {
    local current_env="${CONDA_DEFAULT_ENV:-}"
    if [[ -n "$current_env" ]]; then
        echo "Deactivating Conda environment: $current_env"
        conda deactivate
    else
        local selected_env=$(conda env list | awk '{print $1}' | grep -vE '^(#|$)' | fzf --prompt="Select Conda Env: ")
        [[ -n "$selected_env" ]] && conda activate "$selected_env"
    fi
}

# Source NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Cargo
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load plugins manually
source ~/.dotfiles/zsh/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.dotfiles/zsh/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.dotfiles/zsh/.zsh/plugins/zsh-completions/zsh-completions.plugin.zsh
source ~/.dotfiles/zsh/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
# source ~/.dotfiles/zsh/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Load completions
autoload -Uz compinit && compinit

# Keybinding for Conda Toggle
autoload -U add-zsh-hook
function conda_toggle_widget() {
    zle -I
    conda_toggle_env
    zle reset-prompt
}
zle -N conda_toggle_widget

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[t' conda_toggle_widget

# History config
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt inc_append_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color $realpath'

# Shell options
setopt autocd
setopt correct
setopt interactivecomments
setopt magicequalsubst
setopt nonomatch
setopt notify
setopt numericglobsort
setopt promptsubst

# Aliases
alias c='clear'
alias q='exit'
alias ..='cd ..'
alias mkdir='mkdir -pv'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias rmdir='rmdir -v'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias virsh='virsh -c qemu:///system'
alias virt-viewer='virt-viewer -c qemu:///system'


# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/rushin/.lmstudio/bin"
# End of LM Studio CLI section

