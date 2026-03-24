
module_audio(){

if [[ "$PROFILE_NAME" != "audio" && "$PROFILE_NAME" != "full" ]]; then
 return
fi

log "Installing audio production stack"

install_pkg pipewire wireplumber pipewire-jack-audio-connection-kit


if [[ "$AUDIO_INTERFACE" == "focusrite" ]]; then

log "Applying Focusrite tweaks"

cat >/etc/modprobe.d/focusrite.conf <<EOF
options snd_usb_audio implicit_fb=1
EOF

fi

}
