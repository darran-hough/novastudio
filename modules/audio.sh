
module_audio(){

log "Installing PipeWire audio stack"

install_pkg pipewire wireplumber pipewire-jack-audio-connection-kit

if [[ "$AUDIO_INTERFACE" == "focusrite" ]]; then

log "Applying Focusrite optimisations"

cat >/etc/modprobe.d/focusrite.conf <<EOF
options snd_usb_audio implicit_fb=1
EOF

fi

}
