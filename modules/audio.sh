module_audio(){

if [[ "$PROFILE_NAME" != "audio" && "$PROFILE_NAME" != "full" ]]; then
 return
fi

log "Installing audio production stack"

    # ── Remove PulseAudio if present ──────────────────────────────────────────
    if rpm -q pulseaudio &>/dev/null; then
        dnf remove -y pulseaudio pulseaudio-utils >> "$LOG" 2>&1
        success "PulseAudio removed"
    else
        success "PulseAudio not present — skipping"
    fi

    # ── PipeWire stack ────────────────────────────────────────────────────────
    # Uses install_pkg (per-package, non-fatal) rather than spinner_run so that
    # renamed or missing packages on newer Fedora releases don't abort the whole
    # section. Package names confirmed against Fedora 43 repos.
    # Core PipeWire — always present on Fedora 38+
    install_pkg pipewire pipewire-utils pipewire-alsa \
        pipewire-jack-audio-connection-kit pipewire-pulseaudio \
        wireplumber
    # Optional dev/doc packages — may not exist on all releases; failures are harmless
    install_pkg pipewire-devel wireplumber-devel pipewire-doc 2>/dev/null || true
    # GStreamer PipeWire integration — package was merged into gstreamer1-plugins-good
    # on Fedora 40+; try both names, neither is fatal if absent
    # pipewire-gstreamer is the correct package name on Fedora 40+
    install_pkg pipewire-gstreamer 2>/dev/null || \
        install_pkg gstreamer1-plugins-good 2>/dev/null || true
    success "PipeWire stack installed"

    # ── JACK libraries (infrastructure — no GUI apps) ────────────────────────
    install_pkg jack-audio-connection-kit jack-audio-connection-kit-devel
    success "JACK2 libraries installed"

    # ── PipeWire JACK config for low latency ─────────────────────────────────
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
    install_pkg alsa-utils alsa-tools alsa-plugins-pulseaudio


    # ALSA UCM profiles
    if $HW_FOCUSRITE; then

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

    local real_user="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
    if [[ -n "$real_user" ]]; then
        groupadd -f audio 2>/dev/null || true
        groupadd -f jackuser 2>/dev/null || true
        groupadd -f realtime 2>/dev/null || true
        usermod -aG audio,jackuser,realtime "$real_user"
        success "User $real_user added to audio/jackuser/realtime groups"
    fi

    # ── Plugin framework libraries (infrastructure — not apps) ───────────────

    # Refresh metadata first — zita-njbridge requires up-to-date repo metadata
    dnf makecache --refresh >> "$LOG" 2>&1 || true
    install_pkg ladspa ladspa-devel lv2 lv2-devel lilv \
                 a2jmidid
    success "Audio infrastructure libraries installed"

    # ── Enable PipeWire user services ─────────────────────────────────────────

    systemctl --global enable pipewire.socket pipewire.service wireplumber.service >> "$LOG" 2>&1
    systemctl --global enable pipewire-pulse.socket pipewire-pulse.service >> "$LOG" 2>&1
    success "PipeWire services enabled"
}
