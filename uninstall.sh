#!/usr/bin/env bashSTREAMING_CHUNK:Initializing uninstaller settings...set -eBOLD="\033[1m"RESET="\033[0m"RED="\033[31m"GREEN="\033[32m"YELLOW="\033[33m"echo -e "${RED}${BOLD}"echo "----------------------------------------"echo "  SysCraft CLI Uninstaller              "echo "----------------------------------------"echo -e "${RESET}"STREAMING_CHUNK:Prompting user confirmation...FORCE=0if [ "$1" == "-f" ] || [ "$1" == "--force" ]; thenFORCE=1fiif [ $FORCE -eq 0 ]; thenread -p "Are you sure you want to completely uninstall syscraft? [y/N]: " confirmcase "$confirm" in[yY][eE][sS]|[yY])echo "Proceeding with uninstallation...";;*)echo "Uninstallation cancelled."exit 0;;esacfiSTREAMING_CHUNK:Locating and removing binary executables...TARGET_PATHS=("/usr/local/bin/syscraft""$HOME/.local/bin/syscraft""/usr/bin/syscraft")REMOVED_COUNT=0for bin_path in "${TARGET_PATHS[@]}"; do
if [ -f "$bin_path" ]; then
echo -e "Removing ${YELLOW}${bin_path}${RESET}..."
if [ -w "$(dirname "$bin_path")" ]; then
rm -f "$bin_path"
else
sudo rm -f "$bin_path"
fi
REMOVED_COUNT=$((REMOVED_COUNT + 1))
echo -e "${GREEN}✓ Binary removed.${RESET}"fidoneSTREAMING_CHUNK:Removing shell autocompletions...COMPLETION_FILE="$HOME/.bash_completion.d/syscraft"if [ -f "$COMPLETION_FILE" ]; then
rm -f "$COMPLETION_FILE"
echo -e "${GREEN}✓ Autocomplete file removed.${RESET}"fiSTREAMING_CHUNK:Cleaning configuration and user data...CONFIG_DIR="$HOME/.syscraft"if [ -d "$CONFIG_DIR" ]; then
if [ $FORCE -eq 1 ]; then
rm -rf "$CONFIG_DIR"
echo -e "${GREEN}✓ Purged configuration directory (${CONFIG_DIR}).${RESET}"elseread -p "Do you also want to delete user data ($CONFIG_DIR)? [y/N]: " purge_data
case "$purge_data" in
[yY][eE][sS]|[yY])
rm -rf "$CONFIG_DIR"
echo -e "${GREEN}✓ Purged user data directory.${RESET}"
;;
*)
echo -e "${YELLOW}ℹ️ Preserved data directory at ${CONFIG_DIR}${RESET}";;esacfifiSTREAMING_CHUNK:Displaying final summary...if [ $REMOVED_COUNT -gt 0 ]; then
echo -e "\n${GREEN}${BOLD}✅ SysCraft has been successfully uninstalled.${RESET}"elseecho -e "\n${YELLOW}⚠️ No installed SysCraft binary was detected.${RESET}"fi