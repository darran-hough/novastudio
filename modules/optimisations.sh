module_optimisations(){

log "Enabling RPM Fusion repositories"

dnf install -y \
 https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
 https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

log "Refreshing repositories"

dnf makecache

log "Installing gamemode"

dnf install -y gamemode || true

log "Applying safe system optimisations"

sed -i '/fastestmirror/d' /etc/dnf/dnf.conf
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

systemctl enable --now gamemoded || true

}