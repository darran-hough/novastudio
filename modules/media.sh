
module_media(){

if [[ "$PROFILE_NAME" != "media" && "$PROFILE_NAME" != "full" ]]; then
 return
fi

log "Installing media tools"

install_pkg ffmpeg obs-studio blender kdenlive
install_pkg ffmpeg ffmpegthumbnailer
install_pkg vlc
install_pkg gstreamer1-plugins-bad-freeworld
install_pkg gstreamer1-plugins-ugly

}
