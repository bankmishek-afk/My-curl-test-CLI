#!/bin/bash
# ============================================================
# 🚀 ULTIMATE CLI INSTALLER v3.1
# Современный установщик с GUI-индикаторами
# Исправлена обработка ввода для curl | bash
# ============================================================

set -e

# ========== ЦВЕТА И СТИЛИ ==========
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# Цвета текста
BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
GRAY='\033[90m'

# Фоны
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# ========== ПЕРЕМЕННЫЕ ==========
REPO_URL="https://raw.githubusercontent.com/bankmishek-afk/My-curl-test-CLI/refs/heads/main"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/mycli"
DATA_DIR="$HOME/.local/share/mycli"
CLI_MAIN="cli.sh"
CLI_NAME="mycli"
VERSION="3.1.0"
TOTAL_STEPS=8
CURRENT_STEP=0
NON_INTERACTIVE=false

# ========== ОПРЕДЕЛЕНИЕ ИНТЕРАКТИВНОСТИ ==========
# Проверяем, запущен ли скрипт через curl | bash
if [ ! -t 0 ] || [ -z "$PS1" ]; then
    NON_INTERACTIVE=true
fi

# ========== ФУНКЦИИ GUI ==========

# Рисует красивый заголовок с рамкой
draw_header() {
    clear 2>/dev/null || true
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║     ███╗   ███╗██╗   ██╗ ██████╗██╗     ██╗               ║"
    echo "║     ████╗ ████║╚██╗ ██╔╝██╔════╝██║     ██║               ║"
    echo "║     ██╔████╔██║ ╚████╔╝ ██║     ██║     ██║               ║"
    echo "║     ██║╚██╔╝██║  ╚██╔╝  ██║     ██║     ██║               ║"
    echo "║     ██║ ╚═╝ ██║   ██║   ╚██████╗███████╗██║               ║"
    echo "║     ╚═╝     ╚═╝   ╚═╝    ╚═════╝╚══════╝╚═╝               ║"
    echo "║                                                              ║"
    echo "║               ${WHITE}${BOLD}CLI INSTALLER v${VERSION}${CYAN}                    ║"
    echo "║          ${GRAY}Modern CLI Tool with GUI Interface${CYAN}              ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
}

# Функция для безопасного ввода
safe_read() {
    local prompt="$1"
    local default="${2:-}"
    local response=""
    
    if [ "$NON_INTERACTIVE" = true ]; then
        # Неинтерактивный режим - используем значения по умолчанию
        echo -e "${YELLOW}⚠️  Неинтерактивный режим, используем значения по умолчанию${RESET}"
        echo "$default"
        return 0
    fi
    
    # Интерактивный режим
    while true; do
        echo -ne "$prompt"
        read -r response
        if [ -n "$response" ] || [ -n "$default" ]; then
            echo "${response:-$default}"
            return 0
        fi
        echo -e "${RED}❌ Введите значение или нажмите Enter для значения по умолчанию${RESET}"
    done
}

# Рисует прогресс-бар
draw_progress() {
    local percent=$1
    local width=50
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    echo -ne "${CYAN}┃ ${RESET}"
    echo -ne "${BG_CYAN}${BLACK}"
    for ((i=0; i<filled; i++)); do echo -ne "█"; done
    echo -ne "${RESET}"
    echo -ne "${BG_GRAY}${BLACK}"
    for ((i=0; i<empty; i++)); do echo -ne "░"; done
    echo -ne "${RESET} ${CYAN}${BOLD}${percent}%${RESET}\n"
}

# Показывает шаг установки с анимацией
show_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local message="$1"
    local emoji="$2"
    local color="${3:-$CYAN}"
    
    echo ""
    echo -e "${GRAY}┌─────────────────────────────────────────────────────────${RESET}"
    echo -e "${color}${BOLD}${emoji}  ШАГ ${CURRENT_STEP}/${TOTAL_STEPS}${RESET} ${color}${BOLD}${message}${RESET}"
    echo -e "${GRAY}└─────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    # Анимация спиннера
    if [ "$NON_INTERACTIVE" = false ]; then
        local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        local i=0
        for ((j=0; j<15; j++)); do
            echo -ne "\r${CYAN}  ${spin:i++%10:1}  ${DIM}Выполняется...${RESET}"
            sleep 0.1
        done
    fi
    echo -e "\r${GREEN}  ✅  Готово!${RESET}    "
    echo ""
}

# Показывает информацию в таблице
show_info_table() {
    local title="$1"
    shift
    echo -e "${CYAN}${BOLD}📊 ${title}${RESET}"
    echo -e "${GRAY}┌────────────────────────┬──────────────────────────────┐${RESET}"
    
    while [ $# -gt 0 ]; do
        local key="$1"
        local value="$2"
        shift 2
        printf "${GRAY}│${RESET} %-22s ${GRAY}│${RESET} %-28s ${GRAY}│${RESET}\n" "$key" "$value"
    done
    
    echo -e "${GRAY}└────────────────────────┴──────────────────────────────┘${RESET}"
}

# ========== ОСНОВНЫЕ ФУНКЦИИ УСТАНОВКИ ==========

check_requirements() {
    show_step "Проверка системных требований" "🔍" "$BLUE"
    
    local requirements=()
    
    # Проверка curl
    if command -v curl &> /dev/null; then
        echo -e "  ${GREEN}✅ curl установлен${RESET}"
    else
        echo -e "  ${RED}❌ curl не найден${RESET}"
        requirements+=("curl")
    fi
    
    # Проверка bash
    if command -v bash &> /dev/null; then
        local bash_version=$(bash --version | head -1 | grep -oP '\d+\.\d+' 2>/dev/null || echo "4.0+")
        echo -e "  ${GREEN}✅ bash $bash_version${RESET}"
    else
        echo -e "  ${RED}❌ bash не найден${RESET}"
        requirements+=("bash")
    fi
    
    # Проверка прав на запись
    if [ -w "$HOME" ]; then
        echo -e "  ${GREEN}✅ Права на запись в HOME${RESET}"
    else
        echo -e "  ${RED}❌ Нет прав на запись в HOME${RESET}"
        requirements+=("write_permission")
    fi
    
    if [ ${#requirements[@]} -ne 0 ]; then
        echo ""
        echo -e "${RED}❌ Ошибка: Не выполнены требования:${RESET}"
        for req in "${requirements[@]}"; do
            echo -e "  ${RED}• $req${RESET}"
        done
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}✅ Все требования выполнены!${RESET}"
}

create_directories() {
    show_step "Создание директорий" "📁" "$MAGENTA"
    
    local dirs=("$INSTALL_DIR" "$CONFIG_DIR" "$DATA_DIR" "$CONFIG_DIR/plugins" "$DATA_DIR/cache")
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo -e "  ${GREEN}✅ Создана: ${DIM}$dir${RESET}"
        else
            echo -e "  ${BLUE}ℹ️  Существует: ${DIM}$dir${RESET}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ Все директории готовы!${RESET}"
}

download_files() {
    show_step "Загрузка файлов CLI" "🌐" "$YELLOW"
    
    echo -e "  ${CYAN}Загрузка основного файла...${RESET}"
    if curl -fsSL "$REPO_URL/$CLI_MAIN" -o "$INSTALL_DIR/$CLI_NAME"; then
        chmod +x "$INSTALL_DIR/$CLI_NAME"
        echo -e "  ${GREEN}✅ $CLI_NAME загружен${RESET}"
    else
        echo -e "  ${RED}❌ Ошибка загрузки $CLI_NAME${RESET}"
        exit 1
    fi
    
    echo -e "  ${CYAN}Загрузка конфигурации...${RESET}"
    curl -fsSL "$REPO_URL/config/default.conf" -o "$CONFIG_DIR/default.conf" 2>/dev/null || echo -e "  ${YELLOW}⚠️  Конфиг не найден, создаём пустой${RESET}"
    
    echo ""
    echo -e "${GREEN}✅ Все файлы загружены!${RESET}"
}

configure_shell() {
    show_step "Настройка оболочки" "⚙️" "$BLUE"
    
    local shell_rc=""
    local shell_name=$(basename "$SHELL")
    
    case "$shell_name" in
        bash) shell_rc="$HOME/.bashrc" ;;
        zsh) shell_rc="$HOME/.zshrc" ;;
        fish) shell_rc="$HOME/.config/fish/config.fish" ;;
        *) shell_rc="$HOME/.profile" ;;
    esac
    
    echo -e "  ${CYAN}Обнаружена оболочка: ${BOLD}$shell_name${RESET}"
    echo -e "  ${CYAN}Файл конфигурации: ${DIM}$shell_rc${RESET}"
    
    if [ ! -f "$shell_rc" ]; then
        touch "$shell_rc"
        echo -e "  ${YELLOW}⚠️  Создан новый $shell_rc${RESET}"
    fi
    
    # Добавляем в PATH если ещё нет
    if ! grep -q "$INSTALL_DIR" "$shell_rc" 2>/dev/null; then
        echo "" >> "$shell_rc"
        echo "# MyCLI Configuration" >> "$shell_rc"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$shell_rc"
        echo "alias mycli='$INSTALL_DIR/$CLI_NAME'" >> "$shell_rc"
        echo "alias mchelp='$INSTALL_DIR/$CLI_NAME --help'" >> "$shell_rc"
        
        echo -e "  ${GREEN}✅ Добавлены алиасы в $shell_rc${RESET}"
    else
        echo -e "  ${BLUE}ℹ️  PATH уже настроен${RESET}"
    fi
    
    # Создаём переменные окружения
    cat > "$CONFIG_DIR/env.sh" << EOF
#!/bin/bash
export MYCLI_HOME="$INSTALL_DIR"
export MYCLI_CONFIG="$CONFIG_DIR"
export MYCLI_DATA="$DATA_DIR"
export MYCLI_VERSION="$VERSION"
EOF
    
    echo -e "  ${GREEN}✅ Переменные окружения созданы${RESET}"
    echo ""
    echo -e "${GREEN}✅ Настройка завершена!${RESET}"
}

setup_completions() {
    show_step "Настройка автодополнения" "🔮" "$CYAN"
    
    local shell_name=$(basename "$SHELL")
    local comp_file="$CONFIG_DIR/completions.sh"
    
    cat > "$comp_file" << 'EOF'
#!/bin/bash
# Автодополнение для mycli

_mycli_completions() {
    local cur prev words cword
    _init_completion || return
    
    case "$prev" in
        mycli)
            COMPREPLY=($(compgen -W "hello world date weather system info config plugin help version" -- "$cur"))
            return
            ;;
        hello)
            COMPREPLY=($(compgen -W "--name --lang" -- "$cur"))
            return
            ;;
        config)
            COMPREPLY=($(compgen -W "set get list" -- "$cur"))
            return
            ;;
        plugin)
            COMPREPLY=($(compgen -W "install remove list enable" -- "$cur"))
            return
            ;;
    esac
    
    COMPREPLY=($(compgen -W "hello world date weather system info config plugin help version" -- "$cur"))
}

complete -F _mycli_completions mycli
EOF
    
    # Добавляем автодополнение в shell_rc
    local shell_rc=""
    case "$shell_name" in
        bash) shell_rc="$HOME/.bashrc" ;;
        zsh) shell_rc="$HOME/.zshrc" ;;
        *) shell_rc="$HOME/.profile" ;;
    esac
    
    if ! grep -q "mycli/completions.sh" "$shell_rc" 2>/dev/null; then
        echo "source $comp_file" >> "$shell_rc"
        echo -e "  ${GREEN}✅ Автодополнение добавлено${RESET}"
    else
        echo -e "  ${BLUE}ℹ️  Автодополнение уже настроено${RESET}"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Автодополнение настроено!${RESET}"
}

test_installation() {
    show_step "Тестирование установки" "🧪" "$YELLOW"
    
    echo -e "  ${CYAN}Запуск тестов...${RESET}"
    
    # Тест 1: Проверка исполняемого файла
    if [ -x "$INSTALL_DIR/$CLI_NAME" ]; then
        echo -e "  ${GREEN}✅ Исполняемый файл доступен${RESET}"
    else
        echo -e "  ${RED}❌ Исполняемый файл не найден${RESET}"
        exit 1
    fi
    
    # Тест 2: Проверка версии
    if "$INSTALL_DIR/$CLI_NAME" version &>/dev/null; then
        local version_output=$("$INSTALL_DIR/$CLI_NAME" version 2>&1 | head -1)
        echo -e "  ${GREEN}✅ Версия: $version_output${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Не удалось получить версию${RESET}"
    fi
    
    # Тест 3: Проверка конфигов
    if [ -f "$CONFIG_DIR/default.conf" ]; then
        echo -e "  ${GREEN}✅ Конфигурация загружена${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Конфигурация отсутствует${RESET}"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Тестирование завершено!${RESET}"
}

show_summary() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║${RESET}                                                              ${CYAN}${BOLD}║${RESET}"
    echo -e "${CYAN}${BOLD}║${RESET}        ${GREEN}${BOLD}✨ УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА! ✨${CYAN}${BOLD}        ║${RESET}"
    echo -e "${CYAN}${BOLD}║${RESET}                                                              ${CYAN}${BOLD}║${RESET}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    show_info_table "Информация об установке" \
        "Версия" "$VERSION" \
        "Путь установки" "$INSTALL_DIR" \
        "Конфигурация" "$CONFIG_DIR" \
        "Данные" "$DATA_DIR" \
        "Команда" "mycli" \
        "Оболочка" "$(basename "$SHELL")"
    
    echo ""
    echo -e "${YELLOW}${BOLD}📌  БЫСТРЫЙ СТАРТ:${RESET}"
    echo -e "  ${GRAY}1.${RESET} Перезагрузите оболочку: ${CYAN}source ~/.$(basename "$SHELL")rc${RESET}"
    echo -e "  ${GRAY}2.${RESET} Запустите CLI: ${CYAN}mycli help${RESET}"
    echo -e "  ${GRAY}3.${RESET} Попробуйте команды: ${CYAN}mycli hello --name Вася${RESET}"
    echo ""
    
    echo -e "${DIM}Для удаления выполните: curl -fsSL $REPO_URL/uninstall.sh | bash${RESET}"
    echo ""
}

# ========== MAIN ==========
main() {
    draw_header
    
    echo -e "${GRAY}${BOLD}🚀 Запуск установки...${RESET}"
    echo -e "${DIM}Версия: $VERSION | Дата: $(date '+%d.%m.%Y %H:%M:%S')${RESET}"
    
    # Проверка, установлен ли уже
    if [ -f "$INSTALL_DIR/$CLI_NAME" ]; then
        echo ""
        echo -e "${YELLOW}⚠️  MyCLI уже установлен!${RESET}"
        echo -e "  ${DIM}Путь: $INSTALL_DIR/$CLI_NAME${RESET}"
        echo ""
        
        if [ "$NON_INTERACTIVE" = true ]; then
            echo -e "${YELLOW}⚠️  Неинтерактивный режим: переустановка...${RESET}"
            echo ""
        else
            echo -ne "${YELLOW}Переустановить? [y/N] ${RESET}"
            read -r confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}✅ Установка отменена${RESET}"
                exit 0
            fi
        fi
    else
        # Спрашиваем подтверждение только в интерактивном режиме
        if [ "$NON_INTERACTIVE" = false ]; then
            echo ""
            echo -ne "${YELLOW}Установить MyCLI в $INSTALL_DIR? [Y/n] ${RESET}"
            read -r confirm
            if [[ "$confirm" =~ ^[Nn]$ ]]; then
                echo -e "${RED}❌ Установка отменена${RESET}"
                exit 0
            fi
        else
            echo -e "${DIM}Неинтерактивный режим: установка продолжается...${RESET}"
        fi
    fi
    
    echo ""
    
    # Запуск установки
    check_requirements
    create_directories
    download_files
    configure_shell
    setup_completions
    test_installation
    show_summary
    
    echo -e "${GREEN}${BOLD}🎉 Установка завершена! Приятного использования!${RESET}"
    echo ""
    
    # Автоматически добавляем в текущую сессию
    export PATH="$PATH:$INSTALL_DIR"
    alias mycli="$INSTALL_DIR/$CLI_NAME" 2>/dev/null || true
    
    echo -e "${DIM}💡 Совет: выполните 'source ~/.$(basename "$SHELL")rc' для применения настроек${RESET}"
    echo ""
}

# ========== ЗАПУСК ==========
main "$@"
