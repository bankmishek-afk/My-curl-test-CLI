#!/usr/bin/env bashSTREAMING_CHUNK:Initializing installer configuration...set -eREPO_USER="your-github-username"REPO_NAME="syscraft"BRANCH="main"RAW_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${BRANCH}"BOLD="\033[1m"RESET="\033[0m"GREEN="\033[32m"RED="\033[31m"YELLOW="\033[33m"CYAN="\033[36m"STREAMING_CHUNK:Displaying installer header...echo -e "${CYAN}${BOLD}"echo "----------------------------------------"echo "  SysCraft CLI Installer                "echo "----------------------------------------"echo -e "${RESET}"STREAMING_CHUNK:Verifying required dependencies...echo -e "${BOLD}🔍 Checking dependencies...${RESET}"REQUIRED_TOOLS=("curl" "bash" "awk")for tool in "${REQUIRED_TOOLS[@]}"; do
if ! command -v "$tool" >/dev/null 2>&1; then
echo -e "${RED}❌ Error: Required tool '$tool' is not installed.${RESET}"
exit 1
fi
done
echo -e "${GREEN}✓ All core dependencies met.${RESET}"STREAMING_CHUNK:Determining optimal target installation directory...INSTALL_DIR=""if [ "$(id -u)" -eq 0 ]; thenINSTALL_DIR="/usr/local/bin"elif [ -w "/usr/local/bin" ]; thenINSTALL_DIR="/usr/local/bin"elseINSTALL_DIR="$HOME/.local/bin"mkdir -p "$INSTALL_DIR"fiTARGET_PATH="${INSTALL_DIR}/syscraft"
echo -e "${BOLD}📁 Installing binary to:${RESET}${TARGET_PATH}"STREAMING_CHUNK:Downloading main CLI script from GitHub...echo -e "${BOLD}⬇️ Downloading syscraft executable...${RESET}"if curl -sSL "${RAW_URL}/cli.sh" -o "${TARGET_PATH}"; thenchmod +x "${TARGET_PATH}"
echo -e "${GREEN}✓ Executable permissions granted.${RESET}"
else
echo -e "${RED}❌ Download failed! Please check your network connection or repository URL.${RESET}"exit 1fiSTREAMING_CHUNK:Setting up shell autocompletions...echo -e "${BOLD}⚙️ Setting up shell autocompletions...${RESET}"COMPLETIONS_DIR="$HOME/.bash_completion.d"mkdir -p "$COMPLETIONS_DIR"if "${TARGET_PATH}" completion > "${COMPLETIONS_DIR}/syscraft" 2>/dev/null; thenecho -e "${GREEN}✓ Autocomplete file written to ${COMPLETIONS_DIR}/syscraft${RESET}"# Auto source in .bashrc if not present
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ] && ! grep -q "syscraft" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# SysCraft autocompletion" >> "$BASHRC"
    echo "[ -f \"${COMPLETIONS_DIR}/syscraft\" ] && source \"${COMPLETIONS_DIR}/syscraft\"" >> "$BASHRC"
fi
fiSTREAMING_CHUNK:Checking environment PATH inclusion...echo ""if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
echo -e "${YELLOW}⚠️ WARNING: ${INSTALL_DIR} is not in your \$PATH.${RESET}"echo "Add the following line to your ~/.bashrc or ~/.zshrc:"echo -e "${CYAN}  export PATH=\"\$PATH:${INSTALL_DIR}"${RESET}"echo ""fiSTREAMING_CHUNK:Displaying final installation success status...echo -e "${GREEN}${BOLD}🎉 SysCraft installed successfully!${RESET}"echo -e "Try running: ${CYAN}syscraft help${RESET}"echo -e "Or launch menu: ${CYAN}syscraft menu${RESET}"
