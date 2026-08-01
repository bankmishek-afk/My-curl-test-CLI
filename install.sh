#!/bin/bash
# ============================================================
# 🚀 ULTIMATE CLI INSTALLER v3.3 - CODESPACES FIX
# Полностью автоматическая установка с фиксом для Codespaces
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
VERSION="3.3.0"

# ========== ФУНКЦИИ ==========

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
    echo "║          ${GRAY}Optimized for Codespaces${CYAN}                      ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
}

# ========== ОСНОВНЫЕ ФУНКЦИИ ==========

check_requirements() {
    echo -e "${BLUE}🔍 Проверка требований...${RESET}"
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl не найден${RESET}"
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
    
    # Создаём конфиг
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
    
    # Добавляем в PATH если ещё нет
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

# ФИКС: Добавляем в текущую сессию
fix_current_session() {
    echo -e "${BLUE}🔧 Применение настроек в текущей сессии...${RESET}"
    
    # Добавляем в PATH для текущей сессии
    export PATH="$INSTALL_DIR:$PATH"
    
    # Создаём алиас для текущей сессии
    alias mycli="$INSTALL_DIR/$CLI_NAME" 2>/dev/null || true
    
    # Проверяем, что работает
    if command -v mycli &>/dev/null; then
        echo -e "${GREEN}✅ MyCLI доступен в текущей сессии${RESET}"
    else
        echo -e "${YELLOW}⚠️  Используйте полный путь: $INSTALL_DIR/$CLI_NAME${RESET}"
        echo -e "${YELLOW}⚠️  Или выполните: source $HOME/.bashrc${RESET}"
    fi
    
    echo ""
}

test_installation() {
    echo -e "${BLUE}🧪 Тестирование...${RESET}"
    
    # Используем полный путь для теста
    if "$INSTALL_DIR/$CLI_NAME" version &>/dev/null; then
        local version=$("$INSTALL_DIR/$CLI_NAME" version 2>&1 | head -1)
        echo -e "${GREEN}✅ Установка работает: $version${RESET}"
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
    
    echo -e "${YELLOW}${BOLD}📌  ВАЖНО ДЛЯ CODESPACES:${RESET}"
    echo -e "  ${GRAY}•${RESET} MyCLI установлен в: ${CYAN}$INSTALL_DIR/${CLI_NAME}${RESET}"
    echo -e "  ${GRAY}•${RESET} Для использования в ЭТОМ терминале:"
    echo -e "    ${CYAN}source ~/.bashrc${RESET} ${DIM}# или перезапустите терминал${RESET}"
    echo -e "  ${GRAY}•${RESET} Или используйте полный путь: ${CYAN}$INSTALL_DIR/$CLI_NAME help${RESET}"
    echo ""
    
    echo -e "${YELLOW}${BOLD}📌  БЫСТРЫЙ СТАРТ:${RESET}"
    echo -e "  ${GRAY}1.${RESET} Примените настройки: ${CYAN}source ~/.bashrc${RESET}"
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
    
    # Запуск установки
    check_requirements
    create_directories
    download_cli
    setup_shell
    fix_current_session
    test_installation
    show_completion
    
    # Показываем как использовать прямо сейчас
    echo -e "${CYAN}💡 Используйте прямо сейчас:${RESET}"
    echo -e "  ${DIM}$ $INSTALL_DIR/$CLI_NAME version${RESET}"
    echo -e "  ${DIM}$ $INSTALL_DIR/$CLI_NAME help${RESET}"
    echo ""
}

main "$@"
