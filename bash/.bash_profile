# ~/.bash_profile
# Set QT Env
export QT_QPA_PLATFORMTHEME=qt5ct

# Path Management
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

[[ -f ~/.bashrc ]] && . ~/.bashrc
