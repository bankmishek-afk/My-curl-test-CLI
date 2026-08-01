#!/bin/bash
# ============================================================
# 🗑️ MYCLI UNINSTALLER v3.0
# Современный деинсталлятор с подтверждением
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
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/mycli"
DATA_DIR="$HOME/.local/share/mycli"
CLI_NAME="mycli"
VERSION="3.0.0"

# ========== GUI ФУНКЦИИ ==========

# Большой баннер удаления
draw_uninstall_header() {
    clear
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
    echo "║          ${WHITE}${BOLD}УДАЛЕНИЕ MYCLI v${VERSION}${RED}                       ║"
    echo "║          ${GRAY}Внимание! Это действие необратимо!${RED}              ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
}

# Интерактивное меню выбора
show_confirmation_menu() {
    echo -e "${YELLOW}${BOLD}⚠️  ВНИМАНИЕ!${RESET}"
    echo -e "${YELLOW}Вы собираетесь удалить MyCLI и все связанные с ним файлы.${RESET}"
    echo ""
    echo -e "${CYAN}Будут удалены:${RESET}"
    echo -e "  ${GRAY}•${RESET} Исполняемый файл: ${BOLD}$INSTALL_DIR/$CLI_NAME${RESET}"
    echo -e "  ${GRAY}•${RESET} Конфигурация: ${BOLD}$CONFIG_DIR${RESET}"
    echo -e "  ${GRAY}•${RESET} Данные: ${BOLD}$DATA_DIR${RESET}"
    echo -e "  ${GRAY}•${RESET} Алиасы из .bashrc/.zshrc${RESET}"
    echo ""
    echo -e "${RED}${BOLD}⛔ Это действие НЕЛЬЗЯ будет отменить!${RESET}"
    echo ""
    
    # Красивое меню подтверждения
    local options=("✅ Да, удалить всё" "❌ Нет, оставить" "📦 Только удалить исполняемый файл" "⚙️ Только удалить конфиги")
    local selected=0
    
    echo -e "${CYAN}${BOLD}Что вы хотите сделать?${RESET}"
    echo ""
    
    while true; do
        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e "  ${GREEN}${BOLD}▶${RESET} ${GREEN}${BOLD}${options[$i]}${RESET} ${DIM}(выбрано)${RESET}"
            else
                echo -e "    ${DIM}${options[$i]}${RESET}"
            fi
        done
        
        echo ""
        echo -e "${DIM}↑/↓ - выбрать, Enter - подтвердить, Ctrl+C - отмена${RESET}"
        
        read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key
            if [[ $key == '[A' ]]; then
                selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} ))
            elif [[ $key == '[B' ]]; then
                selected=$(( (selected + 1) % ${#options[@]} ))
            fi
        elif [[ $key == "" ]]; then
            break
        fi
    done
    
    echo ""
    return $selected
}

# Прогресс-бар удаления
show_progress() {
    local current=$1
    local total=$2
    local message="$3"
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    
    echo -ne "\r${CYAN}┃${RESET} "
    for ((i=0; i<width; i++)); do
        if [ $i -lt $filled ]; then
            echo -ne "${BG_RED}${WHITE} ${RESET}"
        else
            echo -ne "${BG_BLACK}${WHITE} ${RESET}"
        fi
    done
    echo -ne " ${CYAN}${BOLD}${percent}%${RESET} ${message}"
}

# ========== ФУНКЦИИ УДАЛЕНИЯ ==========

remove_executable() {
    echo -e "${BLUE}🗑️  Удаление исполняемого файла...${RESET}"
    if [ -f "$INSTALL_DIR/$CLI_NAME" ]; then
        rm -f "$INSTALL_DIR/$CLI_NAME"
        echo -e "  ${GREEN}✅ Удалён: $INSTALL_DIR/$CLI_NAME${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Файл не найден: $INSTALL_DIR/$CLI_NAME${RESET}"
    fi
    echo ""
}

remove_config() {
    echo -e "${BLUE}🗑️  Удаление конфигурации...${RESET}"
    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        echo -e "  ${GREEN}✅ Удалена директория: $CONFIG_DIR${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Директория не найдена: $CONFIG_DIR${RESET}"
    fi
    echo ""
}

remove_data() {
    echo -e "${BLUE}🗑️  Удаление данных...${RESET}"
    if [ -d "$DATA_DIR" ]; then
        rm -rf "$DATA_DIR"
        echo -e "  ${GREEN}✅ Удалена директория: $DATA_DIR${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Директория не найдена: $DATA_DIR${RESET}"
    fi
    echo ""
}

clean_shell_config() {
    echo -e "${BLUE}🗑️  Очистка конфигурации оболочки...${RESET}"
    
    local shell_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")
    
    for file in "${shell_files[@]}"; do
        if [ -f "$file" ]; then
            # Создаём бэкап
            cp "$file" "$file.mycli.backup"
            echo -e "  ${GREEN}✅ Создан бэкап: $file.mycli.backup${RESET}"
            
            # Удаляем строки с MyCLI
            sed -i.bak '/# MyCLI Configuration/d' "$file"
            sed -i.bak '/export PATH=.*\.local\/bin/d' "$file"
            sed -i.bak '/alias mycli=/d' "$file"
            sed -i.bak '/alias mchelp=/d' "$file"
            sed -i.bak '/source.*mycli\/completions/d' "$file"
            
            echo -e "  ${GREEN}✅ Очищен: $file${RESET}"
        fi
    done
    
    echo ""
}

show_uninstall_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}║${RESET}                                                              ${GREEN}${BOLD}║${RESET}"
    echo -e "${GREEN}${BOLD}║${RESET}        ${RED}${BOLD}🗑️  УДАЛЕНИЕ УСПЕШНО ЗАВЕРШЕНО! ${GREEN}${BOLD}        ║${RESET}"
    echo -e "${GREEN}${BOLD}║${RESET}                                                              ${GREEN}${BOLD}║${RESET}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "${YELLOW}${BOLD}📝 Что было сделано:${RESET}"
    echo -e "  ${GREEN}✅${RESET} Удалены все файлы MyCLI"
    echo -e "  ${GREEN}✅${RESET} Очищены конфигурации оболочки"
    echo -e "  ${GREEN}✅${RESET} Созданы бэкапы (если были изменения)"
    echo ""
    
    echo -e "${CYAN}${BOLD}💡 Дальнейшие действия:${RESET}"
    echo -e "  ${GRAY}1.${RESET} Перезагрузите терминал для применения изменений"
    echo -e "  ${GRAY}2.${RESET} Если нужно восстановить, проверьте файлы *.mycli.backup"
    echo -e "  ${GRAY}3.${RESET} Чтобы установить заново: ${CYAN}curl -fsSL [URL]/install.sh | bash${RESET}"
    echo ""
    
    echo -e "${RED}${BOLD}👋 MyCLI удалён! Спасибо, что использовали наш инструмент!${RESET}"
    echo ""
}

# ========== MAIN ==========
main() {
    # Показываем баннер
    draw_uninstall_header
    
    # Проверяем, установлен ли CLI
    if [ ! -f "$INSTALL_DIR/$CLI_NAME" ] && [ ! -d "$CONFIG_DIR" ] && [ ! -d "$DATA_DIR" ]; then
        echo -e "${YELLOW}⚠️  MyCLI не найден в системе.${RESET}"
        echo -e "${DIM}Похоже, MyCLI уже удалён или не был установлен.${RESET}"
        echo ""
        exit 0
    fi
    
    # Показываем меню подтверждения
    show_confirmation_menu
    local choice=$?
    
    # Обработка выбора
    case $choice in
        0) # Удалить всё
            echo -e "${RED}${BOLD}⏳ Начинаем полное удаление...${RESET}"
            echo ""
            
            # Показываем прогресс
            steps=4
            current=0
            
            ((current++))
            show_progress $current $steps "Удаление исполняемых файлов..."
            remove_executable > /dev/null 2>&1
            
            ((current++))
            show_progress $current $steps "Удаление конфигурации..."
            remove_config > /dev/null 2>&1
            
            ((current++))
            show_progress $current $steps "Удаление данных..."
            remove_data > /dev/null 2>&1
            
            ((current++))
            show_progress $current $steps "Очистка оболочки..."
            clean_shell_config > /dev/null 2>&1
            
            echo ""
            echo ""
            
            # Показываем итоговую информацию
            remove_executable
            remove_config
            remove_data
            clean_shell_config
            show_uninstall_summary
            ;;
            
        1) # Отмена
            echo -e "${GREEN}✅ Удаление отменено. MyCLI сохранён.${RESET}"
            exit 0
            ;;
            
        2) # Только исполняемый файл
            echo -e "${YELLOW}${BOLD}⏳ Удаление только исполняемого файла...${RESET}"
            echo ""
            remove_executable
            echo -e "${GREEN}✅ Исполняемый файл удалён. Конфиги и данные сохранены.${RESET}"
            echo -e "${DIM}Для полного удаления запустите uninstall снова.${RESET}"
            ;;
            
        3) # Только конфиги
            echo -e "${YELLOW}${BOLD}⏳ Удаление только конфигурации...${RESET}"
            echo ""
            remove_config
            remove_data
            echo -e "${GREEN}✅ Конфиги удалены. Исполняемый файл сохранён.${RESET}"
            echo -e "${DIM}Для полного удаления запустите uninstall снова.${RESET}"
            ;;
    esac
    
    log "MyCLI удалён"
}

# ========== ЗАПУСК ==========
main "$@"
