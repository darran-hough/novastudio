
module_gpu(){

log "Configuring GPU"

case "$GPU_VENDOR" in

nvidia)
install_pkg akmod-nvidia xorg-x11-drv-nvidia-cuda
;;

amd)
install_pkg mesa-vulkan-drivers mesa-dri-drivers
;;

intel)
install_pkg intel-media-driver mesa-vulkan-drivers
;;

*)
log "Unknown GPU - skipping driver install"
;;

esac

}
