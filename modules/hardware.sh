detect_hardware(){

log "Detecting hardware"

CPU_VENDOR=$(lscpu | awk -F: '/Vendor ID/{print $2}' | xargs)
CPU_CORES=$(nproc)

RAM=$(free -g | awk '/Mem:/ {print $2}')

GPU=$(lspci | grep -Ei "vga|3d")

if echo "$GPU" | grep -iq nvidia; then
GPU_VENDOR="nvidia"
elif echo "$GPU" | grep -iq amd; then
GPU_VENDOR="amd"
elif echo "$GPU" | grep -iq intel; then
GPU_VENDOR="intel"
else
GPU_VENDOR="unknown"
fi


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

log "CPU: $CPU_VENDOR ($CPU_CORES cores)"
log "RAM: ${RAM}GB"
log "GPU: $GPU_VENDOR"
log "Audio: $AUDIO_INTERFACE"

}

module_hardware(){
 log "Hardware module complete"
}
