export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
export EDITOR=nvim
export SUDO_EDITOR=nvim

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
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Cargo
# [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"


autoload -U compinit; compinit

function zvm_config() {
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
}

# Load plugins manually
source ~/.dotfiles/zsh/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.dotfiles/zsh/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.dotfiles/zsh/.zsh/plugins/zsh-completions/zsh-completions.plugin.zsh
source ~/.dotfiles/zsh/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
source ~/.dotfiles/zsh/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
# source ~/.dotfiles/zsh/.zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh

# Load completions
autoload -Uz compinit && compinit
autoload -Uz up-line-or-search down-line-or-search fzf-history-widget
zle -N up-line-or-search
zle -N down-line-or-search
zle -N fzf-history-widget

my_zvm_vi_yank() {
    zvm_vi_yank
    echo -en "${CUTBUFFER}" | xclip -selection clipboard
}

my_zvm_vi_delete() {
    zvm_vi_delete
    echo -en "${CUTBUFFER}" | xclip -selection clipboard
}

my_zvm_vi_change() {
    zvm_vi_change
    echo -en "${CUTBUFFER}" | xclip -selection clipboard
}

my_zvm_vi_change_eol() {
    zvm_vi_change_eol
    echo -en "${CUTBUFFER}" | xclip -selection clipboard
}

my_zvm_vi_substitute() {
    zvm_vi_substitute
    echo -en "${CUTBUFFER}" | xclip -selection clipboard
}

my_zvm_vi_substitute_whole_line() {
    zvm_vi_substitute_whole_line
    echo -en "${CUTBUFFER}" | xclip -selection clipboard
}

my_zvm_vi_put_after() {
    CUTBUFFER=$(xclip -selection clipboard -o)
    zvm_vi_put_after
    zvm_highlight clear
}

my_zvm_vi_put_before() {
    CUTBUFFER=$(xclip -selection clipboard -o)
    zvm_vi_put_before
    zvm_highlight clear
}

my_zvm_vi_replace_selection() {
    CUTBUFFER=$(xclip -selection clipboard -o)
    zvm_vi_replace_selection
    echo -en "${CUTBUFFER}" | xclip -selection clipboard
}

# my_history_search_backward() {
#   zle history-search-backward
# }
#
# my_history_search_forward() {
#   zle history-search-forward
# }
#
# my_fzf_history_widget() {
#   zle fzf-history-widget
# }

# Keybinding for Conda Toggle
autoload -U add-zsh-hook
function conda_toggle_widget() {
  zle -I
  conda_toggle_env
  zle reset-prompt
}
zle -N conda_toggle_widget

zvm_after_lazy_keybindings() {
    zvm_define_widget my_zvm_vi_yank
    zvm_define_widget my_zvm_vi_delete
    zvm_define_widget my_zvm_vi_change
    zvm_define_widget my_zvm_vi_change_eol
    zvm_define_widget my_zvm_vi_put_after
    zvm_define_widget my_zvm_vi_put_before
    zvm_define_widget my_zvm_vi_substitute
    zvm_define_widget my_zvm_vi_substitute_whole_line
    zvm_define_widget my_zvm_vi_replace_selection
    # zvm_define_widget my_history_search_forward
    # zvm_define_widget my_history_search_backward
    # zvm_define_widget my_fzf_history_widget
    zvm_define_widget conda_toggle_env

    # zvm_bindkey viins '^r' my_fzf_history_widget
    # zvm_bindkey viins '^n' my_history_search_forward
    # zvm_bindkey viins '^p' my_history_search_backward

    zvm_bindkey viins '^p' history-search-backward
    zvm_bindkey viins '^n' history-search-forward
    zvm_bindkey viins '^[t' conda_toggle_widget
    
    zvm_bindkey vicmd 'y' my_zvm_vi_change_eol
    zvm_bindkey vicmd 'P' my_zvm_vi_put_before
    zvm_bindkey vicmd 'yy' my_zvm_vi_substitute_whole_line
    zvm_bindkey vicmd 'p' my_zvm_vi_put_after

    zvm_bindkey visual 'p' my_zvm_vi_replace_selection
    zvm_bindkey visual 'c' my_zvm_vi_change
    zvm_bindkey visual 'd' my_zvm_vi_delete
    zvm_bindkey visual 's' my_zvm_vi_substitute
    zvm_bindkey visual 'x' my_zvm_vi_delete
    zvm_bindkey visual 'y' my_zvm_vi_yank
}


zvm_after_init_commands+=(
  zvm_after_lazy_keybindings
  # fzf
  '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'

)

# zsh mode
# normal mode
# bindkey -e
# vim mode
bindkey -v 

# Keybindings
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

log_recent_dir() {
  local DIR="$PWD"
  local FILE="$HOME/.recent_dirs"

  [[ "$DIR" == "$LAST_LOGGED_DIR" ]] && return
  LAST_LOGGED_DIR="$DIR"

  mkdir -p "$(dirname "$FILE")"
  grep -Fxv "$DIR" "$FILE" 2>/dev/null > "$FILE.tmp"
  echo "$DIR" >> "$FILE.tmp"
  mv "$FILE.tmp" "$FILE"
  tail -n 50 "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
}

precmd_functions+=(log_recent_dir)

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
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

