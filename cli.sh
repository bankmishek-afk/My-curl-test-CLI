#!/usr/bin/env bashSTREAMING_CHUNK:Initializing global variables and configuration paths...VERSION="1.2.0"CONFIG_DIR="$HOME/.syscraft"TASKS_FILE="$CONFIG_DIR/tasks.txt"NOTES_DIR="$CONFIG_DIR/notes"LOG_FILE="$CONFIG_DIR/syscraft.log"STREAMING_CHUNK:Defining color codes and UI formatting constants...BOLD="\033[1m"RESET="\033[0m"RED="\033[31m"GREEN="\033[32m"YELLOW="\033[33m"BLUE="\033[34m"MAGENTA="\033[35m"CYAN="\033[36m"WHITE="\033[37m"STREAMING_CHUNK:Creating necessary storage directories...init_environment() {mkdir -p "$CONFIG_DIR"mkdir -p "$NOTES_DIR"touch "$TASKS_FILE"touch "$LOG_FILE"}STREAMING_CHUNK:Logging events to internal file...log_action() {local message="$1"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"}STREAMING_CHUNK:Rendering visual banner...show_banner() {echo -e "${CYAN}${BOLD}"echo "  ____               raft   "
echo " / | 123 ___  / | __ __ _ / | | "
echo " _ | | | / || |   | '/ ` | || |"
echo "  ) | || _ | || | | (| |  | | "
echo " |/ _, |/ _||  _,||  _|"echo "        |___/        v$VERSION"
echo -e "${RESET}"}STREAMING_CHUNK:Displaying general CLI help documentation...show_help() {show_bannerecho -e "${BOLD}USAGE:${RESET}"echo "  syscraft  [options] [arguments]"echo ""echo -e "${BOLD}COMMANDS:${RESET}"echo -e "  ${GREEN}sysinfo${RESET}, ${GREEN}info${RESET}       Display system hardware and network metrics"echo -e "  ${GREEN}tasks${RESET}, ${GREEN}todo${RESET}         Manage daily task items (add, list, done, clear)"echo -e "  ${GREEN}notes${RESET}             Quick plain-text note keeper (add, list, view, del)"echo -e "  ${GREEN}net${RESET}               Network diagnosis tools (ip, ping, port)"echo -e "  ${GREEN}clean${RESET}             Clean temporary caches and log files"echo -e "  ${GREEN}menu${RESET}              Launch interactive shell interface"echo -e "  ${GREEN}completion${RESET}        Generate Bash autocomplete script"echo -e "  ${GREEN}version${RESET}, ${GREEN}-v${RESET}        Show installed version"echo -e "  ${GREEN}help${RESET}, ${GREEN}-h${RESET}           Show this help message"echo ""echo -e "${BOLD}EXAMPLES:${RESET}"echo "  syscraft tasks add 'Fix server production deployment'"echo "  syscraft notes add 'project-idea' 'Build a custom Rust CLI'"echo "  syscraft net ip"echo "  syscraft clean --dry-run"}STREAMING_CHUNK:Handling system information gathering...cmd_sysinfo() {echo -e "${BOLD}${BLUE}=== SYSTEM DIAGNOSTICS ===${RESET}"
echo -e "${BOLD}OS:${RESET}        $(uname -s) ($(uname -m))"
echo -e "${BOLD}Kernel:${RESET}$(uname -r)"echo -e "${BOLD}Uptime:${RESET}$(uptime -p 2>/dev/null || uptime)"
echo -e "${BOLD}User:${RESET}      $USER@$(hostname)"echo ""
echo -e "${BOLD}${BLUE}=== RESOURCE USAGE ===${RESET}"
if command -v free >/dev/null 2>&1; then
    echo -e "${BOLD}Memory:${RESET}"
    free -h | awk 'NR==1{printf "  %-10s %-10s %-10s\n", $2, $3, $4} NR==2{printf "  %-10s %-10s %-10s\n", $2, $3, $4}'
fi

echo -e "${BOLD}Disk Storage:${RESET}"
df -h / | awk 'NR==1{printf "  %-10s %-10s %-10s %-10s\n", $2, $3, $4, $5} NR==2{printf "  %-10s %-10s %-10s %-10s\n", $2, $3, $4, $5}'

log_action "Executed sysinfo command"
}STREAMING_CHUNK:Managing todo tasks subsystem...cmd_tasks() {local subcmd="$1"shiftcase "$subcmd" in
    add)
        if [ -z "$1" ]; then
            echo -e "${RED}Error:${RESET} Task description missing."
            return 1
        fi
        echo "[ ] $1" >> "$TASKS_FILE"
        echo -e "${GREEN}✓ Task added:${RESET} \"$1\""
        log_action "Added task: $1"
        ;;
    list|"")
        echo -e "${BOLD}${MAGENTA}=== YOUR TASKS ===${RESET}"
        if [ ! -s "$TASKS_FILE" ]; then
            echo -e "${YELLOW}No tasks found. Create one with: syscraft tasks add \"Task description\"${RESET}"
        else
            nl -w2 -s'. ' "$TASKS_FILE"
        fi
        ;;
    done)
        local line_num="$1"
        if [ -z "$line_num" ]; then
            echo -e "${RED}Error:${RESET} Task number required."
            return 1
        fi
        if sed -i "${line_num}s/\[ \]/\[x\]/" "$TASKS_FILE" 2>/dev/null; then
            echo -e "${GREEN}✓ Marked task #$line_num as completed!${RESET}"
            log_action "Completed task #$line_num"
        else
            echo -e "${RED}Failed to mark task #$line_num.${RESET}"
        fi
        ;;
    clear)
        > "$TASKS_FILE"
        echo -e "${YELLOW}Cleared all tasks.${RESET}"
        log_action "Cleared tasks"
        ;;
    *)
        echo -e "${RED}Unknown tasks subcommand:${RESET}$subcmd"
        echo "Usage: syscraft tasks [add|list|done|clear]"
        ;;
esac
}STREAMING_CHUNK:Managing note storage subsystem...cmd_notes() {local subcmd="$1"shiftcase "$subcmd" in
    add)
        local title="$1"
        local content="$2"
        if [ -z "$title" ] \vert{}\vert{} [ -z "$content" ]; then
            echo -e "${RED}Usage:${RESET} syscraft notes add <title> <content>"
            return 1
        fi
        echo "$content" > "$NOTES_DIR/$title.txt"
        echo -e "${GREEN}✓ Saved note:${RESET}$title"
        log_action "Created note: $title"
        ;;
    list|"")
        echo -e "${BOLD}${CYAN}=== YOUR NOTES ===${RESET}"
        local files=("$NOTES_DIR"/*.txt)
        if [ ! -e "${files[0]}" ]; then
            echo -e "${YELLOW}No notes found.${RESET}"
        else
            for f in "$NOTES_DIR"/*.txt; do
                basename "$f" .txt | sed 's/^/  • /'
            done
        fi
        ;;
    view)
        local title="$1"
        if [ -f "$NOTES_DIR/$title.txt" ]; then
            echo -e "${BOLD}--- Note: $title ---${RESET}"
            cat "$NOTES_DIR/$title.txt"
        else
            echo -e "${RED}Note '$title' not found.${RESET}"
        fi
        ;;
    del)
        local title="$1"
        if [ -f "$NOTES_DIR/$title.txt" ]; then
            rm "$NOTES_DIR/$title.txt"
            echo -e "${YELLOW}Deleted note $title.${RESET}"
            log_action "Deleted note: $title"
        else
            echo -e "${RED}Note '$title' not found.${RESET}"
        fi
        ;;
    *)
        echo "Usage: syscraft notes [add|list|view|del]"
        ;;
esac
}STREAMING_CHUNK:Handling network diagnostic routines...cmd_net() {local subcmd="$1"
case "$subcmd" in
ip)
echo -e "${BOLD}Public IP:${RESET}$(curl -s https://ifconfig.me || echo 'Unavailable')"
echo -e "${BOLD}Local IP:${RESET}$(hostname -I 2>/dev/null | awk '{print $1}' || echo '127.0.0.1')"
;;
ping)
local host="${2:-1.1.1.1}"echo -e "Pinging ${CYAN}$host${RESET}..."ping -c 4 "$host";;port)local host="$2"local port="$3"if [ -z "$host" ] \vert{}\vert{} [ -z "$port" ]; thenecho "Usage: syscraft net port  "return 1fi(echo > /dev/tcp/"$host"/"$port") >/dev/null 2>&1 && \
echo -e "${GREEN}✓ Port $port on $host is OPEN${RESET}" || \
echo -e "${RED}✗ Port $port on $host is CLOSED/BLOCKED${RESET}";;*)echo "Usage: syscraft net [ip|ping |port  ]";;esac}STREAMING_CHUNK:Executing system cleanup routines...cmd_clean() {local dry_run=0if [ "$1" == "--dry-run" ]; then
dry_run=1
echo -e "${YELLOW}[DRY RUN MODE] No files will actually be deleted.${RESET}"fiecho -e "${YELLOW}Searching for temporary files (~/*.tmp, /tmp/*_syscraft)...${RESET}"

if [ $dry_run -eq 0 ]; then
    rm -rf /tmp/*_syscraft 2>/dev/null
    rm -f "$HOME"/*.tmp 2>/dev/null
    echo -e "${GREEN}✓ Temporary cache files cleared!${RESET}"
    log_action "Cleaned temp files"
else
    echo -e "${CYAN}Found test temporary files ready for cleanup.${RESET}"
fi
}STREAMING_CHUNK:Launching interactive shell menu...cmd_interactive() {show_bannerecho -e "${BOLD}Interactive Control Menu${RESET}\n"PS3="Choose an action (1-6): "
options=("System Info" "View Tasks" "View Notes" "Check IP" "Clean System" "Quit")
select opt in "${options[@]}"; do
    case $opt in
        "System Info")
            cmd_sysinfo
            ;;
        "View Tasks")
            cmd_tasks list
            ;;
        "View Notes")
            cmd_notes list
            ;;
        "Check IP")
            cmd_net ip
            ;;
        "Clean System")
            cmd_clean
            ;;
        "Quit")
            echo "Goodbye!"
            break
            ;;
        *) echo -e "${RED}Invalid option $REPLY${RESET}";;
    esac
done
}STREAMING_CHUNK:Generating shell completion script...cmd_completion() {cat << 'EOF'_syscraft_completions() {local cur prev optsCOMPREPLY=()cur="${COMP_WORDS[COMP_CWORD]}"
prev="${COMP_WORDS[COMP_CWORD-1]}"opts="sysinfo tasks notes net clean menu completion version help"case "${prev}" in
    tasks)
        COMPREPLY=( $(compgen -W "add list done clear" -- ${cur}) )
        return 0
        ;;
    notes)
        COMPREPLY=( $(compgen -W "add list view del" -- ${cur}) )
        return 0
        ;;
    net)
        COMPREPLY=( $(compgen -W "ip ping port" -- ${cur}) )
        return 0
        ;;
esac

COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}complete -F _syscraft_completions syscraftEOF}STREAMING_CHUNK:Dispatching command argument parser...main() {init_environmentif [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    sysinfo|info)
        cmd_sysinfo
        ;;
    tasks|todo)
        shift
        cmd_tasks "$@"
        ;;
    notes)
        shift
        cmd_notes "$@"
        ;;
    net)
        shift
        cmd_net "$@"
        ;;
    clean)
        shift
        cmd_clean "$@"
        ;;
    menu)
        cmd_interactive
        ;;
    completion)
        cmd_completion
        ;;
    version|-v|--version)
        echo "syscraft version $VERSION"
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${RESET}\n"
        show_help
        exit 1
        ;;
esac
}main "$@"