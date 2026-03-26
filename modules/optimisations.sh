module_optimisations(){

# ─────────────────────────────────────────────────────────────────────────────
# 1. RPM FUSION
# ─────────────────────────────────────────────────────────────────────────────

FEDORA_VER=$(rpm -E %fedora)
FREE_RPM="rpmfusion-free-release-${FEDORA_VER}"
NONFREE_RPM="rpmfusion-nonfree-release-${FEDORA_VER}"
 
if rpm -q "$FREE_RPM" &>/dev/null && rpm -q "$NONFREE_RPM" &>/dev/null; then
    skip "RPM Fusion (free + nonfree)"
    SKIPPED+=("RPM Fusion")
else
    log "Adding RPM Fusion repositories…"
    if dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"; then
        success "RPM Fusion enabled."
        INSTALLED+=("RPM Fusion")
    else
        ERRORS+=("RPM Fusion: repo install failed")
    fi
fi


# ─────────────────────────────────────────────────────────────────────────────
# 2. SYSTEM UPDATE
# ─────────────────────────────────────────────────────────────────────────────
log "2 · System Update"
log "Refreshing metadata and upgrading base system…"
dnf upgrade -y || warn "Some packages failed to upgrade — continuing anyway."
success "System up to date."
 



# ─────────────────────────────────────────────────────────────────────────────
# 3. GameMode
# ─────────────────────────────────────────────────────────────────────────────

#!/bin/bash

TARGET="/etc/polkit-1/rules.d/99-gamemode.rules"

EXPECTED='polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec" &&
        action.lookup("program") == "/usr/libexec/cpugovctl" &&
        subject.isInGroup("gamemode")) {
        return polkit.Result.YES;
    }
});'

# Only skip the write if file exists AND content is already correct
if [ ! -f "$TARGET" ] || [ "$(cat "$TARGET" | tr -d '[:space:]')" != "$(echo "$EXPECTED" | tr -d '[:space:]')" ]; then
    echo "Writing $TARGET..."

    sudo tee "$TARGET" << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec" &&
        action.lookup("program") == "/usr/libexec/cpugovctl" &&
        subject.isInGroup("gamemode")) {
        return polkit.Result.YES;
    }
});
EOF

    if [ $? -eq 0 ]; then
        echo "Done. $TARGET written successfully."
    else
        echo "ERROR: Failed to write $TARGET" >&2
    fi
else
    echo "File already correct: $TARGET — skipping."
fi

echo "Writing $TARGET..."

sudo tee "$TARGET" << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec" &&
        action.lookup("program") == "/usr/libexec/cpugovctl" &&
        subject.isInGroup("gamemode")) {
        return polkit.Result.YES;
    }
});
EOF

if [ $? -eq 0 ]; then
    echo "Done. $TARGET written successfully."
else
    echo "ERROR: Failed to write $TARGET" >&2
    exit 1
fi

}
