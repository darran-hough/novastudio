
#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/lib/common.sh"

print_banner
require_root
detect_user

load_modules

detect_hardware
choose_profile

run_modules

success "NovaStudio Installer completed successfully."
