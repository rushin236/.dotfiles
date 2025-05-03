export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

export SUDO_EDITOR=nvim

# Init oh-my-posh
# eval "$(oh-my-posh init bash --config ~/.cache/oh-my-posh/themes/paradox.omp.json)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.bash' 'hook' 2>/dev/null)"
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

# shell integrations
# node js nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# rust
. "$HOME/.cargo/env"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# fzf integration
eval "$(fzf --bash)"
