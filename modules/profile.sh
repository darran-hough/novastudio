choose_profile(){

echo ""
echo "Choose NovaStudio profile:"
echo "1) Gaming"
echo "2) Audio Production"
echo "3) Media Production"
echo "4) Full Creator Studio"

read -rp "Selection: " PROFILE

case "$PROFILE" in
1) PROFILE_NAME="gaming";;
2) PROFILE_NAME="audio";;
3) PROFILE_NAME="media";;
4) PROFILE_NAME="full";;
*) PROFILE_NAME="full";;
esac

echo "Selected profile: $PROFILE_NAME"

}

module_profile(){
 log "Profile already selected"
}