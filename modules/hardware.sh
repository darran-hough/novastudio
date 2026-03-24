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

if lsusb | grep -Ei "focusrite|scarlett|clarett" &>/dev/null; then
AUDIO_INTERFACE="focusrite"
else
AUDIO_INTERFACE="generic"
fi

log "CPU: $CPU_VENDOR ($CPU_CORES cores)"
log "RAM: ${RAM}GB"
log "GPU: $GPU_VENDOR"
log "Audio: $AUDIO_INTERFACE"

}

module_hardware(){
 log "Hardware module complete"
}