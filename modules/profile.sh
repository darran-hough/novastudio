
choose_profile(){

echo ""
echo "Choose NovaStudio profile:"
echo "1) Audio Production"
echo "2) Media Production"
echo "3) Gaming"
echo "4) Full Studio"

read -rp "Selection: " PROFILE

log "Selected profile: $PROFILE"

}
