# ===================================================
# ZONE 1: CORE ENVIRONMENT & PATHS
# ===================================================
# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# Ensure essential directories exist
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN" "$HOME/bin"

# Path Management
export PATH="$HOME/bin:$LOCAL_BIN:$HOME/.lmstudio/bin:$PATH"
export USER=${USER:-$(id -un)}

# Editor Settings
if ! command -v "$EDITOR" >/dev/null 2>&1; then
    if command -v nvim >/dev/null 2>&1; then
        export EDITOR='nvim'
    elif command -v vim >/dev/null 2>&1; then
        export EDITOR='vim'
    fi
fi

if [ -n "$EDITOR" ]; then
    export VISUAL="$EDITOR"
    export SUDO_EDITOR="$EDITOR"
fi

# Source external files
[[ -f ~/.bash_tools ]] && . ~/.bash_tools
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do [ -f "$rc" ] && . "$rc"; done
fi

# Tools options setup
if command -v conda &> /dev/null; then
    if ! grep -qi "auto_activate: false" ~/.condarc 2>/dev/null; then
        conda config --set auto_activate false
    fi
fi

unset rc

# ===================================================
# ZONE 2: FUNCTIONS (Conda, Prompt, Logging)
# ===================================================

# --- INTERACTIVE CONDA TOGGLE ---
conda_toggle_env() {

    if ! command -v conda &>/dev/null; then
        return 1
    fi

    local current_env="${CONDA_DEFAULT_ENV:-}"
    local selected_env
    local deactivate_opt="[Deactivate Conda -> System Python]"

    selected_env=$(
        (echo "$deactivate_opt"; conda env list | awk '{print $1}' | grep -vE '^(#|$)') |
        fzf --height 40% --layout=reverse --border --prompt="Select Conda Env: "
    )

    [[ -z "$selected_env" ]] && return 0

    if [[ "$selected_env" == "$deactivate_opt" ]]; then
        while [[ -n "$CONDA_DEFAULT_ENV" ]]; do
            conda deactivate
        done
        return 0
    fi

    if [[ "$selected_env" == "$current_env" ]]; then
        return 0
    fi

    [[ -n "$current_env" ]] && conda deactivate
    conda activate "$selected_env"
}

# --- DIRECTORY LOGGER ---
log_recent_dir() {
    local DIR="$PWD"
    local FILE="$HOME/.recent_dirs"
    [[ "$DIR" == "$LAST_LOGGED_DIR" ]] && return
    LAST_LOGGED_DIR="$DIR"
    grep -Fxv "$DIR" "$FILE" 2>/dev/null >"$FILE.tmp"
    echo "$DIR" >>"$FILE.tmp"
    mv "$FILE.tmp" "$FILE"
    tail -n 50 "$FILE" >"$FILE.tmp" && mv "$FILE.tmp" "$FILE"
}

# ===================================================
# ZONE 3: AUTOMATIC MANAGERS (Updaters)
# ===================================================

# --- STARSHIP AUTOMATIC MANAGER ---
install_or_update_starship() {
    local BIN_DIR="$HOME/.local/bin"
    local CHECK_FILE="$BIN_DIR/.starship_update_check"
    local REPO_URL="starship/starship"

    # 1. Dependency Check
    if ! command -v curl &> /dev/null || ! command -v grep &> /dev/null; then
        echo "ERROR: 'curl' and 'grep' are required for Starship auto-installer."
        return 1
    fi

    local NEEDS_INSTALL=0
    local REMOTE_VER=""

    # 2. Check if installed
    if [[ ! -x "$BIN_DIR/starship" ]]; then
        echo "Starship not found. Installing locally..."
        NEEDS_INSTALL=1
    else
        # 3. Check for updates (Once every 7 days = 10080 minutes)
        if [[ ! -f "$CHECK_FILE" ]] || [[ -n $(find "$CHECK_FILE" -mmin +10080 2>/dev/null) ]]; then
            touch "$CHECK_FILE"

            # Fetch latest tag from GitHub and strip the leading 'v' using sed
            REMOTE_VER=$(curl -s "https://api.github.com/repos/$REPO_URL/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")' | sed 's/^v//')

            # Get local version purely as numbers (e.g., "1.24.2")
            local LOCAL_VER="$($BIN_DIR/starship --version 2>/dev/null | head -n 1 | awk '{sub(/^v/, "", $2); print $2}')"

            # If versions don't match, an update is available
            if [[ -n "$REMOTE_VER" && "$LOCAL_VER" != "$REMOTE_VER" ]]; then
                echo "New version $REMOTE_VER found for Starship (Current: $LOCAL_VER). Updating..."
                NEEDS_INSTALL=1
            fi
        fi
    fi

    # 4. Perform Download & Install using official script silently
    if [[ $NEEDS_INSTALL -eq 1 ]]; then
        mkdir -p "$BIN_DIR"
        if curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$BIN_DIR" >/dev/null; then
            echo "Starship is up to date!"
        else
            echo "ERROR: Starship installation failed."
        fi
    fi
}

# --- NEOVIM AUTOMATIC MANAGER ---
install_or_update_nvim() {
    local NVIM_DIR="$HOME/.local/nvim"
    local BIN_DIR="$HOME/.local/bin"
    local CHECK_FILE="$NVIM_DIR/.last_update_check"
    local VERSION_FILE="$NVIM_DIR/.version"
    local REPO_URL="neovim/neovim"

    # 1. Dependency Check
    if ! command -v curl &> /dev/null || ! command -v tar &> /dev/null || ! command -v grep &> /dev/null; then
        echo "ERROR: 'curl', 'tar', and 'grep' are required for Neovim auto-installer."
        return 1
    fi

    # 2. Architecture Check (Handles your PC vs Raspberry Pi)
    local ARCH=$(uname -m)
    local DL_ASSET=""
    case "$ARCH" in
        x86_64)          DL_ASSET="nvim-linux-x86_64.tar.gz" ;;
        aarch64|arm64)   DL_ASSET="nvim-linux-arm64.tar.gz" ;;
        *)               echo "Unsupported architecture for Neovim pre-builts: $ARCH" && return 1 ;;
    esac

    local NEEDS_INSTALL=0
    local REMOTE_VER=""

    # 3. Check if installed
    if [[ ! -x "$BIN_DIR/nvim" ]]; then
        echo "Neovim not found. Installing for $ARCH..."
        NEEDS_INSTALL=1
    else
        # 4. Check for updates (Once every 7 days = 10080 minutes)
        if [[ ! -f "$CHECK_FILE" ]] || [[ -n $(find "$CHECK_FILE" -mmin +10080 2>/dev/null) ]]; then
            touch "$CHECK_FILE"

            # Fast check using GitHub API for the latest release tag
            REMOTE_VER=$(curl -s "https://api.github.com/repos/$REPO_URL/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
            local LOCAL_VER=""

            [[ -f "$VERSION_FILE" ]] && LOCAL_VER=$(cat "$VERSION_FILE")

            # If versions don't match, an update is available
            if [[ -n "$REMOTE_VER" && "$LOCAL_VER" != "$REMOTE_VER" ]]; then
                echo "New version $REMOTE_VER found for Neovim. Updating..."
                NEEDS_INSTALL=1
            fi
        fi
    fi

    # 5. Perform Download & Install if flagged
    if [[ $NEEDS_INSTALL -eq 1 ]]; then
        # Ensure we grab the remote tag if this is a first-time install
        [[ -z "$REMOTE_VER" ]] && REMOTE_VER=$(curl -s "https://api.github.com/repos/$REPO_URL/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

        if [[ -n "$REMOTE_VER" ]]; then
            local DOWNLOAD_URL="https://github.com/$REPO_URL/releases/download/$REMOTE_VER/$DL_ASSET"
            local TMP_DIR="/tmp/nvim-dl-$RANDOM"

            mkdir -p "$TMP_DIR" "$NVIM_DIR" "$BIN_DIR"

            # Download and extract, stripping the top-level folder so contents go straight into TMP_DIR
            if curl -sL "$DOWNLOAD_URL" | tar -xz -C "$TMP_DIR" --strip-components=1 2>/dev/null; then

                # Wipe the old installation cleanly
                rm -rf "${NVIM_DIR:?}/"*

                # Move the fresh files into the permanent directory
                mv "$TMP_DIR"/* "$NVIM_DIR/"

                # Create the symlink in your PATH
                ln -sf "$NVIM_DIR/bin/nvim" "$BIN_DIR/nvim"

                # Save the new version tag
                echo "$REMOTE_VER" > "$VERSION_FILE"
            else
                echo "ERROR: Failed to download or extract Neovim from $DOWNLOAD_URL"
            fi

            # Clean up
            rm -rf "$TMP_DIR"
        fi
    fi
}

# --- 1. AUTOMATIC FZF MANAGER ---
FZF_DIR="$HOME/.fzf"
FZF_CHECK_FILE="$FZF_DIR/.last_update_check"

install_or_update_fzf() {
    if [ ! -d "$FZF_DIR" ]; then
        echo "fzf not found. Installing from git..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
        "$FZF_DIR/install" --bin --no-update-rc
    else
        # Only check for updates once every 24 hours
        if [[ ! -f "$FZF_CHECK_FILE" ]] || [[ -n $(find "$FZF_CHECK_FILE" -mmin +1440) ]]; then
            touch "$FZF_CHECK_FILE"

            # Extract local version (e.g., 0.70.0)
            LOCAL_VER=$("$FZF_DIR/bin/fzf" --version 2>/dev/null | awk '{print $1}')

            # Fetch remote tag and strip the leading 'v' if it exists
            REMOTE_TAG=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
            REMOTE_VER="${REMOTE_TAG#v}" # This removes the 'v' prefix

            if [[ -z "$REMOTE_VER" ]]; then
                return
            fi

            if [[ "$LOCAL_VER" != "$REMOTE_VER" ]]; then
                echo "Updating fzf from $LOCAL_VER to $REMOTE_VER..."
                # Use git fetch/reset to handle shallow clone updates more reliably
                (cd "$FZF_DIR" && git fetch --depth 1 && git reset --hard origin/master && ./install --bin --no-update-rc)
            fi
        fi
    fi
}

# --- AUTOMATIC CARAPACE MANAGER ---
install_or_update_carapace() {
    local CARAPACE_BIN="$LOCAL_BIN/carapace"
    local CHECK_FILE="$LOCAL_BIN/.carapace_update_check"

    # 1. Detect Architecture dynamically
    local ARCH=$(uname -m)
    local DL_ARCH=""
    case "$ARCH" in
        x86_64)          DL_ARCH="amd64" ;;
        aarch64|arm64)   DL_ARCH="arm64" ;;
        armv7l|armv6l)   DL_ARCH="arm" ;;
        i386|i686)       DL_ARCH="386" ;;
        *)               echo "Unsupported architecture: $ARCH" && return 1 ;;
    esac

    local NEEDS_INSTALL=0
    local REMOTE_VER=""

    # 2. Check if installed by looking exactly where we install it
    if [[ ! -x "$CARAPACE_BIN" ]]; then
        echo "Carapace not found. Installing for linux_$DL_ARCH..."
        NEEDS_INSTALL=1
    else
        # 3. Check for updates (Once every 24 hours)
        if [[ ! -f "$CHECK_FILE" ]] || [[ -n $(find "$CHECK_FILE" -mmin +1440 2>/dev/null) ]]; then

            # Fast GitHub API check for the latest tag
            REMOTE_VER=$(curl -s "https://api.github.com/repos/carapace-sh/carapace-bin/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

            if [[ -n "$REMOTE_VER" ]]; then
                # Read local version from our check file.
                # Fallback to asking the binary if the file was somehow deleted.
                local LOCAL_VER=""
                if [[ -s "$CHECK_FILE" ]]; then
                    LOCAL_VER=$(cat "$CHECK_FILE")
                else
                    local RAW_VER=$("$CARAPACE_BIN" --version 2>/dev/null | awk '{print $2}')
                    [[ -n "$RAW_VER" ]] && LOCAL_VER="v${RAW_VER#v}"
                fi

                if [[ "$LOCAL_VER" != "$REMOTE_VER" ]]; then
                    echo "Updating Carapace from ${LOCAL_VER:-unknown} to $REMOTE_VER..."
                    NEEDS_INSTALL=1
                else
                    # It is up to date. Write version to file to update the modification timestamp.
                    echo "$REMOTE_VER" > "$CHECK_FILE"
                fi
            fi
        fi
    fi

    # 4. Perform Download & Extract if flagged
    if [[ $NEEDS_INSTALL -eq 1 ]]; then
        # If REMOTE_VER is empty (happens on first install), fetch it
        if [[ -z "$REMOTE_VER" ]]; then
            REMOTE_VER=$(curl -s "https://api.github.com/repos/carapace-sh/carapace-bin/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
        fi

        if [[ -n "$REMOTE_VER" ]]; then
            local CARAPACE_URL=$(curl -s "https://api.github.com/repos/carapace-sh/carapace-bin/releases/tags/$REMOTE_VER" | \
                grep "browser_download_url" | grep "linux_${DL_ARCH}.tar.gz" | head -n 1 | cut -d '"' -f 4)

            if [[ -n "$CARAPACE_URL" ]]; then
                # Extract *only* the carapace binary into your local bin folder
                curl -sL "$CARAPACE_URL" | tar -xz -C "$LOCAL_BIN" carapace 2>/dev/null || curl -sL "$CARAPACE_URL" | tar -xz -C "$LOCAL_BIN"
                chmod +x "$CARAPACE_BIN" 2>/dev/null

                # WRITE THE VERSION TO THE CHECK FILE
                echo "$REMOTE_VER" > "$CHECK_FILE"
            else
                echo "Failed to find Carapace release for linux_$DL_ARCH."
            fi
        fi
    fi
}

# --- BASH LINE EDITOR (Syntax Highlighting) ---
install_or_update_blesh() {
    local BLE_DIR="$HOME/.local/share/blesh"
    local CHECK_FILE="$BLE_DIR/.last_update_check"
    local HASH_FILE="$BLE_DIR/.commit_hash"
    local REPO_URL="https://github.com/akinomyoga/ble.sh.git"

    # 1. Dependency Check
    if ! command -v make &> /dev/null || ! command -v gawk &> /dev/null || ! command -v git &> /dev/null; then
        echo "ERROR: 'make', 'git', and 'gawk' are required for ble.sh."
        return 1
    fi

    local NEEDS_INSTALL=0
    local REMOTE_HASH=""

    # 2. Check if installed
    if [[ ! -f "$BLE_DIR/ble.sh" ]]; then
        echo "ble.sh not found. Installing..."
        NEEDS_INSTALL=1
    else
        # 3. Check for updates (Once every 24 hours)
        if [[ ! -f "$CHECK_FILE" ]] || [[ $(find "$CHECK_FILE" -mmin +1440 2>/dev/null) ]]; then
            touch "$CHECK_FILE"

            # Fast check using git ls-remote to get the latest commit hash on master
            REMOTE_HASH=$(git ls-remote "$REPO_URL" HEAD | awk '{print $1}')
            local LOCAL_HASH=""

            [[ -f "$HASH_FILE" ]] && LOCAL_HASH=$(cat "$HASH_FILE")

            # If the hashes don't match, an update is available
            if [[ -n "$REMOTE_HASH" && "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
                echo "New commit found for ble.sh. Updating in the background..."
                NEEDS_INSTALL=1
            fi
        fi
    fi

    # 4. Perform Build & Install if flagged
    if [[ $NEEDS_INSTALL -eq 1 ]]; then
        # Ensure we grab the remote hash if this is a first-time install
        [[ -z "$REMOTE_HASH" ]] && REMOTE_HASH=$(git ls-remote "$REPO_URL" HEAD | awk '{print $1}')

        # Clone, build, and install silently
        rm -rf /tmp/blesh-src
        git clone --recursive --depth 1 --shallow-submodules "$REPO_URL" /tmp/blesh-src &> /dev/null
        make -C /tmp/blesh-src install PREFIX="$HOME/.local" &> /dev/null
        rm -rf /tmp/blesh-src

        # Save the new hash to prevent infinite update loops
        [[ -n "$REMOTE_HASH" ]] && echo "$REMOTE_HASH" > "$HASH_FILE"
    fi
}

# Run the manager silently
install_or_update_starship
install_or_update_nvim
install_or_update_fzf
install_or_update_carapace
install_or_update_blesh

# ===================================================
# ZONE 4: ALIASES & FINAL ATTACHMENTS
# ===================================================
alias c='clear'
alias q='exit'
alias ..='cd ..'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias grep='grep --color=auto'

# ===================================================
# ZONE 5: SHELL UI INITIALIZATION
# ===================================================

# Turn ON Vim keystrokes FIRST so ble.sh loads the Vi module
set -o vi

# Start the syntax highlighter in the background (Do not attach yet)
if [[ -f "$HOME/.local/share/blesh/ble.sh" ]]; then
    source "$HOME/.local/share/blesh/ble.sh" --noattach
fi

# Load basic system fallbacks
[[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

# Load Carapace
if command -v carapace &> /dev/null; then
    export CARAPACE_BRIDGES='zsh,fish,bash'
    source <(carapace _carapace)
fi

# STANDARD FZF
if [[ -d "$HOME/.fzf/bin" ]]; then
    export PATH="$PATH:$HOME/.fzf/bin"
    eval "$(fzf --bash)"
fi
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline --color='header:italic'"

PROMPT_COMMAND="log_recent_dir"

# Initialize Starship prompt
if command -v starship &> /dev/null; then
    # Generate preset BEFORE initializing if it's missing
    if [ ! -f ~/.config/starship.toml ]; then
        mkdir -p  ~/.config
        starship preset plain-text-symbols -o ~/.config/starship.toml
    fi
    eval "$(starship init bash)"
fi

# --- ATTACH SYNTAX HIGHLIGHTING (THIS GOES AT THE VERY BOTTOM) ---
[[ ${BLE_VERSION-} ]] && ble-attach
