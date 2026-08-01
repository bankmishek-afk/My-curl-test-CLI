#!/bin/bash
# ============================================================
# 🗑️ MYCLI UNINSTALLER v3.3 - FULL CLEAN
# Полное удаление MyCLI
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
CYAN='\033[36m'

# ========== ПЕРЕМЕННЫЕ ==========
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/mycli"
DATA_DIR="$HOME/.local/share/mycli"
CLI_NAME="mycli"

# ========== ФУНКЦИИ ==========

draw_header() {
    echo ""
    echo -e "${RED}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║     ██╗   ██╗███╗   ██╗██╗███╗   ██╗███████╗████████╗    ║"
    echo "║     ██║   ██║████╗  ██║██║████╗  ██║██╔════╝╚══██╔══╝    ║"
    echo "║     ██║   ██║██╔██╗ ██║██║██╔██╗ ██║███████╗   ██║       ║"
    echo "║     ██║   ██║██║╚██╗██║██║██║╚██╗██║╚════██║   ██║       ║"
    echo "║     ╚██████╔╝██║ ╚████║██║██║ ╚████║███████║   ██║       ║"
    echo "║      ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝       ║"
    echo "║                                                              ║"
    echo "║          ${WHITE}${BOLD}УДАЛЕНИЕ MYCLI${RED}                               ║"
    echo "║          ${GRAY}Внимание! Это действие необратимо!${RED}              ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
}

# ========== УДАЛЕНИЕ ==========

remove_all() {
    echo -e "${BLUE}🗑️  Удаление MyCLI...${RESET}"
    echo ""
    
    # 1. Удаляем исполняемый файл
    if [ -f "$INSTALL_DIR/$CLI_NAME" ]; then
        rm -f "$INSTALL_DIR/$CLI_NAME"
        echo -e "  ${GREEN}✅ Удалён: $INSTALL_DIR/$CLI_NAME${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Не найден: $INSTALL_DIR/$CLI_NAME${RESET}"
    fi
    
    # 2. Удаляем конфигурацию
    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        echo -e "  ${GREEN}✅ Удалена: $CONFIG_DIR${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Не найдена: $CONFIG_DIR${RESET}"
    fi
    
    # 3. Удаляем данные
    if [ -d "$DATA_DIR" ]; then
        rm -rf "$DATA_DIR"
        echo -e "  ${GREEN}✅ Удалена: $DATA_DIR${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Не найдена: $DATA_DIR${RESET}"
    fi
    
    echo ""
}

clean_shell() {
    echo -e "${BLUE}🧹 Очистка конфигурации оболочки...${RESET}"
    
    local files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            # Создаём бэкап
            cp "$file" "$file.mycli.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Удаляем строки с MyCLI
            sed -i '/# MyCLI Configuration/d' "$file" 2>/dev/null || true
            sed -i '/export PATH=.*\.local\/bin/d' "$file" 2>/dev/null || true
            sed -i '/alias mycli=/d' "$file" 2>/dev/null || true
            sed -i '/alias mchelp=/d' "$file" 2>/dev/null || true
            sed -i '/source.*mycli\/completions/d' "$file" 2>/dev/null || true
            
            echo -e "  ${GREEN}✅ Очищен: $file${RESET}"
            echo -e "  ${DIM}   Бэкап: $file.mycli.backup.*${RESET}"
        fi
    done
    
    echo ""
}

remove_alias() {
    echo -e "${BLUE}🔨 Удаление алиаса из текущей сессии...${RESET}"
    
    # Удаляем алиас из текущей сессии
    unalias mycli 2>/dev/null || true
    
    # Удаляем из PATH
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v "$INSTALL_DIR" | tr '\n' ':' | sed 's/:$//')
    
    echo -e "  ${GREEN}✅ Алиас удалён из текущей сессии${RESET}"
    echo ""
}

show_completion() {
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}║${RESET}                                                              ${GREEN}${BOLD}║${RESET}"
    echo -e "${GREEN}${BOLD}║${RESET}        ${RED}${BOLD}🗑️  УДАЛЕНИЕ УСПЕШНО ЗАВЕРШЕНО! ${GREEN}${BOLD}        ║${RESET}"
    echo -e "${GREEN}${BOLD}║${RESET}                                                              ${GREEN}${BOLD}║${RESET}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "${YELLOW}${BOLD}📝 Что было удалено:${RESET}"
    echo -e "  ${GREEN}✅${RESET} Исполняемый файл: $INSTALL_DIR/$CLI_NAME"
    echo -e "  ${GREEN}✅${RESET} Конфигурация: $CONFIG_DIR"
    echo -e "  ${GREEN}✅${RESET} Данные: $DATA_DIR"
    echo -e "  ${GREEN}✅${RESET} Алиасы и PATH из .bashrc/.zshrc"
    echo ""
    
    echo -e "${CYAN}${BOLD}💡 Дальнейшие действия:${RESET}"
    echo -e "  ${GRAY}1.${RESET} Перезапустите терминал или выполните: ${CYAN}exec bash${RESET}"
    echo -e "  ${GRAY}2.${RESET} Если нужно восстановить, проверьте файлы *.mycli.backup.*"
    echo -e "  ${GRAY}3.${RESET} Чтобы установить заново: ${CYAN}curl -fsSL [URL]/install.sh | bash${RESET}"
    echo ""
    
    echo -e "${RED}${BOLD}👋 MyCLI удалён!${RESET}"
    echo ""
}

# ========== MAIN ==========
main() {
    draw_header
    
    # Проверяем, установлен ли CLI
    local installed=false
    if [ -f "$INSTALL_DIR/$CLI_NAME" ] || [ -d "$CONFIG_DIR" ] || [ -d "$DATA_DIR" ]; then
        installed=true
    fi
    
    if [ "$installed" = false ]; then
        echo -e "${YELLOW}⚠️  MyCLI не найден в системе.${RESET}"
        echo -e "${DIM}Похоже, MyCLI уже удалён или не был установлен.${RESET}"
        echo ""
        exit 0
    fi
    
    # Показываем что будет удалено
    echo -e "${YELLOW}${BOLD}⚠️  Будет удалено:${RESET}"
    [ -f "$INSTALL_DIR/$CLI_NAME" ] && echo -e "  ${RED}•${RESET} $INSTALL_DIR/$CLI_NAME"
    [ -d "$CONFIG_DIR" ] && echo -e "  ${RED}•${RESET} $CONFIG_DIR"
    [ -d "$DATA_DIR" ] && echo -e "  ${RED}•${RESET} $DATA_DIR"
    echo -e "  ${RED}•${RESET} Алиасы и PATH из .bashrc/.zshrc"
    echo ""
    
    echo -e "${RED}${BOLD}⛔ Это действие НЕЛЬЗЯ будет отменить!${RESET}"
    echo ""
    
    # Автоматическое удаление (без подтверждения для curl | bash)
    echo -e "${DIM}Автоматическое удаление...${RESET}"
    echo ""
    
    remove_all
    clean_shell
    remove_alias
    show_completion
    
    # Сбрасываем текущую сессию
    echo -e "${CYAN}🔄 Перезагрузите терминал для полной очистки:${RESET}"
    echo -e "  ${DIM}exec bash${RESET}"
    echo ""
}

main "$@"
