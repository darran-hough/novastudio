
module_gpu(){

log "Configuring GPU drivers"

case "$GPU_VENDOR" in

nvidia)
sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
install_pkg akmod-nvidia xorg-x11-drv-nvidia-cuda
;;

amd)
install_pkg mesa-vulkan-drivers mesa-dri-drivers
;;

intel)
install_pkg intel-media-driver mesa-vulkan-drivers
;;

*)
log "Unknown GPU - skipping"
;;

esac

}
