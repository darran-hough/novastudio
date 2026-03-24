
module_gaming(){

if [[ "$PROFILE_NAME" != "gaming" && "$PROFILE_NAME" != "full" ]]; then
 return
fi

log "Installing gaming tools"

install_pkg steam lutris mangohud gamemode gamescope

}
