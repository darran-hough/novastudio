
#!/usr/bin/env bash

LOG="/var/log/novastudio-installer.log"

log(){
 echo "[ $(date '+%F %T') ] $*" | tee -a "$LOG"
}

success(){
 echo "✔ $*"
}

fail(){
 echo "ERROR: $*" >&2
 exit 1
}

require_root(){
 [[ $EUID -eq 0 ]] || fail "Run installer using sudo."
}

detect_user(){
 REAL_USER=${SUDO_USER:-$(who | awk 'NR==1{print $1}')}
 HOME_DIR=$(eval echo "~$REAL_USER")
}

print_banner(){
cat << "EOF"
=====================================
        NovaStudio Installer v2
=====================================
EOF
}

install_pkg(){
 for pkg in "$@"; do
   if ! rpm -q "$pkg" &>/dev/null; then
      log "Installing $pkg"
      dnf install -y --allowerasing "$pkg"
   fi
 done
}

load_modules(){
 MODULES=(
  hardware
  profile
  gpu
  audio
  gaming
  wine
  media
  optimisations
 )

 for m in "${MODULES[@]}"; do
   source "$BASE_DIR/modules/$m.sh"
 done
}

run_modules(){
 for m in "${MODULES[@]}"; do
   log "Running module: $m"
   "module_$m"
 done
}
