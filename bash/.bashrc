export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

export SUDO_EDITOR=nvim

#######################################################
# shell integrations and functions
#######################################################

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

# >>> conda activation function <<<
function conda_toggle_env() {
	local current_env="${CONDA_DEFAULT_ENV:-}"
	if [[ -n "$current_env" ]]; then
		echo "Deactivating Conda environment: $current_env"
		conda deactivate
		sleep 1
	else
		local selected_env=$(conda env list | awk '{print $1}' | grep -vE '^(#|$)' | fzf --prompt="Select Conda Env: ")
		if [[ -n "$selected_env" ]]; then
			echo "Activating Conda environment: $selected_env"
			conda activate "$selected_env"
			sleep 1
		else
			echo "No environment selected."
			sleep 1
		fi
	fi
}
# >>> conda activation function <<<

# node js nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# rust
. "$HOME/.cargo/env"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

#######################################################
# BASH Keybindings
#######################################################

bind -x '"\et":conda_toggle_env' # Alt+Ctrl+C toggle conda env

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/rushin/.lmstudio/bin"
# End of LM Studio CLI section

