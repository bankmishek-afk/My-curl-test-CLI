#!/bin/bash
# ============================================================
# 🚀 ULTIMATE CLI INSTALLER v3.2 - FULLY AUTOMATIC
# Полностью автоматическая установка без вопросов
# ============================================================

set -e

# ========== ЦВЕТА ==========
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
GRAY='\033[90m'

# ========== ПЕРЕМЕННЫЕ ==========
REPO_URL="https://raw.githubusercontent.com/bankmishek-afk/My-curl-test-CLI/refs/heads/main"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/mycli"
DATA_DIR="$HOME/.local/share/mycli"
CLI_NAME="mycli"
VERSION="3.2.0"

# ========== ФУНКЦИИ ==========

# Простой прогресс-бар
show_progress() {
    local current=$1
    local total=$2
    local message="$3"
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    
    echo -ne "\r${CYAN}[${RESET}"
    for ((i=0; i<width; i++)); do
        if [ $i -lt $filled ]; then
            echo -ne "${BG_GREEN}${BLACK}=${RESET}"
        else
            echo -ne "${BG_BLACK}${WHITE} ${RESET}"
        fi
    done
    echo -ne "${CYAN}]${RESET} ${BOLD}${percent}%${RESET} ${message}    "
}

# Большой баннер
draw_banner() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║     ███╗   ███╗██╗   ██╗ ██████╗██╗     ██╗               ║"
    echo "║     ████╗ ████║╚██╗ ██╔╝██╔════╝██║     ██║               ║"
    echo "║     ██╔████╔██║ ╚████╔╝ ██║     ██║     ██║               ║"
    echo "║     ██║╚██╔╝██║  ╚██╔╝  ██║     ██║     ██║               ║"
    echo "║     ██║ ╚═╝ ██║   ██║   ╚██████╗███████╗██║               ║"
    echo "║     ╚═╝     ╚═╝   ╚═╝    ╚═════╝╚══════╝╚═╝               ║"
    echo "║                                                              ║"
    echo "║               ${WHITE}${BOLD}AUTOMATIC INSTALLER v${VERSION}${CYAN}             ║"
    echo "║          ${GRAY}No questions asked - Just works!${CYAN}                ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
}

# ========== ОСНОВНЫЕ ФУНКЦИИ ==========

check_requirements() {
    echo -e "${BLUE}🔍 Проверка требований...${RESET}"
    
    local missing=()
    
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    if ! command -v bash &> /dev/null; then
        missing+=("bash")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}❌ Отсутствуют: ${missing[*]}${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Все требования выполнены${RESET}"
    echo ""
}

create_directories() {
    echo -e "${BLUE}📁 Создание директорий...${RESET}"
    
    mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$DATA_DIR" "$CONFIG_DIR/plugins" "$DATA_DIR/cache"
    
    echo -e "${GREEN}✅ Директории созданы${RESET}"
    echo ""
}

download_cli() {
    echo -e "${BLUE}🌐 Загрузка CLI...${RESET}"
    
    if curl -fsSL "$REPO_URL/cli.sh" -o "$INSTALL_DIR/$CLI_NAME"; then
        chmod +x "$INSTALL_DIR/$CLI_NAME"
        echo -e "${GREEN}✅ CLI загружен: $INSTALL_DIR/$CLI_NAME${RESET}"
    else
        echo -e "${RED}❌ Ошибка загрузки CLI${RESET}"
        exit 1
    fi
    
    # Создаём конфиг по умолчанию
    cat > "$CONFIG_DIR/default.conf" << 'EOF'
# MyCLI Configuration
theme=default
language=ru
auto_update=true
EOF
    
    echo -e "${GREEN}✅ Конфигурация создана${RESET}"
    echo ""
}

setup_shell() {
    echo -e "${BLUE}⚙️  Настройка оболочки...${RESET}"
    
    local shell_rc=""
    local shell_name=$(basename "$SHELL")
    
    case "$shell_name" in
        bash) shell_rc="$HOME/.bashrc" ;;
        zsh) shell_rc="$HOME/.zshrc" ;;
        fish) shell_rc="$HOME/.config/fish/config.fish" ;;
        *) shell_rc="$HOME/.profile" ;;
    esac
    
    if [ ! -f "$shell_rc" ]; then
        touch "$shell_rc"
    fi
    
    # Добавляем в PATH
    if ! grep -q "MYCLI" "$shell_rc" 2>/dev/null; then
        cat >> "$shell_rc" << EOF

# MyCLI Configuration
export PATH="\$PATH:$INSTALL_DIR"
alias mycli='$INSTALL_DIR/$CLI_NAME'
EOF
        echo -e "${GREEN}✅ Обновлён $shell_rc${RESET}"
    else
        echo -e "${BLUE}ℹ️  $shell_rc уже настроен${RESET}"
    fi
    
    # Создаём автодополнение
    cat > "$CONFIG_DIR/completions.sh" << 'EOF'
#!/bin/bash
_mycli_completions() {
    COMPREPLY=($(compgen -W "hello world date weather system info config plugin help version" -- "${COMP_WORDS[1]}"))
}
complete -F _mycli_completions mycli
EOF
    
    echo -e "${GREEN}✅ Настройка завершена${RESET}"
    echo ""
}

test_installation() {
    echo -e "${BLUE}🧪 Тестирование...${RESET}"
    
    if "$INSTALL_DIR/$CLI_NAME" version &>/dev/null; then
        echo -e "${GREEN}✅ Установка работает${RESET}"
    else
        echo -e "${YELLOW}⚠️  Тест не пройден, но файл установлен${RESET}"
    fi
    
    echo ""
}

show_completion() {
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║${RESET}                                                              ${CYAN}${BOLD}║${RESET}"
    echo -e "${CYAN}${BOLD}║${RESET}        ${GREEN}${BOLD}✨ УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА! ✨${CYAN}${BOLD}        ║${RESET}"
    echo -e "${CYAN}${BOLD}║${RESET}                                                              ${CYAN}${BOLD}║${RESET}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "${YELLOW}${BOLD}📌  БЫСТРЫЙ СТАРТ:${RESET}"
    echo -e "  ${GRAY}1.${RESET} Примените настройки: ${CYAN}source ~/.$(basename "$SHELL")rc${RESET}"
    echo -e "  ${GRAY}2.${RESET} Проверьте установку: ${CYAN}mycli version${RESET}"
    echo -e "  ${GRAY}3.${RESET} Попробуйте команды:"
    echo -e "     ${CYAN}mycli hello --name Вася${RESET}"
    echo -e "     ${CYAN}mycli weather Москва${RESET}"
    echo -e "     ${CYAN}mycli system${RESET}"
    echo -e "     ${CYAN}mycli help${RESET}"
    echo ""
    
    echo -e "${DIM}🗑️  Для удаления: curl -fsSL $REPO_URL/uninstall.sh | bash${RESET}"
    echo ""
    
    echo -e "${GREEN}${BOLD}🎉 Готово! Приятного использования!${RESET}"
    echo ""
}

# ========== MAIN ==========
main() {
    draw_banner
    
    echo -e "${DIM}Установка MyCLI v$VERSION...${RESET}"
    echo -e "${DIM}Путь: $INSTALL_DIR${RESET}"
    echo ""
    
    # Шаги установки с прогрессом
    steps=5
    current=0
    
    # Шаг 1
    ((current++))
    show_progress $current $steps "Проверка требований..."
    check_requirements > /dev/null 2>&1
    echo ""
    
    # Шаг 2
    ((current++))
    show_progress $current $steps "Создание директорий..."
    create_directories > /dev/null 2>&1
    echo ""
    
    # Шаг 3
    ((current++))
    show_progress $current $steps "Загрузка файлов..."
    download_cli > /dev/null 2>&1
    echo ""
    
    # Шаг 4
    ((current++))
    show_progress $current $steps "Настройка оболочки..."
    setup_shell > /dev/null 2>&1
    echo ""
    
    # Шаг 5
    ((current++))
    show_progress $current $steps "Тестирование..."
    test_installation > /dev/null 2>&1
    echo ""
    echo ""
    
    # Показываем детали
    check_requirements
    create_directories
    download_cli
    setup_shell
    test_installation
    show_completion
    
    # Добавляем в текущую сессию
    export PATH="$PATH:$INSTALL_DIR"
}

main "$@"
