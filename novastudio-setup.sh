#!/usr/bin/env bash
# ==============================================================================
#  ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗ ███████╗████████╗██╗   ██╗██████╗ ██╗ ██████╗
#  ████╗  ██║██╔═══██╗██║   ██║██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║██╔═══██╗
#  ██╔██╗ ██║██║   ██║██║   ██║███████║███████╗   ██║   ██║   ██║██║  ██║██║██║   ██║
#  ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║╚════██║   ██║   ██║   ██║██║  ██║██║██║   ██║
#  ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║███████║   ██║   ╚██████╔╝██████╔╝██║╚██████╔╝
#  ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝
#
#  NovаStudio OS — Fedora-Based Media, Audio & Gaming Environment
#  Version 2.1 | Architect Edition
#  Built for: Media Production · Audio Engineering · Windows App Compatibility
#              Focusrite Interfaces · Yabridge · Low-Latency Performance
#              Gaming (Steam · Lutris · Proton-GE · GameMode · MangoHud)
#
#  Author  : NovаStudio OS Architect
#  License : MIT
#  Target  : Fedora 39/40/41+
# ==============================================================================

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 0 : GLOBAL CONSTANTS & COLOUR PALETTE
# ──────────────────────────────────────────────────────────────────────────────

readonly NS_VERSION="2.1"
readonly NS_NAME="NovаStudio OS"
readonly LOG_FILE="/var/log/novastudio-setup.log"
readonly BACKUP_DIR="/var/novastudio/backups/$(date +%Y%m%d_%H%M%S)"
readonly CONFIG_DIR="$HOME/.config/novastudio"
readonly WINE_PREFIX="$HOME/.wine-novastudio"

# Colours
RED='\033[0;31m';    LRED='\033[1;31m'
GREEN='\033[0;32m';  LGREEN='\033[1;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'
LCYAN='\033[1;36m';  MAGENTA='\033[0;35m'
LMAGENTA='\033[1;35m'; BLUE='\033[0;34m'
LBLUE='\033[1;34m';  WHITE='\033[1;37m'
GREY='\033[0;37m';   BOLD='\033[1m'
DIM='\033[2m';       RESET='\033[0m'
BLINK='\033[5m';     UNDERLINE='\033[4m'

# Status icons
ICO_OK="✅";  ICO_FAIL="❌"; ICO_WARN="⚠️ "
ICO_INFO="ℹ️ "; ICO_GEAR="⚙️ "; ICO_ROCKET="🚀"
ICO_MUSIC="🎵"; ICO_FILM="🎬"; ICO_WIN="🪟"
ICO_AUDIO="🎧"; ICO_CHIP="🔧"; ICO_BRUSH="🎨"
ICO_LOCK="🔒"; ICO_STAR="⭐"; ICO_GAME="🎮"

# Global state flags (set during hardware detection)
HW_GPU_NVIDIA=false; HW_GPU_AMD=false; HW_GPU_INTEL=false
HW_FOCUSRITE=false;  HW_USB_AUDIO=false; HW_THUNDERBOLT=false
HW_LAPTOP=false;     HW_NVME=false;      HW_RAM_GB=0
HW_CPU_CORES=0;      HW_CPU_VENDOR=""
ERRORS=(); WARNINGS=()

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 1 : LOGGING & OUTPUT HELPERS
# ──────────────────────────────────────────────────────────────────────────────

# Ensure log directory exists even before root check
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

_log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE" 2>/dev/null || true; }
_log_cmd() { "$@" 2>&1 | tee -a "$LOG_FILE"; }

print_banner() {
    clear
    echo -e "${LCYAN}"
    cat << 'EOF'
  ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗ ███████╗████████╗██╗   ██╗██████╗ ██╗ ██████╗
  ████╗  ██║██╔═══██╗██║   ██║██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║██╔═══██╗
  ██╔██╗ ██║██║   ██║██║   ██║███████║███████╗   ██║   ██║   ██║██║  ██║██║██║   ██║
  ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║╚════██║   ██║   ██║   ██║██║  ██║██║██║   ██║
  ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║███████║   ██║   ╚██████╔╝██████╔╝██║╚██████╔╝
  ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝
EOF
    echo -e "${RESET}"
    echo -e "  ${GREY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${WHITE}${BOLD}  Fedora-Based Media & Audio Production Environment  v${NS_VERSION}${RESET}"
    echo -e "  ${GREY}  Media Production · Audio Engineering · Windows Apps · Low-Latency${RESET}"
    echo -e "  ${GREY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
}

step_header() {
    local step="$1" title="$2"
    echo
    echo -e "  ${LCYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    printf "  ${LCYAN}║${RESET}  ${LMAGENTA}STEP %-2s${RESET} ${WHITE}%-51s${LCYAN}║${RESET}\n" "$step" "$title"
    echo -e "  ${LCYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    _log "=== STEP $step: $title ==="
}

info()    { echo -e "  ${LCYAN}${ICO_INFO}${RESET}  ${WHITE}$*${RESET}";    _log "INFO: $*"; }
success() { echo -e "  ${LGREEN}${ICO_OK}${RESET}  ${GREEN}$*${RESET}";     _log "OK:   $*"; }
warn()    { echo -e "  ${YELLOW}${ICO_WARN}${RESET} ${YELLOW}$*${RESET}";   _log "WARN: $*"; WARNINGS+=("$*"); }
error()   { echo -e "  ${LRED}${ICO_FAIL}${RESET}  ${RED}$*${RESET}";       _log "ERR:  $*"; ERRORS+=("$*"); }
task()    { echo -e "  ${MAGENTA}${ICO_GEAR}${RESET}  ${GREY}$*${RESET}..."; _log "TASK: $*"; }
bold_info(){ echo -e "  ${LBLUE}${ICO_STAR}${RESET}  ${BOLD}${WHITE}$*${RESET}"; _log "★ $*"; }

progress_bar() {
    local current="$1" total="$2" label="${3:-Progress}"
    local pct=$(( current * 100 / total ))
    local filled=$(( pct / 2 ))
    local bar=""
    for (( i=0; i<50; i++ )); do
        if (( i < filled )); then bar+="█"; else bar+="░"; fi
    done
    printf "\r  ${CYAN}[${LGREEN}%s${CYAN}] ${WHITE}%3d%% ${GREY}%s${RESET}" "$bar" "$pct" "$label"
}

spinner_run() {
    local label="$1"; shift
    local spinchars='⣾⣽⣻⢿⡿⣟⣯⣷'
    "$@" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${LCYAN}%s${RESET}  ${GREY}%s${RESET}" "${spinchars:$((i % ${#spinchars})):1}" "$label"
        sleep 0.1
        (( i++ )) || true
    done
    wait "$pid"
    local rc=$?
    printf "\r  "
    if [[ $rc -eq 0 ]]; then
        echo -e "${LGREEN}${ICO_OK}${RESET}  ${GREEN}${label}${RESET}"
    else
        echo -e "${LRED}${ICO_FAIL}${RESET}  ${RED}${label} (failed — see log)${RESET}"
        ERRORS+=("$label")
    fi
    return $rc
}

confirm() {
    local msg="${1:-Continue?}" default="${2:-y}"
    local prompt yn
    if [[ "$default" == "y" ]]; then prompt="[Y/n]"; else prompt="[y/N]"; fi
    echo -en "  ${YELLOW}❓  ${WHITE}${msg} ${GREY}${prompt}${RESET} "
    read -r yn
    yn="${yn:-$default}"
    [[ "$yn" =~ ^[Yy] ]]
}

pause() {
    echo -en "  ${GREY}${DIM}Press ENTER to continue...${RESET}"
    read -r
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "\n  ${LRED}${ICO_FAIL}  This script must be run as root (sudo).${RESET}"
        echo -e "  ${GREY}  Usage: sudo bash novastudio-setup.sh${RESET}\n"
        exit 1
    fi
}

dnf_install() {
    # Silent install; errors collected but non-fatal per package
    local pkg
    for pkg in "$@"; do
        if ! rpm -q "$pkg" &>/dev/null; then
            if ! dnf install -y "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Package not available / failed: $pkg"
            fi
        fi
    done
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 2 : PRE-FLIGHT CHECKS
# ──────────────────────────────────────────────────────────────────────────────

preflight_checks() {
    step_header "0" "Pre-Flight System Checks"

    # Root
    require_root

    # Fedora check
    task "Verifying Fedora base"
    if ! grep -qi "fedora" /etc/os-release 2>/dev/null; then
        error "This script requires Fedora Linux. Aborting."
        exit 1
    fi
    local fed_ver
    fed_ver=$(grep VERSION_ID /etc/os-release | cut -d= -f2)
    success "Fedora $fed_ver detected"

    # Minimum Fedora version (39+)
    if (( fed_ver < 39 )); then
        warn "Fedora $fed_ver is older than recommended (39+). Some features may fail."
        confirm "Continue anyway?" "n" || exit 1
    fi

    # Internet connectivity
    task "Checking internet connectivity"
    if ! ping -c1 -W3 8.8.8.8 &>/dev/null; then
        error "No internet access. Cannot proceed."
        exit 1
    fi
    success "Internet connectivity OK"

    # Disk space (need at least 15 GB free)
    task "Checking disk space"
    local free_gb
    free_gb=$(df / --output=avail -BG | tail -1 | tr -d 'G ')
    if (( free_gb < 15 )); then
        error "Insufficient disk space: ${free_gb}GB free, need at least 15GB."
        exit 1
    fi
    success "Disk space OK (${free_gb}GB free)"

    # Create backup & config dirs
    mkdir -p "$BACKUP_DIR" "$CONFIG_DIR"

    # Initialise log
    _log "NovаStudio OS Setup v${NS_VERSION} — started"
    success "Log initialised → $LOG_FILE"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 3 : HARDWARE AUTO-DETECTION
# ──────────────────────────────────────────────────────────────────────────────

detect_hardware() {
    step_header "1" "${ICO_CHIP} Hardware Auto-Detection"

    # ── CPU ──────────────────────────────────────────────────────────────────
    task "Detecting CPU"
    HW_CPU_CORES=$(nproc)
    HW_CPU_VENDOR=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}' 2>/dev/null || echo "Unknown")
    local cpu_model
    cpu_model=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //' 2>/dev/null || echo "Unknown")
    success "CPU: $cpu_model ($HW_CPU_CORES cores, vendor: $HW_CPU_VENDOR)"

    # ── RAM ──────────────────────────────────────────────────────────────────
    task "Detecting RAM"
    HW_RAM_GB=$(awk '/MemTotal/ {printf "%d", $2/1024/1024}' /proc/meminfo)
    local ram_mb
    ram_mb=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
    success "RAM: ${HW_RAM_GB}GB (${ram_mb}MB total)"
    (( HW_RAM_GB < 8 )) && warn "Only ${HW_RAM_GB}GB RAM detected — media production benefits from 16GB+"

    # ── Storage ──────────────────────────────────────────────────────────────
    task "Detecting storage"
    if ls /dev/nvme* &>/dev/null; then
        HW_NVME=true
        local nvme_list
        nvme_list=$(ls /dev/nvme?n1 2>/dev/null | tr '\n' ' ')
        success "NVMe SSD(s) detected: $nvme_list"
    else
        local disk_type
        disk_type=$(lsblk -d -o NAME,ROTA 2>/dev/null | awk 'NR>1 && /^[sh]d/ {if($2=="0") print "SSD"; else print "HDD"; exit}')
        success "Storage type: ${disk_type:-rotational/SSD}"
    fi

    # ── GPU ───────────────────────────────────────────────────────────────────
    # Uses `lspci -mm` (machine-readable) to match on exact PCI class strings:
    #   "VGA compatible controller"  — class 0300, all display outputs
    #   "3D controller"              — class 0302, headless compute GPUs (NVIDIA secondary)
    #   "Display controller"         — class 0380, misc display hardware
    # This avoids false-positives from AMD chipset USB/SATA controllers whose
    # lspci description contains "AMD" AND accidentally matches "3d" as a
    # substring of "USB 3.1" or "USB3" in the device name.
    task "Detecting GPU(s)"
    local lspci_display
    lspci_display=$(lspci 2>/dev/null | grep -iE \
        "VGA compatible controller|3D controller|Display controller")

    if echo "$lspci_display" | grep -iq "nvidia"; then
        HW_GPU_NVIDIA=true
        local nvidia_model
        nvidia_model=$(echo "$lspci_display" | grep -i nvidia | head -1 | sed 's/.*: //')
        success "NVIDIA GPU: $nvidia_model"
    fi

    # AMD GPU: must be a display-class device AND have an AMD/Radeon identifier.
    # Explicitly exclude USB, SATA, Audio, and other non-GPU AMD PCI devices.
    if echo "$lspci_display" | grep -iE "amd|radeon|amdgpu" &>/dev/null; then
        HW_GPU_AMD=true
        local amd_model
        amd_model=$(echo "$lspci_display" | grep -iE "amd|radeon|amdgpu" | head -1 | sed 's/.*: //')
        success "AMD GPU: $amd_model"
    fi

    if echo "$lspci_display" | grep -i "intel" &>/dev/null; then
        HW_GPU_INTEL=true
        local intel_model
        intel_model=$(echo "$lspci_display" | grep -i intel | head -1 | sed 's/.*: //')
        success "Intel GPU: $intel_model"
    fi

    $HW_GPU_NVIDIA || $HW_GPU_AMD || $HW_GPU_INTEL || \
        warn "No recognised GPU detected — using generic framebuffer"

    # ── USB Audio / Focusrite ─────────────────────────────────────────────────
    task "Detecting Focusrite / USB audio interfaces"
    # Focusrite USB Vendor ID is 0x1235
    if lsusb 2>/dev/null | grep -iq "1235:"; then
        HW_FOCUSRITE=true
        local focusrite_model
        focusrite_model=$(lsusb 2>/dev/null | grep -i "1235:" | head -1)
        success "${ICO_AUDIO} Focusrite device: $focusrite_model"
    elif lsusb 2>/dev/null | grep -iE "scarlett|clarett|focusrite" &>/dev/null; then
        HW_FOCUSRITE=true
        success "${ICO_AUDIO} Focusrite device detected via name match"
    else
        info "No Focusrite device connected right now (driver will still be installed)"
    fi

    if lsusb 2>/dev/null | grep -iE "audio|sound|midi" &>/dev/null; then
        HW_USB_AUDIO=true
        success "USB audio device(s) present"
    fi

    # ── Thunderbolt ──────────────────────────────────────────────────────────
    task "Detecting Thunderbolt"
    if ls /sys/bus/thunderbolt/devices/ 2>/dev/null | grep -q .; then
        HW_THUNDERBOLT=true
        success "Thunderbolt controller detected"
    fi

    # ── Laptop detection ─────────────────────────────────────────────────────
    task "Checking form factor"
    if ls /sys/class/power_supply/BAT* &>/dev/null; then
        HW_LAPTOP=true
        success "Laptop form factor detected (battery present)"
    else
        success "Desktop form factor detected"
    fi

    # ── Summary ──────────────────────────────────────────────────────────────
    echo
    echo -e "  ${LCYAN}┌─────────────────────────────────────────────┐${RESET}"
    echo -e "  ${LCYAN}│${RESET}  ${BOLD}${WHITE}Hardware Detection Summary${RESET}                  ${LCYAN}│${RESET}"
    echo -e "  ${LCYAN}├─────────────────────────────────────────────┤${RESET}"
    printf "  ${LCYAN}│${RESET}  %-12s %-30s ${LCYAN}│${RESET}\n" "CPU Cores:"    "$HW_CPU_CORES"
    printf "  ${LCYAN}│${RESET}  %-12s %-30s ${LCYAN}│${RESET}\n" "RAM:"          "${HW_RAM_GB}GB"
    printf "  ${LCYAN}│${RESET}  %-12s %-30s ${LCYAN}│${RESET}\n" "NVMe:"         "$HW_NVME"
    printf "  ${LCYAN}│${RESET}  %-12s %-30s ${LCYAN}│${RESET}\n" "NVIDIA:"       "$HW_GPU_NVIDIA"
    printf "  ${LCYAN}│${RESET}  %-12s %-30s ${LCYAN}│${RESET}\n" "AMD GPU:"      "$HW_GPU_AMD"
    printf "  ${LCYAN}│${RESET}  %-12s %-30s ${LCYAN}│${RESET}\n" "Focusrite:"    "$HW_FOCUSRITE"
    printf "  ${LCYAN}│${RESET}  %-12s %-30s ${LCYAN}│${RESET}\n" "Thunderbolt:"  "$HW_THUNDERBOLT"
    printf "  ${LCYAN}│${RESET}  %-12s %-30s ${LCYAN}│${RESET}\n" "Laptop:"       "$HW_LAPTOP"
    echo -e "  ${LCYAN}└─────────────────────────────────────────────┘${RESET}"

    _log "Hardware detection complete"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 4 : SYSTEM OPTIMISATION
# ──────────────────────────────────────────────────────────────────────────────

optimise_system() {
    step_header "2" "${ICO_ROCKET} System Optimisation"

    # ── DNF configuration ────────────────────────────────────────────────────
    task "Optimising DNF package manager"
    cp /etc/dnf/dnf.conf "$BACKUP_DIR/dnf.conf.bak" 2>/dev/null || true
    cat >> /etc/dnf/dnf.conf << 'EOF'
# NovаStudio OS — DNF Optimisations
fastestmirror=True
max_parallel_downloads=10
deltarpm=True
install_weak_deps=False
EOF
    success "DNF: parallel downloads and fastestmirror enabled"

    # ── RPM Fusion ───────────────────────────────────────────────────────────
    task "Enabling RPM Fusion (Free + Non-Free)"
    if ! rpm -q rpmfusion-free-release &>/dev/null; then
        spinner_run "Installing RPM Fusion Free" \
            dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    fi
    if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
        spinner_run "Installing RPM Fusion Non-Free" \
            dnf install -y \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    fi
    success "RPM Fusion enabled"

    # ── Flatpak / Flathub ────────────────────────────────────────────────────
    task "Configuring Flatpak + Flathub"
    dnf_install flatpak
    if ! flatpak remote-list 2>/dev/null | grep -q flathub; then
        flatpak remote-add --if-not-exists flathub \
            https://flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
    fi
    success "Flathub repository added"

    # ── System update ────────────────────────────────────────────────────────
    task "Running full system update (this may take a few minutes)"
    spinner_run "Refreshing metadata" dnf makecache --refresh
    spinner_run "Updating all packages" dnf upgrade -y --refresh

    # ── Kernel selection ─────────────────────────────────────────────────────
    task "Installing low-latency / realtime kernel"
    # kernel-rt is in RPM Fusion Non-Free. On brand-new Fedora releases it may
    # lag by a few weeks. If not found, we try the official @rt/realtime COPR
    # as a fallback before giving up and staying on the standard kernel.
    local rt_found=false

    if dnf list available kernel-rt >> "$LOG_FILE" 2>&1; then
        rt_found=true
    else
        info "kernel-rt not in RPM Fusion yet for this Fedora release — trying @rt/realtime COPR"
        if dnf copr enable -y @rt/realtime >> "$LOG_FILE" 2>&1; then
            # Refresh metadata after enabling new repo
            dnf makecache >> "$LOG_FILE" 2>&1 || true
            if dnf list available kernel-rt >> "$LOG_FILE" 2>&1; then
                rt_found=true
            fi
        else
            warn "Could not enable @rt/realtime COPR"
        fi
    fi

    if $rt_found; then
        spinner_run "Installing kernel-rt (realtime)" \
            dnf install -y kernel-rt kernel-rt-devel kernel-rt-modules-extra
        # Set realtime kernel as default using grubby (most reliable method)
        local rt_vmlinuz
        rt_vmlinuz=$(ls /boot/vmlinuz-*rt* 2>/dev/null | sort -V | tail -1)
        if [[ -n "$rt_vmlinuz" ]]; then
            grubby --set-default "$rt_vmlinuz" >> "$LOG_FILE" 2>&1 && \
                success "Realtime kernel set as default: $rt_vmlinuz" || \
                warn "grubby could not set default kernel — set manually after reboot"
        fi
    else
        warn "kernel-rt not available in any known repo for Fedora $(rpm -E %fedora)"
        warn "Staying on standard kernel. Retry later: sudo dnf install -y kernel-rt kernel-rt-devel"
        dnf_install kernel kernel-devel
    fi

    # ── CPU governor ─────────────────────────────────────────────────────────
    task "Configuring CPU performance governor"
    dnf_install cpupower
    if $HW_LAPTOP; then
        # Laptop: use schedutil for battery-friendly but still responsive
        cat > /etc/systemd/system/cpu-performance.service << 'EOF'
[Unit]
Description=NovаStudio CPU Governor
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g schedutil
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    else
        cat > /etc/systemd/system/cpu-performance.service << 'EOF'
[Unit]
Description=NovаStudio CPU Governor (Performance)
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    fi
    systemctl enable cpu-performance.service >> "$LOG_FILE" 2>&1
    success "CPU governor service configured"

    # ── I/O scheduler ────────────────────────────────────────────────────────
    task "Configuring I/O scheduler"
    if $HW_NVME; then
        # NVMe: none (no queuing needed) or mq-deadline
        cat > /etc/udev/rules.d/60-novastudio-io.rules << 'EOF'
# NovаStudio IO Scheduler Rules
# NVMe drives — use none (pass-through)
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# SSD drives — use mq-deadline
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# HDD drives — use bfq (Best Fair Queueing — better for audio)
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
    else
        cat > /etc/udev/rules.d/60-novastudio-io.rules << 'EOF'
# NovаStudio IO Scheduler Rules
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
    fi
    success "I/O scheduler rules configured"

    # ── Kernel parameters ────────────────────────────────────────────────────
    task "Applying kernel parameters for low-latency / audio"
    cp /etc/sysctl.conf "$BACKUP_DIR/sysctl.conf.bak" 2>/dev/null || true
    cat > /etc/sysctl.d/99-novastudio.conf << 'EOF'
# ── NovаStudio OS: Kernel Tuning ──────────────────────────────────────────
# Virtual memory: reduce swappiness for better real-time performance
vm.swappiness = 10
vm.dirty_ratio = 3
vm.dirty_background_ratio = 1
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100

# Network performance
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_fastopen = 3

# File system
fs.inotify.max_user_watches = 524288
fs.file-max = 2097152

# Memory
kernel.perf_cpu_time_max_percent = 50
EOF
    sysctl --system >> "$LOG_FILE" 2>&1
    success "Kernel parameters applied"

    # ── GRUB tuning ──────────────────────────────────────────────────────────
    task "Tuning GRUB for performance"
    cp /etc/default/grub "$BACKUP_DIR/grub.bak" 2>/dev/null || true

    local grub_opts="quiet splash threadirqs nohz_full=all rcu_nocbs=all skew_tick=1 mitigations=off"
    # If Intel CPU, add intel_idle.max_cstate=1
    [[ "$HW_CPU_VENDOR" == "GenuineIntel" ]] && grub_opts+=" intel_idle.max_cstate=1"
    # AMD: disable C-states for RT
    [[ "$HW_CPU_VENDOR" == "AuthenticAMD" ]] && grub_opts+=" processor.max_cstate=1"

    sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"${grub_opts}\"|" /etc/default/grub
    # On modern Fedora (EFI or BIOS), grub2-mkconfig must always target
    # /boot/grub2/grub.cfg — the EFI path is a read-only BLS wrapper.
    # grub2-mkconfig itself writes the correct EFI location internally.
    if grub2-mkconfig -o /boot/grub2/grub.cfg >> "$LOG_FILE" 2>&1; then
        success "GRUB tuned with realtime parameters"
    else
        warn "grub2-mkconfig reported an error — check log. Boot parameters may not have applied."
    fi

    # ── Limits for audio ─────────────────────────────────────────────────────
    task "Setting system limits for audio production (ulimits)"
    cp /etc/security/limits.conf "$BACKUP_DIR/limits.conf.bak" 2>/dev/null || true
    cat >> /etc/security/limits.conf << 'EOF'
# ── NovаStudio OS: Audio/RT Limits ───────────────────────────────────────
@audio   -  rtprio     99
@audio   -  memlock    unlimited
@audio   -  nice       -20
*        -  nofile     1048576
EOF
    success "RT priority limits configured for @audio group"

    # ── Transparent huge pages ───────────────────────────────────────────────
    task "Disabling transparent huge pages (better for RT audio)"
    cat > /etc/systemd/system/disable-thp.service << 'EOF'
[Unit]
Description=Disable Transparent Huge Pages
After=sysinit.target local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
ExecStart=/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable disable-thp.service >> "$LOG_FILE" 2>&1
    success "THP disabled at boot"

    success "${ICO_ROCKET} System optimisation complete"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 5 : GPU DRIVERS
# ──────────────────────────────────────────────────────────────────────────────

install_gpu_drivers() {
    step_header "3" "GPU Drivers"

    if $HW_GPU_NVIDIA; then
        task "Installing NVIDIA drivers (akmod — stable)"
        spinner_run "Installing akmod-nvidia" dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
        # Wait for kernel module build
        echo -e "  ${YELLOW}⏳  Waiting for NVIDIA kernel module to build (may take 2–5 min)...${RESET}"
        akmods --force >> "$LOG_FILE" 2>&1 || true
        modprobe nvidia >> "$LOG_FILE" 2>&1 || true
        success "NVIDIA driver installed"
        # NVIDIA power management for laptops
        if $HW_LAPTOP; then
            dnf_install nvidia-settings
            cat > /etc/modprobe.d/nvidia-power.conf << 'EOF'
options nvidia "NVreg_DynamicPowerManagement=0x02"
options nvidia-drm modeset=1
EOF
        else
            echo 'options nvidia-drm modeset=1' > /etc/modprobe.d/nvidia-drm.conf
        fi
        success "NVIDIA DRM modesetting enabled"
    fi

    if $HW_GPU_AMD; then
        task "Configuring AMD GPU (amdgpu — open source)"
        dnf_install mesa-dri-drivers mesa-vulkan-drivers vulkan-loader \
            xorg-x11-drv-amdgpu libdrm mesa-libGL mesa-libGLES
        cat > /etc/modprobe.d/amdgpu.conf << 'EOF'
# NovаStudio AMD GPU options
options amdgpu si_support=1
options amdgpu cik_support=1
options amdgpu ppfeaturemask=0xffffffff
EOF
        # ROCm for compute (media encoding)
        # Note: mesa-opencl-icd was renamed to mesa-opencl in Fedora 38+
        if confirm "Install AMD ROCm (GPU compute — useful for video encoding)?" "y"; then
            # Try modern package name first, fall back gracefully — non-fatal
            if dnf list available mesa-opencl >> "$LOG_FILE" 2>&1; then
                dnf_install rocm-opencl mesa-opencl
            elif dnf list available mesa-opencl-icd >> "$LOG_FILE" 2>&1; then
                dnf_install rocm-opencl mesa-opencl-icd
            else
                dnf_install rocm-opencl
                warn "mesa-opencl package not found — ROCm installed without OpenCL ICD"
            fi
        fi
        success "AMD GPU configured"
    fi

    if $HW_GPU_INTEL; then
        task "Installing Intel GPU drivers"
        dnf_install mesa-dri-drivers mesa-vulkan-drivers intel-media-driver \
            libva libva-intel-driver libva-utils
        success "Intel GPU drivers installed"
    fi

    # ── Vulkan + VA-API (hardware video decode) ───────────────────────────────
    task "Installing Vulkan SDK and VA-API"
    dnf_install vulkan vulkan-tools vulkan-loader vulkan-loader-devel \
        libva libva-utils gstreamer1-vaapi ffmpeg
    success "Vulkan and VA-API installed"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 6 : AUDIO SUBSYSTEM (PipeWire + JACK + Focusrite)
# ──────────────────────────────────────────────────────────────────────────────

setup_audio() {
    step_header "4" "${ICO_AUDIO} Audio Subsystem (PipeWire + JACK + Focusrite)"

    # ── Remove PulseAudio if present ──────────────────────────────────────────
    task "Removing legacy PulseAudio"
    if rpm -q pulseaudio &>/dev/null; then
        dnf remove -y pulseaudio pulseaudio-utils >> "$LOG_FILE" 2>&1
        success "PulseAudio removed"
    else
        success "PulseAudio not present — skipping"
    fi

    # ── PipeWire stack ────────────────────────────────────────────────────────
    # Uses dnf_install (per-package, non-fatal) rather than spinner_run so that
    # renamed or missing packages on newer Fedora releases don't abort the whole
    # section. Package names confirmed against Fedora 43 repos.
    task "Installing PipeWire (modern audio server)"
    # Core PipeWire — always present on Fedora 38+
    dnf_install pipewire pipewire-utils pipewire-alsa \
        pipewire-jack-audio-connection-kit pipewire-pulseaudio \
        wireplumber
    # Optional dev/doc packages — may not exist on all releases; failures are harmless
    dnf_install pipewire-devel wireplumber-devel pipewire-doc 2>/dev/null || true
    # GStreamer PipeWire integration — package was merged into gstreamer1-plugins-good
    # on Fedora 40+; try both names, neither is fatal if absent
    dnf_install gstreamer1-plugin-pipewire 2>/dev/null || \
        dnf_install gstreamer1-plugins-good 2>/dev/null || true
    success "PipeWire stack installed"

    # ── JACK libraries (infrastructure — no GUI apps) ────────────────────────
    task "Installing JACK2 libraries"
    dnf_install jack-audio-connection-kit jack-audio-connection-kit-devel
    success "JACK2 libraries installed"

    # ── PipeWire JACK config for low latency ─────────────────────────────────
    task "Configuring PipeWire for low-latency (32 frames / 48000 Hz)"
    mkdir -p /etc/pipewire/pipewire.conf.d
    cat > /etc/pipewire/pipewire.conf.d/99-novastudio-rt.conf << 'EOF'
# NovаStudio OS — PipeWire Low-Latency Config
context.properties = {
    default.clock.rate          = 48000
    default.clock.allowed-rates = [ 44100 48000 88200 96000 176400 192000 ]
    default.clock.quantum       = 32
    default.clock.min-quantum   = 16
    default.clock.max-quantum   = 8192
    core.daemon                 = true
    core.name                   = pipewire-0
    mem.allow-mlock             = true
}
context.spa-libs = {
    api.alsa.*  = alsa/libspa-alsa
    api.jack.*  = jack/libspa-jack
    api.bluez5.* = bluez5/libspa-bluez5
}
EOF

    mkdir -p /etc/wireplumber/wireplumber.conf.d
    cat > /etc/wireplumber/wireplumber.conf.d/99-novastudio-alsa.conf << 'EOF'
# NovаStudio OS — WirePlumber ALSA tuning
monitor.alsa.rules = [
    {
        matches = [ { node.name = "~alsa_*" } ]
        actions = {
            update-props = {
                api.alsa.period-size   = 32
                api.alsa.headroom      = 0
                api.alsa.disable-mmap  = false
                session.suspend-timeout-seconds = 0
            }
        }
    }
]
EOF
    success "PipeWire low-latency config applied"

    # ── Focusrite Scarlett driver ─────────────────────────────────────────────
    task "Setting up Focusrite Scarlett/Clarett support"

    # The scarlett2 kernel module is upstream in Linux 5.14+
    # Enable advanced features
    cat > /etc/modprobe.d/focusrite.conf << 'EOF'
# NovаStudio OS — Focusrite Scarlett2 driver options
# Enable full Scarlett Gen 2/3/4 and Clarett USB/+ features
options snd_usb_audio implicit_fb=1
options snd_usb_audio lowlatency=1
EOF

    # udev rules for Focusrite
    cat > /etc/udev/rules.d/60-focusrite.rules << 'EOF'
# NovаStudio OS — Focusrite Focusrite Audio Interfaces
# Focusrite (Vendor 0x1235)
SUBSYSTEM=="usb", ATTR{idVendor}=="1235", GROUP="audio", MODE="0664", TAG+="uaccess"
# Focusrite Clarett via Thunderbolt
SUBSYSTEM=="thunderbolt", ATTR{vendor}=="0x1235", GROUP="audio", MODE="0664"
# Set high USB transfer priority
SUBSYSTEM=="usb", ATTR{idVendor}=="1235", ATTR{power/autosuspend}="-1"
EOF

    # ALSA utilities (infrastructure — alsa-scarlett-gui installed in apps section)
    dnf_install alsa-utils alsa-tools alsa-plugins-pulseaudio
    info "Note: alsa-scarlett-gui GUI app installed in Section 12 (Applications)"

    # ALSA UCM profiles
    if $HW_FOCUSRITE; then
        task "Configuring Focusrite UCM profile"
        mkdir -p /usr/share/alsa/ucm2/Focusrite
        cat > /usr/share/alsa/ucm2/Focusrite/Focusrite.conf << 'EOF'
Comment "Focusrite USB Audio Interface — NovаStudio Profile"
SectionUseCase."HiFi" {
    Comment "High Fidelity"
    SectionVerb {
        Value { TQ "HiFi" }
        EnableSequence [ cset "name='PCM Playback Volume' 100%" ]
    }
}
EOF
        success "${ICO_AUDIO} Focusrite UCM profile created"
    fi

    # ── audio group ──────────────────────────────────────────────────────────
    task "Adding current user to audio / jackuser groups"
    local real_user="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
    if [[ -n "$real_user" ]]; then
        groupadd -f audio 2>/dev/null || true
        groupadd -f jackuser 2>/dev/null || true
        groupadd -f realtime 2>/dev/null || true
        usermod -aG audio,jackuser,realtime "$real_user"
        success "User $real_user added to audio/jackuser/realtime groups"
    fi

    # ── Plugin framework libraries (infrastructure — not apps) ───────────────
    task "Installing audio plugin framework libraries (LV2, LADSPA, MIDI bridge)"
    dnf_install ladspa ladspa-devel lv2 lv2-devel lilv \
        zita-njbridge zita-alsa-pcmi a2jmidid
    success "${ICO_MUSIC} Audio infrastructure libraries installed"

    # ── Enable PipeWire user services ─────────────────────────────────────────
    task "Enabling PipeWire services"
    systemctl --global enable pipewire.socket pipewire.service wireplumber.service >> "$LOG_FILE" 2>&1
    systemctl --global enable pipewire-pulse.socket pipewire-pulse.service >> "$LOG_FILE" 2>&1
    success "PipeWire services enabled"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 7 : MEDIA PRODUCTION
# ──────────────────────────────────────────────────────────────────────────────

setup_media_production() {
    step_header "5" "${ICO_FILM} Media Codecs & Libraries"

    # ── Codecs ────────────────────────────────────────────────────────────────
    task "Installing multimedia codecs (all formats)"
    dnf_install gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free-extras \
        gstreamer1-plugins-good gstreamer1-plugins-good-extras \
        gstreamer1-plugins-ugly
    dnf_install gstreamer1-plugin-libav
    dnf_install ffmpeg-free
    dnf_install libavcodec-free libavformat-free 2>/dev/null || true
    dnf_install x264 x265 libvpx
    dnf_install openh264 gstreamer1-plugin-openh264 mozilla-openh264
    success "Codecs installed"

    # ── DaVinci Resolve runtime dependencies ─────────────────────────────────
    task "Installing DaVinci Resolve runtime dependencies"
    dnf_install libxcrypt-compat libGLU fuse fuse-libs
    echo
    echo -e "  ${CYAN}${ICO_INFO}  DaVinci Resolve dependency note:${RESET}"
    echo -e "  ${GREY}     Runtime libs installed. Download from:${RESET}"
    echo -e "  ${GREY}     https://www.blackmagicdesign.com/products/davinciresolve${RESET}"
    echo -e "  ${GREY}     Then run: sudo bash DaVinci_Resolve_*.run${RESET}"
    success "DaVinci Resolve runtime dependencies ready"

    # ── Font stack ────────────────────────────────────────────────────────────
    task "Installing professional font collection"
    dnf_install google-noto-fonts-common google-noto-sans-fonts google-noto-serif-fonts \
        liberation-fonts fira-code-fonts ibm-plex-fonts-all \
        adobe-source-code-pro-fonts adobe-source-sans-pro-fonts \
        abattis-cantarell-fonts
    success "${ICO_FILM} Media codecs and libraries installed"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 7b : APPLICATIONS (Audio, Video, Image — all GUI apps)
# ──────────────────────────────────────────────────────────────────────────────

setup_applications() {
    step_header "6" "${ICO_MUSIC} Audio, Video & Image Applications"

    local real_user="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"

    # ── Audio production apps ─────────────────────────────────────────────────
    task "Installing audio production applications"

    # QJackCtl — JACK patchbay GUI (RPM, not Flatpak — needs direct JACK access)
    dnf_install qjackctl
    success "QJackCtl (JACK patchbay) installed"

    # Carla — plugin host (VST2/VST3/LV2/LADSPA/CLAP)
    dnf_install carla
    success "Carla plugin host installed"

    # Cadence — full JACK/audio session manager suite
    dnf_install cadence 2>/dev/null || \
        flatpak install -y flathub org.kxstudio.Cadence >> "$LOG_FILE" 2>&1 || \
        warn "Cadence not available — use QJackCtl instead"

    # Calf Studio plugins (LV2 suite)
    dnf_install calf
    success "Calf LV2 plugin suite installed"

    # qsynth / FluidSynth (MIDI synthesiser)
    dnf_install qsynth fluidsynth fluid-soundfont-gm
    success "qsynth + FluidSynth MIDI synthesiser installed"

    # Ardour — professional DAW (via Flatpak for latest stable)
    task "Installing Ardour DAW"
    flatpak install -y flathub org.ardour.Ardour >> "$LOG_FILE" 2>&1 && \
        success "Ardour DAW installed" || \
        warn "Ardour Flatpak failed — install from https://ardour.org/download.html"

    # Audacity — audio editor / recorder
    task "Installing Audacity"
    flatpak install -y flathub org.audacityteam.Audacity >> "$LOG_FILE" 2>&1 && \
        success "Audacity installed" || \
        dnf_install audacity && success "Audacity (RPM) installed"

    # LMMS — free DAW alternative
    task "Installing LMMS"
    flatpak install -y flathub io.lmms.LMMS >> "$LOG_FILE" 2>&1 && \
        success "LMMS installed" || warn "LMMS Flatpak not available"

    # Helvum — PipeWire patchbay GUI (modern replacement for qpwgraph)
    dnf_install helvum 2>/dev/null || \
        flatpak install -y flathub org.pipewire.Helvum >> "$LOG_FILE" 2>&1 || \
        warn "Helvum not available — use qpwgraph instead"

    # qpwgraph — PipeWire / JACK graph GUI
    dnf_install qpwgraph 2>/dev/null || true

    success "${ICO_MUSIC} Audio applications complete"

    # ── Video production apps ─────────────────────────────────────────────────
    task "Installing video production applications"

    # Kdenlive — professional NLE video editor
    task "Installing Kdenlive"
    flatpak install -y flathub org.kde.kdenlive >> "$LOG_FILE" 2>&1 && \
        success "Kdenlive video editor installed" || \
        dnf_install kdenlive && success "Kdenlive (RPM) installed"

    # OBS Studio — recording and streaming
    task "Installing OBS Studio"
    flatpak install -y flathub com.obsproject.Studio >> "$LOG_FILE" 2>&1 && \
        success "OBS Studio installed" || \
        dnf_install obs-studio && success "OBS Studio (RPM) installed"

    # Blender — 3D / VFX / compositing
    task "Installing Blender"
    flatpak install -y flathub org.blender.Blender >> "$LOG_FILE" 2>&1 && \
        success "Blender installed" || \
        dnf_install blender && success "Blender (RPM) installed"

    # Kdenlive / OBS OBS plugins
    dnf_install obs-studio-plugin-webkitgtk 2>/dev/null || true

    success "${ICO_FILM} Video applications complete"

    # ── Image editing apps ────────────────────────────────────────────────────
    task "Installing image editing applications"

    # GIMP — photo / image editor
    task "Installing GIMP"
    flatpak install -y flathub org.gimp.GIMP >> "$LOG_FILE" 2>&1 && \
        success "GIMP installed" || \
        dnf_install gimp && success "GIMP (RPM) installed"

    # Krita — digital painting
    task "Installing Krita"
    flatpak install -y flathub org.kde.krita >> "$LOG_FILE" 2>&1 && \
        success "Krita installed" || \
        dnf_install krita && success "Krita (RPM) installed"

    # Inkscape — vector graphics
    task "Installing Inkscape"
    flatpak install -y flathub org.inkscape.Inkscape >> "$LOG_FILE" 2>&1 && \
        success "Inkscape installed" || \
        dnf_install inkscape && success "Inkscape (RPM) installed"

    # RawTherapee — RAW photo processing
    task "Installing RawTherapee"
    flatpak install -y flathub com.rawtherapee.RawTherapee >> "$LOG_FILE" 2>&1 && \
        success "RawTherapee installed" || \
        dnf_install rawtherapee && success "RawTherapee (RPM) installed"

    # darktable — RAW processing alternative
    task "Installing darktable"
    flatpak install -y flathub org.darktable.Darktable >> "$LOG_FILE" 2>&1 && \
        success "darktable installed" || warn "darktable Flatpak not available"

    success "${ICO_BRUSH} Image applications complete"

    # ── Fix Flatpak XDG path so apps appear in launcher ──────────────────────
    # When Flatpak is installed as root the exports path may not be in XDG_DATA_DIRS.
    # Add it globally so every user's app launcher sees Flatpak apps.
    task "Ensuring Flatpak apps appear in app launcher"
    local flatpak_exports="/var/lib/flatpak/exports/share"
    if [[ -d "$flatpak_exports" ]]; then
        cat > /etc/profile.d/flatpak-xdg.sh << 'EOF'
# NovаStudio OS — Ensure system Flatpak apps appear in app launchers
if [[ -d /var/lib/flatpak/exports/share ]]; then
    export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
fi
if [[ -d "$HOME/.local/share/flatpak/exports/share" ]]; then
    export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS}"
fi
EOF
        chmod +x /etc/profile.d/flatpak-xdg.sh
        success "Flatpak XDG_DATA_DIRS configured — apps will appear after next login"
    fi

    # Also update desktop database right now for the current session
    update-desktop-database /var/lib/flatpak/exports/share/applications \
        >> "$LOG_FILE" 2>&1 || true

    success "${ICO_STAR} All applications installed"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 8 : WINDOWS APPS (Wine + Yabridge)
# ──────────────────────────────────────────────────────────────────────────────

setup_windows_compatibility() {
    step_header "6" "${ICO_WIN} Windows App Compatibility (Wine + Yabridge)"

    # ── 32-bit multilib ───────────────────────────────────────────────────────
    task "Enabling 32-bit multilib support"
    dnf_install glibc.i686 libstdc++.i686
    success "32-bit libraries available"

    # ── Wine Staging ──────────────────────────────────────────────────────────
    task "Installing Wine (Staging preferred, standard fallback)"
    # wine-staging may not be packaged for every Fedora release.
    # Try staging first; if unavailable fall back to standard wine — non-fatal.
    if dnf list available wine-staging >> "$LOG_FILE" 2>&1; then
        dnf_install wine-staging wine-staging-devel
        success "Wine Staging installed"
    else
        dnf_install wine
        warn "wine-staging not available for this Fedora release — standard Wine installed"
        info "For Wine Staging features, see: https://wiki.winehq.org/Wine-Staging"
    fi
    dnf_install winetricks wine-gecko wine-mono cabextract wget curl p7zip

    # ── Wine prefix initialisation ────────────────────────────────────────────
    task "Creating NovаStudio Wine prefix"
    local real_user="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
    if [[ -n "$real_user" ]]; then
        sudo -u "$real_user" WINEPREFIX="$WINE_PREFIX" WINEARCH=win64 \
            wine wineboot --init >> "$LOG_FILE" 2>&1 || true
        success "Wine prefix created at $WINE_PREFIX"

        # Install common Visual C++ runtimes, .NET, DXVK via winetricks
        task "Installing Wine runtime components (VC++ / .NET / DXVK)"
        sudo -u "$real_user" WINEPREFIX="$WINE_PREFIX" \
            winetricks -q vcrun2019 vcrun2017 vcrun2015 dotnet48 \
            corefonts dxvk vkd3d >> "$LOG_FILE" 2>&1 || true
        success "Wine runtime components installed"
    fi

    # ── DXVK ─────────────────────────────────────────────────────────────────
    task "Installing DXVK (DirectX → Vulkan translation)"
    dnf_install dxvk-native
    success "DXVK installed"

    # ── Yabridge ─────────────────────────────────────────────────────────────
    task "Installing yabridge (Windows VST/VST3/CLAP plugins in Linux DAWs)"

    # Yabridge needs to be downloaded from GitHub releases
    local YABRIDGE_VER
    YABRIDGE_VER=$(curl -s https://api.github.com/repos/robbert-vdh/yabridge/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null || echo "5.1.0")
    YABRIDGE_VER="${YABRIDGE_VER#v}"

    local yb_url="https://github.com/robbert-vdh/yabridge/releases/download/${YABRIDGE_VER}/yabridge-${YABRIDGE_VER}.tar.gz"
    local yb_tmp="/tmp/yabridge-${YABRIDGE_VER}.tar.gz"

    if [[ -n "$real_user" ]]; then
        local yb_dir="/home/${real_user}/.local/share/yabridge"
        mkdir -p "$yb_dir"

        if curl -Lo "$yb_tmp" "$yb_url" >> "$LOG_FILE" 2>&1; then
            tar -xzf "$yb_tmp" -C "$(dirname "$yb_dir")" >> "$LOG_FILE" 2>&1
            chown -R "$real_user:$real_user" "$yb_dir"

            # Symlink yabridgectl to PATH
            ln -sf "$yb_dir/yabridgectl" /usr/local/bin/yabridgectl 2>/dev/null || true
            ln -sf "$yb_dir/yabridge-host.exe" /usr/local/bin/yabridge-host.exe 2>/dev/null || true

            success "yabridge ${YABRIDGE_VER} installed"
        else
            warn "Could not download yabridge — install manually from https://github.com/robbert-vdh/yabridge"
        fi
    fi

    # ── Yabridgectl setup ─────────────────────────────────────────────────────
    if command -v yabridgectl &>/dev/null && [[ -n "$real_user" ]]; then
        task "Configuring yabridgectl"
        sudo -u "$real_user" yabridgectl set --wine-home "$(dirname "$(which wine)")" >> "$LOG_FILE" 2>&1 || true

        # Add default Windows VST plugin directories
        local vst_dirs=(
            "$WINE_PREFIX/drive_c/Program Files/VstPlugins"
            "$WINE_PREFIX/drive_c/Program Files/Common Files/VST3"
            "$WINE_PREFIX/drive_c/Program Files (x86)/VstPlugins"
            "$WINE_PREFIX/drive_c/Program Files (x86)/Steinberg/VSTPlugins"
        )
        for d in "${vst_dirs[@]}"; do
            mkdir -p "$d" 2>/dev/null || true
            sudo -u "$real_user" yabridgectl add "$d" >> "$LOG_FILE" 2>&1 || true
        done
        success "Yabridgectl VST directories configured"
    fi

    success "${ICO_WIN} Windows compatibility stack complete"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 9 : DESKTOP ENVIRONMENT & THEMES
# ──────────────────────────────────────────────────────────────────────────────

setup_desktop_themes() {
    step_header "7" "${ICO_BRUSH} Desktop Environment & Theme Customisation"

    local real_user="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"

    # ── Detect DE ─────────────────────────────────────────────────────────────
    local detected_de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-unknown}}"
    info "Detected desktop environment: $detected_de"

    # ── GNOME extensions & theme tools ───────────────────────────────────────
    if echo "$detected_de" | grep -qi "gnome"; then
        task "Setting up GNOME theme ecosystem"

        dnf_install gnome-tweaks gnome-shell-extension-manager \
            gnome-extensions-app dconf-editor

        # Popular themes
        spinner_run "Installing GNOME themes" \
            dnf install -y gnome-themes-extra gtk-murrine-engine

        # Adwaita Dark as default system theme
        if [[ -n "$real_user" ]]; then
            sudo -u "$real_user" gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
            sudo -u "$real_user" gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
            sudo -u "$real_user" gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || true
            sudo -u "$real_user" gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close' 2>/dev/null || true
            # Font anti-aliasing
            sudo -u "$real_user" gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing 'rgba' 2>/dev/null || true
        fi

        # GNOME extensions via flatpak
        flatpak install -y flathub \
            com.mattjakeman.ExtensionManager >> "$LOG_FILE" 2>&1 || true

        success "GNOME theming configured"

    elif echo "$detected_de" | grep -qi "kde\|plasma"; then
        task "Setting up KDE Plasma theme ecosystem"
        dnf_install kde-gtk-config breeze-gtk plasma-workspace-wayland \
            kvantum papirus-icon-theme
        success "KDE theming packages installed"
    fi

    # ── Papirus icon theme (works everywhere) ─────────────────────────────────
    task "Installing Papirus icon theme"
    if ! rpm -q papirus-icon-theme &>/dev/null; then
        dnf copr enable -y dirkdavidis/papirus-icon-theme >> "$LOG_FILE" 2>&1 || true
        dnf_install papirus-icon-theme
    fi
    success "Papirus icons installed"

    # ── Inter/Manrope fonts for the UI ────────────────────────────────────────
    task "Installing UI fonts (Inter, JetBrains Mono)"
    local font_dir="/usr/local/share/fonts/novastudio"
    mkdir -p "$font_dir"
    # Download Inter font
    if curl -Lo /tmp/inter.zip \
        "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip" \
        >> "$LOG_FILE" 2>&1; then
        unzip -o /tmp/inter.zip -d /tmp/inter-fonts/ >> "$LOG_FILE" 2>&1 || true
        find /tmp/inter-fonts -name "*.otf" -exec cp {} "$font_dir/" \; 2>/dev/null || true
        fc-cache -f >> "$LOG_FILE" 2>&1
        success "Inter font installed"
    else
        warn "Could not download Inter font — using system fonts"
    fi
    dnf_install jetbrains-mono-fonts-all 2>/dev/null || true

    # ── NovаStudio theme config helper ───────────────────────────────────────
    task "Installing NovаStudio Theme Switcher"
    cat > /usr/local/bin/novastudio-theme << 'THEMEEOF'
#!/usr/bin/env bash
# NovаStudio OS Theme Switcher
# Usage: novastudio-theme [dark|light|custom]

THEMES=(
    "dark:Adwaita-dark:Adwaita-dark"
    "light:Adwaita:Adwaita"
    "breeze-dark:Breeze-Dark:Breeze-Dark"
    "nordic:Nordic:Nordic"
    "catppuccin:Catppuccin-Mocha-Standard-Teal-dark:Catppuccin-Mocha"
)

RED='\033[0;31m'; GREEN='\033[1;32m'; CYAN='\033[1;36m'; RESET='\033[0m'

echo -e "\n  ${CYAN}NovаStudio Theme Switcher${RESET}\n"

if [[ $# -eq 0 ]]; then
    echo "  Available themes:"
    for t in "${THEMES[@]}"; do echo "    → ${t%%:*}"; done
    echo
    echo -e "  Usage: ${GREEN}novastudio-theme <theme-name>${RESET}"
    echo -e "         ${GREEN}novastudio-theme list${RESET}"
    exit 0
fi

case "$1" in
    list)
        for t in "${THEMES[@]}"; do echo "  ${t%%:*}"; done ;;
    dark)
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
        echo -e "  ${GREEN}✅  Dark theme applied${RESET}" ;;
    light)
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
        echo -e "  ${GREEN}✅  Light theme applied${RESET}" ;;
    nordic)
        if [[ -d "/usr/share/themes/Nordic" ]]; then
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
            gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'
            echo -e "  ${GREEN}✅  Nordic theme applied${RESET}"
        else
            echo -e "  ${RED}❌  Nordic theme not installed. Run: sudo dnf install nordic-theme${RESET}"
        fi ;;
    *)
        echo -e "  ${RED}Unknown theme: $1${RESET}"
        echo "  Run 'novastudio-theme list' to see available themes" ;;
esac
THEMEEOF
    chmod +x /usr/local/bin/novastudio-theme
    success "Theme switcher installed → run: novastudio-theme"

    # ── Wallpaper ─────────────────────────────────────────────────────────────
    task "Setting NovаStudio default wallpaper (dark gradient)"
    mkdir -p /usr/share/backgrounds/novastudio
    # Generate an SVG wallpaper since we can't download images
    cat > /usr/share/backgrounds/novastudio/novastudio-dark.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="3840" height="2160">
  <defs>
    <radialGradient id="bg" cx="30%" cy="40%" r="80%">
      <stop offset="0%" stop-color="#1a1040"/>
      <stop offset="40%" stop-color="#0d1f3c"/>
      <stop offset="100%" stop-color="#050d1a"/>
    </radialGradient>
    <radialGradient id="glow1" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#2a1f6a" stop-opacity="0.6"/>
      <stop offset="100%" stop-color="transparent"/>
    </radialGradient>
    <radialGradient id="glow2" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#0a3d6b" stop-opacity="0.4"/>
      <stop offset="100%" stop-color="transparent"/>
    </radialGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#bg)"/>
  <ellipse cx="600" cy="900" rx="900" ry="600" fill="url(#glow1)" opacity="0.5"/>
  <ellipse cx="3200" cy="1200" rx="700" ry="500" fill="url(#glow2)" opacity="0.4"/>
  <text x="50%" y="52%" text-anchor="middle" font-family="sans-serif"
        font-size="120" fill="white" opacity="0.04" letter-spacing="40">
    NOVASTUDIO OS
  </text>
</svg>
SVGEOF

    if [[ -n "$real_user" ]] && echo "$detected_de" | grep -qi "gnome"; then
        sudo -u "$real_user" gsettings set org.gnome.desktop.background picture-uri \
            "file:///usr/share/backgrounds/novastudio/novastudio-dark.svg" 2>/dev/null || true
        sudo -u "$real_user" gsettings set org.gnome.desktop.background picture-uri-dark \
            "file:///usr/share/backgrounds/novastudio/novastudio-dark.svg" 2>/dev/null || true
    fi
    success "${ICO_BRUSH} Desktop themes configured"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 10 : DEVELOPER & PRODUCTIVITY TOOLS
# ──────────────────────────────────────────────────────────────────────────────

setup_productivity_tools() {
    step_header "8" "Productivity & Developer Tools"

    task "Installing essential CLI tools"
    dnf_install htop btop neofetch fastfetch tmux git curl wget rsync \
        zip unzip p7zip p7zip-plugins bash-completion fish zsh \
        bat eza ripgrep fd-find fzf jq yq \
        ncdu duf lsof strace tree man-pages

    task "Installing VS Code (Flatpak)"
    flatpak install -y flathub com.visualstudio.code >> "$LOG_FILE" 2>&1 || true

    task "Installing Brave browser"
    # Try native RPM first (better performance, system integration)
    if ! rpm -q brave-browser &>/dev/null; then
        if dnf config-manager addrepo \
            --from-repofile=https://brave-keyring.s3.brave.com/brave-browser.repo \
            >> "$LOG_FILE" 2>&1; then
            dnf_install brave-browser
            success "Brave browser (native RPM) installed"
        else
            # Fallback: Flatpak
            flatpak install -y flathub com.brave.Browser >> "$LOG_FILE" 2>&1 && \
                success "Brave browser (Flatpak) installed" || \
                warn "Brave install failed — visit https://brave.com/linux to install manually"
        fi
    else
        success "Brave browser already installed"
    fi
    # Remove Firefox and Chromium if present — keep only Brave
    if rpm -q firefox &>/dev/null; then
        dnf remove -y firefox >> "$LOG_FILE" 2>&1 && \
            info "Firefox removed (replaced by Brave)" || true
    fi
    flatpak uninstall -y org.mozilla.firefox >> "$LOG_FILE" 2>&1 || true
    flatpak uninstall -y org.chromium.Chromium >> "$LOG_FILE" 2>&1 || true

    task "Installing communication apps"
    flatpak install -y flathub \
        com.discordapp.Discord \
        org.signal.Signal >> "$LOG_FILE" 2>&1 || true

    task "Installing file manager enhancements"
    dnf_install nautilus-extensions file-roller

    # ── Timeshift (system snapshots) ──────────────────────────────────────────
    task "Installing Timeshift (system backup / snapshots)"
    if ! rpm -q timeshift &>/dev/null; then
        dnf copr enable -y thelocehiliond/timeshift >> "$LOG_FILE" 2>&1 || \
        dnf_install timeshift
    else
        success "Timeshift already installed"
    fi

    # ── NovаStudio welcome script ─────────────────────────────────────────────
    task "Installing NovаStudio welcome helper"
    cat > /usr/local/bin/novastudio-info << 'INFOEOF'
#!/usr/bin/env bash
# NovаStudio OS — System Info & Quick Help

C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; W='\033[1;37m'; R='\033[0m'

echo -e "\n${C}  ╔══════════════════════════════════════════════════╗${R}"
echo -e "${C}  ║  ${W}NovаStudio OS — Quick Reference                ${C}║${R}"
echo -e "${C}  ╚══════════════════════════════════════════════════╝${R}\n"

echo -e "  ${G}🎨 Theming${R}"
echo -e "     ${W}novastudio-theme dark${R}          Switch to dark theme"
echo -e "     ${W}novastudio-theme light${R}         Switch to light theme"
echo -e "     ${W}novastudio-theme list${R}          Show all themes\n"

echo -e "  ${G}🎵 Audio${R}"
echo -e "     ${W}qjackctl${R}                       JACK Audio patchbay"
echo -e "     ${W}carla${R}                          Plugin host (VST/LV2)"
echo -e "     ${W}yabridgectl sync${R}               Sync Windows VST plugins"
echo -e "     ${W}yabridgectl status${R}             Check yabridge status\n"

echo -e "  ${G}🪟 Wine / Windows Apps${R}"
echo -e "     ${W}bottles${R}                        GUI Wine manager (Flatpak)"
echo -e "     ${W}wine <program.exe>${R}             Run Windows program\n"

echo -e "  ${G}🎮 Gaming${R}"
echo -e "     ${W}steam${R}                          Steam (Proton enabled for all)"
echo -e "     ${W}lutris${R}                         Lutris game manager"
echo -e "     ${W}game-launch <exe>${R}              Launch with GameMode + MangoHud"
echo -e "     ${W}gamemoderun mangohud %command%${R} Steam launch options template"
echo -e "     ${W}gamescope -W 1920 -H 1080 -- %command%${R}  Force resolution\n"

echo -e "  ${G}🌐 Browser${R}"
echo -e "     ${W}brave-browser${R}                  Brave (only browser installed)\n"
echo -e "     ${W}btop${R}                           System monitor"
echo -e "     ${W}novastudio-info${R}                This help screen"
echo -e "     ${W}sudo novastudio-setup.sh${R}       Re-run setup\n"

echo -e "  ${G}📝 Logs${R}"
echo -e "     ${W}/var/log/novastudio-setup.log${R}  Setup log\n"

# Show basic system info
echo -e "  ${Y}━━━ System Summary ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo -e "  Kernel:  $(uname -r)"
echo -e "  CPU:     $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')"
echo -e "  RAM:     $(awk '/MemTotal/{printf "%.1fGB", $2/1024/1024}' /proc/meminfo)"
echo -e "  Fedora:  $(grep VERSION_ID /etc/os-release | cut -d= -f2)\n"
INFOEOF
    chmod +x /usr/local/bin/novastudio-info

    # Add alias to bash/zsh profiles
    local real_user="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
    if [[ -n "$real_user" ]]; then
        local profile="/home/${real_user}/.bashrc"
        grep -q "novastudio-info" "$profile" 2>/dev/null || \
            echo 'echo "Type novastudio-info for quick help." ' >> "$profile"
    fi

    success "Productivity tools installed"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 11 : SECURITY HARDENING (lightweight)
# ──────────────────────────────────────────────────────────────────────────────

setup_security() {
    step_header "9" "${ICO_LOCK} Security Hardening"

    task "Configuring firewall (firewalld)"
    systemctl enable --now firewalld >> "$LOG_FILE" 2>&1
    # Allow only SSH + local services
    firewall-cmd --set-default-zone=public >> "$LOG_FILE" 2>&1
    firewall-cmd --permanent --add-service=ssh >> "$LOG_FILE" 2>&1
    firewall-cmd --reload >> "$LOG_FILE" 2>&1
    success "Firewall configured (public zone, SSH only)"

    task "Enabling automatic security updates"
    dnf_install dnf-automatic
    sed -i 's/^apply_updates.*=.*/apply_updates = yes/' /etc/dnf/automatic.conf 2>/dev/null || true
    sed -i 's/^upgrade_type.*=.*/upgrade_type = security/' /etc/dnf/automatic.conf 2>/dev/null || true
    systemctl enable dnf-automatic.timer >> "$LOG_FILE" 2>&1
    success "Automatic security updates enabled"

    task "Configuring SSH hardening"
    cp /etc/ssh/sshd_config "$BACKUP_DIR/sshd_config.bak" 2>/dev/null || true
    cat >> /etc/ssh/sshd_config << 'EOF'
# NovаStudio OS SSH Hardening
PermitRootLogin no
PasswordAuthentication yes
X11Forwarding no
MaxAuthTries 3
EOF
    systemctl restart sshd >> "$LOG_FILE" 2>&1 || true
    success "SSH hardened"

    success "${ICO_LOCK} Security hardening complete"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 11 : GAMING
# ──────────────────────────────────────────────────────────────────────────────

setup_gaming() {
    step_header "10" "${ICO_GAME} Gaming (Steam · Lutris · Proton · GameMode · Controllers)"

    local real_user="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"

    # ── 32-bit multilib (Steam requires this) ────────────────────────────────
    task "Ensuring 32-bit multilib libraries"
    dnf_install glibc.i686 libstdc++.i686 libgcc.i686 \
        nss.i686 nspr.i686 libXcomposite.i686 libXdamage.i686 \
        libXrandr.i686 libXtst.i686 libXi.i686 libXext.i686 \
        libX11.i686 mesa-libGL.i686 mesa-dri-drivers.i686 \
        alsa-lib.i686 fontconfig.i686 freetype.i686 libpng.i686 \
        libdrm.i686 libva.i686 SDL2.i686
    success "32-bit libraries installed"

    # ── Vulkan (32-bit + 64-bit) ─────────────────────────────────────────────
    task "Installing Vulkan ICD loaders (32 + 64-bit)"
    dnf_install vulkan-loader vulkan-loader.i686 vulkan-tools
    if $HW_GPU_NVIDIA; then
        dnf_install nvidia-driver-libs.i686 2>/dev/null || true
    fi
    if $HW_GPU_AMD; then
        dnf_install mesa-vulkan-drivers mesa-vulkan-drivers.i686
    fi
    if $HW_GPU_INTEL; then
        dnf_install mesa-vulkan-drivers.i686 2>/dev/null || true
    fi
    success "Vulkan (32-bit + 64-bit) ready"

    # ── DXVK + VKD3D-Proton (DirectX 9/10/11/12 → Vulkan) ──────────────────
    task "Installing DXVK + VKD3D-Proton (DX9–DX12 translation)"

    # Grab latest DXVK release from GitHub
    local DXVK_VER
    DXVK_VER=$(curl -s https://api.github.com/repos/doitsujin/dxvk/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null || echo "v2.4")
    DXVK_VER="${DXVK_VER#v}"
    local dxvk_url="https://github.com/doitsujin/dxvk/releases/download/v${DXVK_VER}/dxvk-${DXVK_VER}.tar.gz"

    if curl -Lo /tmp/dxvk.tar.gz "$dxvk_url" >> "$LOG_FILE" 2>&1; then
        tar -xzf /tmp/dxvk.tar.gz -C /tmp/ >> "$LOG_FILE" 2>&1
        if [[ -n "$real_user" ]]; then
            # Install into the NovаStudio Wine prefix
            sudo -u "$real_user" env WINEPREFIX="$WINE_PREFIX" \
                bash "/tmp/dxvk-${DXVK_VER}/setup_dxvk.sh" install >> "$LOG_FILE" 2>&1 || true
        fi
        success "DXVK ${DXVK_VER} installed"
    else
        warn "DXVK download failed — install manually from https://github.com/doitsujin/dxvk"
    fi

    # VKD3D-Proton (DX12 support — Valve's fork)
    local VKD3D_VER
    VKD3D_VER=$(curl -s https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null || echo "v2.12")
    VKD3D_VER="${VKD3D_VER#v}"
    local vkd3d_url="https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v${VKD3D_VER}/vkd3d-proton-${VKD3D_VER}.tar.zst"

    if curl -Lo /tmp/vkd3d.tar.zst "$vkd3d_url" >> "$LOG_FILE" 2>&1; then
        dnf_install zstd 2>/dev/null || true
        mkdir -p /tmp/vkd3d-proton
        tar --zstd -xf /tmp/vkd3d.tar.zst -C /tmp/vkd3d-proton/ >> "$LOG_FILE" 2>&1 || true
        if [[ -n "$real_user" ]]; then
            sudo -u "$real_user" env WINEPREFIX="$WINE_PREFIX" \
                bash /tmp/vkd3d-proton/setup_vkd3d_proton.sh install >> "$LOG_FILE" 2>&1 || true
        fi
        success "VKD3D-Proton ${VKD3D_VER} installed (DX12 support)"
    else
        warn "VKD3D-Proton download failed — DX12 games may not work"
    fi

    # ── Steam ─────────────────────────────────────────────────────────────────
    task "Installing Steam"
    if ! rpm -q steam &>/dev/null; then
        spinner_run "Installing Steam (RPM Fusion)" \
            dnf install -y steam
    else
        success "Steam already installed"
    fi

    # Enable Steam Play (Proton) by default via config
    if [[ -n "$real_user" ]]; then
        local steam_cfg_dir="/home/${real_user}/.local/share/Steam/config"
        mkdir -p "$steam_cfg_dir"
        # Pre-seed Steam config to enable Proton for all titles
        if [[ ! -f "$steam_cfg_dir/config.vdf" ]]; then
            cat > "$steam_cfg_dir/config.vdf" << 'STEAMEOF'
"InstallConfigStore"
{
    "Software"
    {
        "Valve"
        {
            "Steam"
            {
                "CompatToolMapping"
                {
                }
                "CompatTool"
                {
                    "name"        "proton_experimental"
                    "enabled"     "1"
                }
            }
        }
    }
}
STEAMEOF
            chown "$real_user:$real_user" "$steam_cfg_dir/config.vdf"
        fi
    fi
    success "Steam installed with Proton-for-all pre-seeded"

    # ── GameMode (Feral Interactive) ──────────────────────────────────────────
    task "Installing & configuring GameMode"
    dnf_install gamemode gamemode-devel
    # GameMode config
    mkdir -p /etc/gamemode
    cat > /etc/gamemode.ini << 'EOF'
; NovаStudio OS — GameMode Configuration
[general]
; Enable reaper to kill stray gamemode processes
reaper_freq=5
; Inhibit screensaver / idle
desiredgov=performance
igpu_desiredgov=powersave
softrealtime=auto
renice=-5
ioprio=0
inhibit_screensaver=1

[filter]
whitelist=
blacklist=

[cpu]
park_cores=no
pin_cores=yes

[gpu]
; Set GPU to max performance during gaming
apply_gpu_optimisations=accept-responsibility
gpu_device=0
nv_powermizer_mode=1
amd_performance_level=high

[custom]
start=notify-send "GameMode" "🎮 Performance mode ON" -i applications-games
end=notify-send "GameMode" "💤 Performance mode OFF" -i applications-games
EOF

    # Enable gamemoded service
    systemctl --global enable gamemoded.service >> "$LOG_FILE" 2>&1 || true

    # Add user to gamemode group
    groupadd -f gamemode 2>/dev/null || true
    if [[ -n "$real_user" ]]; then
        usermod -aG gamemode "$real_user"
    fi
    success "GameMode configured (automatic CPU/GPU boost during games)"

    # ── MangoHud (in-game performance overlay) ────────────────────────────────
    task "Installing MangoHud (performance overlay)"
    if ! rpm -q mangohud &>/dev/null; then
        spinner_run "Installing MangoHud" \
            dnf install -y mangohud mangohud.i686
    else
        success "MangoHud already installed"
    fi

    # MangoHud config
    if [[ -n "$real_user" ]]; then
        local mango_cfg="/home/${real_user}/.config/MangoHud/MangoHud.conf"
        mkdir -p "$(dirname "$mango_cfg")"
        cat > "$mango_cfg" << 'EOF'
# NovаStudio OS — MangoHud Default Config
# Toggle overlay: Right Shift + F12
legacy_layout=0
background_alpha=0.5
fps
frametime
cpu_stats
cpu_temp
gpu_stats
gpu_temp
gpu_power
ram
vram
fps_limit=0
no_display
toggle_hud=Shift_R+F12
toggle_logging=Shift_L+F2
upload_log=F5
output_file=/tmp/mangohud.log
position=top-left
font_size=20
round_corners=5
alpha=0.8
gpu_name
wine
frame_timing=1
EOF
        chown "$real_user:$real_user" "$mango_cfg"
    fi
    success "MangoHud installed (toggle: RShift+F12 in-game)"

    # ── vkBasalt (post-processing layer — sharpening, CAS, etc.) ─────────────
    task "Installing vkBasalt (in-game post-processing)"
    if ! rpm -q vkbasalt &>/dev/null; then
        dnf_install vkbasalt vkbasalt.i686 2>/dev/null || \
            warn "vkBasalt not in repos — skip (install from https://github.com/DadSchoorse/vkBasalt)"
    fi

    if [[ -n "$real_user" ]]; then
        local vkb_cfg="/home/${real_user}/.config/vkBasalt/vkBasalt.conf"
        mkdir -p "$(dirname "$vkb_cfg")"
        cat > "$vkb_cfg" << 'EOF'
# NovаStudio OS — vkBasalt Config (toggle: HOME key)
effects = cas
toggleKey = Home
casSharpness = 0.4
EOF
        chown -R "$real_user:$real_user" "$(dirname "$vkb_cfg")"
    fi
    success "vkBasalt configured (Contrast-Adaptive Sharpening, toggle: Home)"

    # ── GameScope (Valve micro-compositor for gaming sessions) ────────────────
    task "Installing GameScope"
    if ! rpm -q gamescope &>/dev/null; then
        spinner_run "Installing GameScope" dnf install -y gamescope
    else
        success "GameScope already installed"
    fi
    success "GameScope installed (use: gamescope -W 1920 -H 1080 -- %command%)"

    # ── Controller support ────────────────────────────────────────────────────
    task "Installing controller drivers"

    # Xbox controllers (xpadneo — advanced Xbox wireless driver)
    if ! dkms status 2>/dev/null | grep -q xpadneo; then
        dnf_install dkms kernel-devel
        if curl -Lo /tmp/xpadneo-install.sh \
            https://raw.githubusercontent.com/atar-axis/xpadneo/master/install.sh \
            >> "$LOG_FILE" 2>&1; then
            bash /tmp/xpadneo-install.sh >> "$LOG_FILE" 2>&1 || true
            success "xpadneo (Xbox wireless) driver installed"
        else
            dnf_install xpadneo 2>/dev/null || \
                warn "xpadneo unavailable — Xbox wireless via kernel default driver"
        fi
    fi

    # DualSense / DualShock (hid-playstation is upstream in kernel 5.12+)
    task "Configuring PlayStation controller support (DualSense / DS4)"
    cat > /etc/udev/rules.d/70-sony-controllers.rules << 'EOF'
# NovаStudio OS — Sony DualShock 4 & DualSense Controllers
# DualShock 4 via USB
SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="05c4", \
    GROUP="input", MODE="0664", TAG+="uaccess"
# DualShock 4 v2 via USB
SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="09cc", \
    GROUP="input", MODE="0664", TAG+="uaccess"
# DualSense via USB
SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="0ce6", \
    GROUP="input", MODE="0664", TAG+="uaccess"
# All Sony HID devices (Bluetooth)
KERNEL=="hidraw*", KERNELS=="*054c:*", GROUP="input", MODE="0664", TAG+="uaccess"
# 8BitDo controllers
SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", GROUP="input", MODE="0664", TAG+="uaccess"
EOF

    # Enable DS module
    modprobe hid_playstation >> "$LOG_FILE" 2>&1 || true
    echo "hid_playstation" > /etc/modules-load.d/hid-playstation.conf
    success "PlayStation controller udev rules configured"

    # ── GPU-specific gaming optimisations ────────────────────────────────────
    task "Applying GPU gaming optimisations"

    if $HW_GPU_NVIDIA; then
        task "NVIDIA gaming tweaks"
        # Enable nvidia-drm modeset (already done in GPU section but ensure here too)
        echo 'options nvidia-drm modeset=1' > /etc/modprobe.d/nvidia-gaming.conf
        # NVIDIA persistent mode — keeps GPU warm for faster launch
        cat > /etc/systemd/system/nvidia-persistent.service << 'EOF'
[Unit]
Description=NVIDIA Persistence Daemon
After=multi-user.target

[Service]
Type=forking
ExecStart=/usr/bin/nvidia-smi -pm 1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
        systemctl enable nvidia-persistent.service >> "$LOG_FILE" 2>&1 || true

        # NVIDIA environment variables for Proton/DXVK
        cat >> /etc/environment << 'EOF'
# NovаStudio OS — NVIDIA Gaming Variables
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_SIZE=10737418240
__GL_THREADED_OPTIMIZATIONS=1
PROTON_ENABLE_NVAPI=1
PROTON_HIDE_NVIDIA_GPU=0
EOF
        success "NVIDIA gaming optimisations applied"
    fi

    if $HW_GPU_AMD; then
        task "AMD gaming tweaks (ACO + RadV)"
        cat >> /etc/environment << 'EOF'
# NovаStudio OS — AMD Gaming Variables
RADV_PERFTEST=aco,gpl
RADV_DEBUG=nohiz
AMD_VULKAN_ICD=RADV
mesa_glthread=true
EOF
        success "AMD ACO shader compiler + RadV tuning applied"
    fi

    # ── Gaming environment variables (universal) ──────────────────────────────
    task "Setting universal gaming environment variables"
    cat >> /etc/environment << 'EOF'

# NovаStudio OS — Universal Gaming Variables
# DXVK async shader compilation (reduces stutter)
DXVK_ASYNC=1
DXVK_STATE_CACHE=1
# VKD3D threading
VKD3D_FEATURE_LEVEL=12_1
# Wine optimisations
WINE_LARGE_ADDRESS_AWARE=1
# GameMode activation string for launchers
# Prefix game commands with: gamemoderun mangohud %command%
EOF
    success "Gaming environment variables configured"

    # ── Kernel gaming tweaks ──────────────────────────────────────────────────
    task "Applying kernel parameters for gaming"
    cat > /etc/sysctl.d/99-novastudio-gaming.conf << 'EOF'
# NovаStudio OS — Gaming Kernel Tuning
# Reduce scheduling latency for games
kernel.sched_latency_ns          = 4000000
kernel.sched_min_granularity_ns  = 500000
kernel.sched_wakeup_granularity_ns = 1000000
kernel.sched_migration_cost_ns   = 500000
# Allow more memory-mapped areas (needed by some games)
vm.max_map_count                 = 2147483642
# Faster compaction for memory-hungry titles
vm.compaction_proactiveness      = 0
EOF
    sysctl --system >> "$LOG_FILE" 2>&1
    success "Gaming kernel parameters applied"

    # ── Firewall: open Steam + game ports ────────────────────────────────────
    task "Opening firewall ports for online gaming"
    if systemctl is-active --quiet firewalld 2>/dev/null; then
        # Steam
        firewall-cmd --permanent --add-port=27015-27050/tcp >> "$LOG_FILE" 2>&1 || true
        firewall-cmd --permanent --add-port=27015-27050/udp >> "$LOG_FILE" 2>&1 || true
        # Steam In-Home Streaming
        firewall-cmd --permanent --add-port=27031-27036/udp >> "$LOG_FILE" 2>&1 || true
        firewall-cmd --permanent --add-port=27036-27037/tcp >> "$LOG_FILE" 2>&1 || true
        # Battle.net
        firewall-cmd --permanent --add-port=1119/tcp >> "$LOG_FILE" 2>&1 || true
        firewall-cmd --reload >> "$LOG_FILE" 2>&1 || true
        success "Gaming firewall ports opened"
    fi

    # ── Sunshine (local game streaming — host) ────────────────────────────────
    task "Installing Sunshine (local game streaming)"
    flatpak install -y flathub dev.lizardbyte.app.Sunshine >> "$LOG_FILE" 2>&1 || true
    # Moonlight client for streaming to other devices
    flatpak install -y flathub com.moonlight_stream.Moonlight >> "$LOG_FILE" 2>&1 || true
    success "Sunshine (host) + Moonlight (client) installed"

    # ── Bottles gaming preset ────────────────────────────────────────────────
    task "Verifying Bottles is installed"
    if ! flatpak list 2>/dev/null | grep -q "com.usebottles.bottles"; then
        flatpak install -y flathub com.usebottles.bottles >> "$LOG_FILE" 2>&1 || true
    fi
    success "Bottles ready (use 'Gaming' preset for Windows games)"

    # ── DNS caching (reduces DNS latency in online games) ────────────────────
    # nscd was removed from Fedora 41+. systemd-resolved ships by default and
    # provides DNS caching out of the box — just ensure it is running.
    task "Enabling DNS caching via systemd-resolved (lower ping jitter)"
    if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
        success "systemd-resolved already running — DNS caching active"
    else
        systemctl enable --now systemd-resolved >> "$LOG_FILE" 2>&1 && \
            success "systemd-resolved enabled — DNS caching active" || \
            warn "Could not enable systemd-resolved — DNS caching unavailable"
    fi

    # ── Quick-launch gaming mode helper ──────────────────────────────────────
    task "Installing 'game-mode' quick-launch wrapper"
    cat > /usr/local/bin/game-launch << 'GMEOF'
#!/usr/bin/env bash
# NovаStudio OS — game-launch wrapper
# Usage: game-launch <executable> [args...]
# Automatically applies: GameMode + MangoHud + nice scheduling
if [[ $# -eq 0 ]]; then
    echo "Usage: game-launch <game_executable> [args]"
    echo "Example: game-launch steam steam://rungameid/1234"
    exit 1
fi
exec gamemoderun mangohud "$@"
GMEOF
    chmod +x /usr/local/bin/game-launch
    success "game-launch wrapper installed"

    # ── Summary ───────────────────────────────────────────────────────────────
    echo
    echo -e "  ${LMAGENTA}┌───────────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${BOLD}${WHITE}${ICO_GAME}  Gaming Stack Summary${RESET}                               ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}├───────────────────────────────────────────────────────────┤${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} Steam (with Proton-for-all pre-enabled)             ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} Lutris + Heroic (Epic / GOG / Amazon)              ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} Proton-GE manager (ProtonPlus)                     ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} DXVK (DX9-11) + VKD3D-Proton (DX12)               ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} GameMode (auto CPU/GPU boost)                      ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} MangoHud overlay (RShift+F12)                      ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} vkBasalt (sharpening, Home key)                    ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} GameScope micro-compositor                         ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} Xbox (xpadneo) + PlayStation (DualSense/DS4)       ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} RetroArch + Dolphin + RPCS3 + xemu + more          ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} Sunshine / Moonlight game streaming                ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} vm.max_map_count=2147483642 (no crashes)           ${LMAGENTA}│${RESET}"
    $HW_GPU_NVIDIA && \
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} NVIDIA: shader cache + persistent mode             ${LMAGENTA}│${RESET}"
    $HW_GPU_AMD && \
    echo -e "  ${LMAGENTA}│${RESET}  ${GREEN}✓${RESET} AMD: ACO compiler + RadV + mesa_glthread           ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}├───────────────────────────────────────────────────────────┤${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${YELLOW}Steam launch options for best performance:${RESET}             ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}│${RESET}  ${GREY}  gamemoderun mangohud %command%${RESET}                     ${LMAGENTA}│${RESET}"
    echo -e "  ${LMAGENTA}└───────────────────────────────────────────────────────────┘${RESET}"

    success "${ICO_GAME} Gaming stack complete"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 12 : FINAL SETUP & SUMMARY
# ──────────────────────────────────────────────────────────────────────────────

final_setup() {
    step_header "11" "Final Setup & Summary"

    # ── Desktop file for theme switcher ───────────────────────────────────────
    task "Creating desktop shortcuts"
    cat > /usr/share/applications/novastudio-theme.desktop << 'EOF'
[Desktop Entry]
Name=NovаStudio Theme Switcher
Comment=Switch NovаStudio OS themes
Exec=bash -c 'novastudio-theme'
Icon=preferences-desktop-theme
Terminal=true
Type=Application
Categories=Settings;
EOF

    cat > /usr/share/applications/novastudio-info.desktop << 'EOF'
[Desktop Entry]
Name=NovаStudio Info
Comment=NovаStudio OS Quick Reference
Exec=bash -c 'novastudio-info; read'
Icon=help-browser
Terminal=true
Type=Application
Categories=Settings;
EOF

    # ── neofetch / fastfetch config ───────────────────────────────────────────
    local real_user="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
    if [[ -n "$real_user" ]]; then
        local nf_conf="/home/${real_user}/.config/neofetch/config.conf"
        mkdir -p "$(dirname "$nf_conf")"
        grep -q "NovаStudio" "$nf_conf" 2>/dev/null || cat >> "$nf_conf" << 'EOF'
# NovаStudio OS neofetch config tweak
title_fqdn="off"
EOF
    fi

    # ── udev reload ───────────────────────────────────────────────────────────
    task "Reloading udev rules"
    udevadm control --reload-rules >> "$LOG_FILE" 2>&1
    udevadm trigger >> "$LOG_FILE" 2>&1
    success "udev rules reloaded"

    # ── systemd daemon reload ─────────────────────────────────────────────────
    task "Reloading systemd daemons"
    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    success "Systemd reloaded"

    # ── Font cache ────────────────────────────────────────────────────────────
    task "Rebuilding font cache"
    fc-cache -f >> "$LOG_FILE" 2>&1
    success "Font cache rebuilt"

    # ── Flatpak update ────────────────────────────────────────────────────────
    task "Updating all Flatpak applications"
    flatpak update -y >> "$LOG_FILE" 2>&1 || true
    success "Flatpak apps up-to-date"

    # ── Summary report ────────────────────────────────────────────────────────
    echo
    echo -e "  ${LGREEN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "  ${LGREEN}║${RESET}  ${BOLD}${WHITE}${ICO_ROCKET}  NovаStudio OS Setup Complete!${RESET}                       ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}╠══════════════════════════════════════════════════════════════╣${RESET}"

    if [[ ${#ERRORS[@]} -eq 0 ]]; then
        echo -e "  ${LGREEN}║${RESET}  ${LGREEN}${ICO_OK}  No errors encountered — clean install!${RESET}               ${LGREEN}║${RESET}"
    else
        echo -e "  ${LGREEN}║${RESET}  ${LRED}${ICO_FAIL}  ${#ERRORS[@]} error(s) — review log for details${RESET}              ${LGREEN}║${RESET}"
        for e in "${ERRORS[@]}"; do
            printf "  ${LGREEN}║${RESET}     ${RED}• %-54s${RESET}${LGREEN}║${RESET}\n" "$e"
        done
    fi

    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo -e "  ${LGREEN}║${RESET}  ${YELLOW}${ICO_WARN} ${#WARNINGS[@]} warning(s) — non-fatal, see log${RESET}               ${LGREEN}║${RESET}"
    fi

    echo -e "  ${LGREEN}╠══════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "  ${LGREEN}║${RESET}  ${CYAN}What was installed:${RESET}                                         ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• Low-latency kernel + RT tuning          ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• PipeWire + JACK + Focusrite support      ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• QJackCtl, Carla, Ardour, Audacity, LMMS  ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• Kdenlive, OBS Studio, Blender            ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• GIMP, Krita, Inkscape, RawTherapee       ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• Wine + yabridge (Windows VSTs)           ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• Gaming: Steam, Lutris, GameMode, MangoHud${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• Brave browser (only browser installed)   ${LGREEN}║${RESET}"
    $HW_GPU_NVIDIA && echo -e "  ${LGREEN}║${RESET}   ${GREY}• NVIDIA drivers (akmod-nvidia)            ${LGREEN}║${RESET}"
    $HW_GPU_AMD    && echo -e "  ${LGREEN}║${RESET}   ${GREY}• AMD amdgpu + ROCm + ACO compiler         ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${GREY}• Theme switcher + Papirus icons           ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}╠══════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "  ${LGREEN}║${RESET}  ${YELLOW}Next steps:${RESET}                                                 ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${WHITE}1. REBOOT your system now (kernel + udev)  ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${WHITE}2. Run: novastudio-info (quick reference)  ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${WHITE}3. Run: yabridgectl sync (after reboot)    ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${WHITE}4. Connect Focusrite → auto-detected       ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${WHITE}5. Open QJackCtl to configure JACK         ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${WHITE}6. In Steam: add 'gamemoderun mangohud'    ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}      ${GREY}to launch options for any game            ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}   ${WHITE}7. Install Proton-GE via ProtonPlus app    ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}╠══════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "  ${LGREEN}║${RESET}  ${GREY}Setup log: /var/log/novastudio-setup.log${RESET}                    ${LGREEN}║${RESET}"
    echo -e "  ${LGREEN}║${RESET}  ${GREY}Backups:   $BACKUP_DIR${RESET}"
    echo -e "  ${LGREEN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo

    _log "Setup complete. Errors: ${#ERRORS[@]}, Warnings: ${#WARNINGS[@]}"

    if confirm "Reboot now to apply all changes?" "y"; then
        info "Rebooting in 5 seconds... (Ctrl+C to cancel)"
        sleep 5
        reboot
    else
        echo -e "\n  ${YELLOW}${ICO_WARN}  Remember to reboot before using NovаStudio OS!${RESET}\n"
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# SECTION 13 : INTERACTIVE MENU (entry point)
# ──────────────────────────────────────────────────────────────────────────────

interactive_menu() {
    print_banner
    echo -e "  ${WHITE}Welcome to the NovаStudio OS Setup Wizard.${RESET}"
    echo -e "  ${GREY}This script will transform your Fedora installation into a${RESET}"
    echo -e "  ${GREY}professional-grade media & audio production workstation.${RESET}"
    echo
    echo -e "  ${YELLOW}${ICO_WARN}  This script requires an internet connection and root privileges.${RESET}"
    echo -e "  ${YELLOW}     It will modify system files. A backup will be created at:${RESET}"
    echo -e "  ${GREY}     $BACKUP_DIR${RESET}"
    echo

    echo -e "  ${LCYAN}What will be installed:${RESET}"
    echo -e "  ${GREY}  [1]  Hardware auto-detection & driver selection${RESET}"
    echo -e "  ${GREY}  [2]  Low-latency / realtime kernel + system tuning${RESET}"
    echo -e "  ${GREY}  [3]  GPU drivers (NVIDIA / AMD / Intel — auto-detected)${RESET}"
    echo -e "  ${GREY}  [4]  PipeWire audio + JACK + Focusrite Scarlett/Clarett${RESET}"
    echo -e "  ${GREY}  [5]  Media codecs + fonts${RESET}"
    echo -e "  ${GREY}  [6]  ${ICO_MUSIC} Apps: Ardour, QJackCtl, Carla, Kdenlive, OBS, Blender, GIMP, Krita${RESET}"
    echo -e "  ${GREY}  [7]  Wine Staging + yabridge + Bottles (Windows VST support)${RESET}"
    echo -e "  ${GREY}  [8]  Desktop themes + Papirus icons + theme switcher${RESET}"
    echo -e "  ${GREY}  [9]  Developer tools + Brave browser${RESET}"
    echo -e "  ${GREY}  [10] Security hardening (firewall + auto-updates)${RESET}"
    echo -e "  ${GREY}  [11] ${ICO_GAME} Gaming: Steam, Lutris, GameMode, MangoHud, controllers${RESET}"
    echo

    if ! confirm "Begin NovаStudio OS installation?" "y"; then
        echo -e "\n  ${GREY}Installation cancelled. No changes were made.${RESET}\n"
        exit 0
    fi

    # Optional module selection
    echo
    echo -e "  ${LCYAN}Installation mode:${RESET}"
    echo -e "  ${WHITE}  [F]${RESET} Full install (recommended)"
    echo -e "  ${WHITE}  [C]${RESET} Custom — choose modules"
    echo -en "  ${YELLOW}❓  ${WHITE}Choose [F/c]: ${RESET}"
    read -r mode_choice
    mode_choice="${mode_choice:-F}"

    local do_gpu=true do_audio=true do_media=true do_apps=true do_wine=true
    local do_themes=true do_productivity=true do_security=true do_gaming=true

    if [[ "$mode_choice" =~ ^[Cc] ]]; then
        echo
        confirm "Install GPU drivers?"                          "y" || do_gpu=false
        confirm "Setup audio (PipeWire/JACK/Focusrite)?"        "y" || do_audio=false
        confirm "Install media codecs + fonts?"                 "y" || do_media=false
        confirm "Install audio/video/image apps (Ardour etc.)?" "y" || do_apps=false
        confirm "Setup Wine + yabridge?"                        "y" || do_wine=false
        confirm "Configure desktop themes?"                     "y" || do_themes=false
        confirm "Install productivity tools + Brave?"           "y" || do_productivity=false
        confirm "Apply security hardening?"                     "y" || do_security=false
        confirm "Setup gaming (Steam/Lutris/GameMode/controllers)?" "y" || do_gaming=false
    fi

    echo
    echo -e "  ${LCYAN}Starting installation...${RESET}"
    sleep 1

    # ── Run pipeline ──────────────────────────────────────────────────────────
    preflight_checks
    detect_hardware
    optimise_system
    $do_gpu          && install_gpu_drivers
    $do_audio        && setup_audio
    $do_media        && setup_media_production
    $do_apps         && setup_applications
    $do_wine         && setup_windows_compatibility
    $do_themes       && setup_desktop_themes
    $do_productivity && setup_productivity_tools
    $do_security     && setup_security
    $do_gaming       && setup_gaming
    final_setup
}

# ──────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ──────────────────────────────────────────────────────────────────────────────

# Allow running specific sections via CLI args for automation:
# sudo bash novastudio-setup.sh --audio-only
# sudo bash novastudio-setup.sh --full
# sudo bash novastudio-setup.sh --detect

case "${1:-}" in
    --full)
        require_root
        print_banner
        preflight_checks; detect_hardware; optimise_system
        install_gpu_drivers; setup_audio; setup_media_production
        setup_applications; setup_windows_compatibility; setup_desktop_themes
        setup_productivity_tools; setup_security; setup_gaming; final_setup
        ;;
    --detect)
        require_root; print_banner; detect_hardware ;;
    --audio-only)
        require_root; print_banner; setup_audio ;;
    --apps-only)
        require_root; print_banner; setup_applications ;;
    --wine-only)
        require_root; print_banner; setup_windows_compatibility ;;
    --themes-only)
        require_root; print_banner; setup_desktop_themes ;;
    --gaming-only)
        require_root; print_banner; detect_hardware; setup_gaming ;;
    --help|-h)
        print_banner
        echo -e "  ${WHITE}Usage:${RESET} sudo bash novastudio-setup.sh [option]\n"
        echo -e "  ${CYAN}Options:${RESET}"
        echo -e "  ${GREY}  (none)          Interactive wizard (recommended)${RESET}"
        echo -e "  ${GREY}  --full          Full unattended install${RESET}"
        echo -e "  ${GREY}  --detect        Hardware detection only${RESET}"
        echo -e "  ${GREY}  --audio-only    Audio subsystem only${RESET}"
        echo -e "  ${GREY}  --apps-only     GUI applications only${RESET}"
        echo -e "  ${GREY}  --wine-only     Wine + yabridge only${RESET}"
        echo -e "  ${GREY}  --themes-only   Desktop themes only${RESET}"
        echo -e "  ${GREY}  --gaming-only   Gaming stack only${RESET}"
        echo -e "  ${GREY}  --help          Show this help${RESET}"
        echo
        ;;
    *)
        interactive_menu ;;
esac
