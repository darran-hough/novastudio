
module_gaming(){
# ─────────────────────────────────────────────────────────────────────────────
# HELPER — safe Flatpak installer (skips already-installed apps)
# Usage: flatpak_install "label" com.example.App
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# 3. FLATHUB REMOTE
# ─────────────────────────────────────────────────────────────────────────────
log "3 · Flathub Remote"
if flatpak remotes | grep -q "^flathub"; then
    skip "Flathub remote"
    SKIPPED+=("Flathub remote")
else
    log "Adding Flathub remote…"
    if flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
        success "Flathub remote added."
        INSTALLED+=("Flathub remote")
    else
        ERRORS+=("Flathub: remote-add failed")
    fi
fi
log "Updating Flatpak runtimes…"
flatpak update -y || warn "Flatpak update encountered issues — continuing."
 

log "Refreshing repositories"
dnf makecache



flatpak_install() {
    local label="$1"
    local app_id="$2"
 
    if flatpak info "$app_id" &>/dev/null; then
        skip "$label ($app_id)"
        SKIPPED+=("$app_id")
    else
        log "Installing Flatpak: $app_id"
        if flatpak install -y flathub "$app_id"; then
            success "$label installed."
            INSTALLED+=("$app_id")
        else
            warn "$label — Flatpak install failed."
            ERRORS+=("$label: flatpak install failed")
        fi
    fi
}


if [[ "$PROFILE_NAME" != "gaming" && "$PROFILE_NAME" != "full" ]]; then
 return
fi

log "Installing gaming tools"


# ─────────────────────────────────────────────────────────────────────────────
# 6. LUTRIS
# ─────────────────────────────────────────────────────────────────────────────
log "6 · Lutris"
install_pkg lutris
 
# ─────────────────────────────────────────────────────────────────────────────
# 7. HEROIC GAMES LAUNCHER
# ─────────────────────────────────────────────────────────────────────────────
log "7 · Heroic Games Launcher"
flatpak_install "Heroic" com.heroicgameslauncher.hgl
 
# ─────────────────────────────────────────────────────────────────────────────
# 8. WINE + WINETRICKS
# ─────────────────────────────────────────────────────────────────────────────
log "8 · Wine & Winetricks"
install_pkg wine wine.i686 winetricks
 
# ─────────────────────────────────────────────────────────────────────────────
# 9. PROTONUP-QT
# ─────────────────────────────────────────────────────────────────────────────
log "9 · ProtonUp-Qt"
flatpak_install "ProtonUp-Qt" net.davidotek.pupgui2
 
# ─────────────────────────────────────────────────────────────────────────────
# 10. GAMEMODE
# ─────────────────────────────────────────────────────────────────────────────
log "10 · GameMode"
install_pkg gamemode gamemode.i686
 
if systemctl --user is-active gamemoded.service &>/dev/null; then
    skip "gamemoded.service (already running)"
else
    systemctl --user enable --now gamemoded.service 2>/dev/null \
        && success "gamemoded.service enabled." \
        || warn "Could not enable gamemoded.service for this user — run manually after login."
fi
 
# ─────────────────────────────────────────────────────────────────────────────
# 11. MANGOHUD
# ─────────────────────────────────────────────────────────────────────────────
log "11 · MangoHud"
install_pkg mangohud mangohud.i686
 
# ─────────────────────────────────────────────────────────────────────────────
# 12. CONTROLLER SUPPORT
# ─────────────────────────────────────────────────────────────────────────────
log "12 · Controller Support"
install_pkg xpad SDL2 SDL2.i686
 
XPAD_CONF="/etc/modules-load.d/xpad.conf"
if [[ -f "$XPAD_CONF" ]] && grep -q "^xpad$" "$XPAD_CONF"; then
    skip "xpad module config (${XPAD_CONF})"
else
    echo "xpad" > "$XPAD_CONF"
    success "xpad module configured to load at boot."
fi
 
# ─────────────────────────────────────────────────────────────────────────────
# 13. DISCORD
# ─────────────────────────────────────────────────────────────────────────────
log "13 · Discord"
flatpak_install "Discord" com.discordapp.Discord
 
# ─────────────────────────────────────────────────────────────────────────────
# 14. GSTREAMER CODECS + FFMPEG
# ─────────────────────────────────────────────────────────────────────────────
log "14 · GStreamer Codecs & FFmpeg"
install_pkg \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-ugly \
    gstreamer1-libav \
    ffmpeg
 

install_pkg steam lutris mangohud gamemode gamescope






}
