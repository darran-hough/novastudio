
#!/usr/bin/env bash

LOG="/var/log/novastudio.log"

log(){
    echo "[ $(date '+%F %T') ] $*" | tee -a "$LOG"
}

error(){
    echo "ERROR: $*" >&2
    exit 1
}

success(){
    echo "✔ $*"
}

require_root(){
    [[ $EUID -eq 0 ]] || error "Run installer with sudo."
}

detect_user(){
    REAL_USER=${SUDO_USER:-$(who | awk 'NR==1{print $1}')}
    HOME_DIR=$(eval echo "~$REAL_USER")
}

print_banner(){
cat << "EOF"
============================================
        NovaStudio OS Installer
============================================
EOF
}

install_pkg(){
    for pkg in "$@"; do
        if ! rpm -q "$pkg" &>/dev/null; then
            log "Installing $pkg"
            dnf install -y "$pkg"
        fi
    done
}

load_modules(){
    MODULES=(
        hardware
        gpu
        audio
        gaming
        wine
        media
        desktop
    )

    for mod in "${MODULES[@]}"; do
        source "$BASE_DIR/modules/$mod.sh"
    done
}

run_modules(){
    for mod in "${MODULES[@]}"; do
        log "Running module: $mod"
        "module_$mod"
    done
}
