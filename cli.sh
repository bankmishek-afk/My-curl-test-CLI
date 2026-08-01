#!/bin/bash
# ============================================================
# 🌟 MYCLI - Ultimate Modern CLI Tool
# Полнофункциональный CLI с GUI интерфейсом
# Версия: 3.0.0
# ============================================================

set -e

# ========== ЦВЕТА ==========
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'

BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
GRAY='\033[90m'

BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# ========== ПЕРЕМЕННЫЕ ==========
VERSION="3.0.0"
CONFIG_DIR="${MYCLI_CONFIG:-$HOME/.config/mycli}"
DATA_DIR="${MYCLI_DATA:-$HOME/.local/share/mycli}"
PLUGIN_DIR="$CONFIG_DIR/plugins"
CACHE_DIR="$DATA_DIR/cache"
LOG_FILE="$DATA_DIR/mycli.log"

# ========== ИНИЦИАЛИЗАЦИЯ ==========
mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$PLUGIN_DIR" "$CACHE_DIR" 2>/dev/null

# ========== УТИЛИТЫ ==========

# Логирование
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# GUI Рамка
draw_box() {
    local text="$1"
    local color="${2:-$CYAN}"
    local width=$(( ${#text} + 4 ))
    
    echo -e "${color}┌$(printf '─%.0s' $(seq 1 $width))┐${RESET}"
    echo -e "${color}│ ${BOLD}${text}${RESET}${color} │${RESET}"
    echo -e "${color}└$(printf '─%.0s' $(seq 1 $width))┘${RESET}"
}

# Спиннер загрузки
show_spinner() {
    local pid=$1
    local message="$2"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r${CYAN}${spin:i++%10:1}${RESET} ${message}"
        sleep 0.1
    done
    echo -e "\r${GREEN}✅${RESET} ${message} - ${GREEN}Готово!${RESET}    "
}

# Прогресс-бар
progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    echo -ne "\r${CYAN}[${RESET}"
    echo -ne "${BG_GREEN}${BLACK}"
    for ((i=0; i<filled; i++)); do echo -ne "█"; done
    echo -ne "${RESET}"
    echo -ne "${BG_BLACK}${WHITE}"
    for ((i=0; i<empty; i++)); do echo -ne "░"; done
    echo -ne "${RESET}${CYAN}]${RESET} ${BOLD}${percent}%${RESET}"
}

# Проверка наличия команды
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ========== ОСНОВНЫЕ КОМАНДЫ ==========

# Команда: hello - приветствие
cmd_hello() {
    local name=""
    local lang="ru"
    local emoji="👋"
    
    # Парсинг аргументов
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name|-n)
                name="$2"
                shift 2
                ;;
            --lang|-l)
                lang="$2"
                shift 2
                ;;
            --emoji|-e)
                emoji="$2"
                shift 2
                ;;
            *)
                if [[ -z "$name" ]]; then
                    name="$1"
                    shift
                else
                    echo -e "${RED}❌ Неизвестный аргумент: $1${RESET}"
                    return 1
                fi
                ;;
        esac
    done
    
    if [[ -z "$name" ]]; then
        name="Мир"
    fi
    
    # Приветствие на разных языках
    local greetings=()
    case "$lang" in
        ru) greetings=("Привет" "Здравствуйте" "Приветствую" "Салют") ;;
        en) greetings=("Hello" "Hi" "Hey" "Greetings") ;;
        es) greetings=("Hola" "Buenos días" "Saludos") ;;
        fr) greetings=("Bonjour" "Salut" "Coucou") ;;
        de) greetings=("Hallo" "Guten Tag" "Servus") ;;
        it) greetings=("Ciao" "Buongiorno" "Salve") ;;
        *) greetings=("Hello" "Привет" "Hola" "Bonjour") ;;
    esac
    
    local greeting=${greetings[$RANDOM % ${#greetings[@]}]}
    
    # Красивое отображение
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║${RESET}  $emoji  ${GREEN}${BOLD}${greeting}, ${name}!${RESET}  ${CYAN}${BOLD}║${RESET}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Дополнительная информация
    echo -e "${DIM}📅 $(date '+%A, %d %B %Y')${RESET}"
    echo -e "${DIM}⏰ $(date '+%H:%M:%S')${RESET}"
    echo ""
    
    # Мотивационная цитата
    local quotes=(
        "Жизнь — это то, что происходит, пока вы строите планы."
        "Будьте изменением, которое хотите видеть в мире."
        "Сложнее всего начать действовать, все остальное зависит только от упорства."
        "Секрет успеха — в постоянстве цели."
        "Верьте в себя и всё получится!"
    )
    echo -e "${ITALIC}💭 ${quotes[$RANDOM % ${#quotes[@]}]}${RESET}"
    echo ""
    
    log "Приветствие: $name ($lang)"
}

# Команда: world - мир приветствует вас
cmd_world() {
    echo ""
    draw_box "🌍 МИР ПРИВЕТСТВУЕТ ВАС!" "$GREEN"
    echo ""
    
    # Анимация мира
    local earth=(
        "   🌍   "
        "  🌍🌍  "
        " 🌍🌍🌍 "
        "🌍🌍🌍🌍"
        " 🌍🌍🌍 "
        "  🌍🌍  "
        "   🌍   "
    )
    
    for line in "${earth[@]}"; do
        echo -e "${GREEN}${BOLD}${line}${RESET}"
        sleep 0.1
    done
    
    echo ""
    
    # Статистика
    local countries=195
    local population="8.1 миллиарда"
    local languages=7100
    
    echo -e "${CYAN}📊 Статистика мира:${RESET}"
    echo -e "  ${GREEN}•${RESET} Стран: ${BOLD}$countries${RESET}"
    echo -e "  ${GREEN}•${RESET} Население: ${BOLD}$population${RESET}"
    echo -e "  ${GREEN}•${RESET} Языков: ${BOLD}$languages${RESET}"
    echo ""
    
    # Случайный факт о мире
    local facts=(
        "Самая высокая гора — Эверест (8848 м)"
        "Самая длинная река — Нил (6670 км)"
        "Самое большое озеро — Каспийское море"
        "Самая пустынная пустыня — Антарктида"
    )
    echo -e "${YELLOW}💡 Интересный факт:${RESET} ${facts[$RANDOM % ${#facts[@]}]}"
    echo ""
    
    log "Показан мир"
}

# Команда: date - работа с датами
cmd_date() {
    local format="full"
    local timezone=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --format|-f)
                format="$2"
                shift 2
                ;;
            --timezone|-z)
                timezone="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}❌ Неизвестный аргумент: $1${RESET}"
                return 1
                ;;
        esac
    done
    
    echo ""
    draw_box "📅 ДАТА И ВРЕМЯ" "$MAGENTA"
    echo ""
    
    # Календарь на месяц
    echo -e "${CYAN}${BOLD}📆 Календарь${RESET}"
    echo ""
    cal -3
    echo ""
    
    # Подробная информация
    echo -e "${CYAN}${BOLD}⏰ Подробно:${RESET}"
    echo -e "  ${GREEN}•${RESET} Дата: ${BOLD}$(date '+%A, %d %B %Y')${RESET}"
    echo -e "  ${GREEN}•${RESET} Время: ${BOLD}$(date '+%H:%M:%S')${RESET}"
    echo -e "  ${GREEN}•${RESET} Неделя: ${BOLD}$(date '+%V')${RESET}"
    echo -e "  ${GREEN}•${RESET} День года: ${BOLD}$(date '+%j')${RESET}"
    echo ""
    
    # Таймер до конца года
    local end_of_year=$(date -d "$(date +%Y)-12-31" +%s)
    local now=$(date +%s)
    local days_left=$(( (end_of_year - now) / 86400 ))
    echo -e "${YELLOW}🎯 До конца года осталось: ${BOLD}${days_left} дней${RESET}"
    echo ""
    
    log "Показана дата"
}

# Команда: weather - погода
cmd_weather() {
    local city="${1:-Москва}"
    local units="metric"
    
    echo ""
    draw_box "🌤️ ПОГОДА В $city" "$BLUE"
    echo ""
    
    # Имитация запроса погоды
    echo -e "${DIM}Загрузка данных о погоде...${RESET}"
    sleep 0.5
    
    # Генерация случайной погоды
    local temps=(-5..35)
    local conditions=("☀️ Ясно" "⛅ Переменная облачность" "☁️ Облачно" "🌧️ Дождь" "🌨️ Снег" "🌤️ Солнечно" "💨 Ветрено")
    local humidity=$((RANDOM % 50 + 40))
    local wind=$((RANDOM % 30 + 1))
    local temp=$((RANDOM % 40 - 5))
    local condition=${conditions[$RANDOM % ${#conditions[@]}]}
    
    # Погодная карта
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET}  $condition                                                  ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}  🌡️  Температура: ${BOLD}${temp}°C${RESET}                                    ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}  💧  Влажность: ${BOLD}${humidity}%${RESET}                                      ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}  💨  Ветер: ${BOLD}${wind} м/с${RESET}                                       ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}  📍  Город: ${BOLD}$city${RESET}                                          ${CYAN}│${RESET}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${RESET}"
    echo ""
    
    # Прогноз на 5 дней
    echo -e "${YELLOW}${BOLD}📊 Прогноз на 5 дней:${RESET}"
    echo ""
    for i in {1..5}; do
        local day_temp=$((temp + RANDOM % 10 - 5))
        local day_cond=${conditions[$RANDOM % ${#conditions[@]}]}
        local day_name=$(date -d "+$i days" '+%a')
        printf "  ${GREEN}%3s${RESET}  %-2s  %-15s  %3d°C\n" "$day_name" ":" "$day_cond" "$day_temp"
    done
    echo ""
    
    log "Погода в $city: $condition, $temp°C"
}

# Команда: system - информация о системе
cmd_system() {
    echo ""
    draw_box "🖥️ СИСТЕМНАЯ ИНФОРМАЦИЯ" "$YELLOW"
    echo ""
    
    # Заголовок
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║${RESET}  ${WHITE}${BOLD}СИСТЕМА${RESET}                                              ${CYAN}${BOLD}║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Информация о системе
    echo -e "${GREEN}📌 ОС:${RESET}     ${BOLD}$(uname -s) $(uname -r)${RESET}"
    echo -e "${GREEN}📌 Хост:${RESET}   ${BOLD}$(hostname)${RESET}"
    echo -e "${GREEN}📌 Пользователь:${RESET} ${BOLD}$(whoami)${RESET}"
    echo -e "${GREEN}📌 Архитектура:${RESET} ${BOLD}$(uname -m)${RESET}"
    echo ""
    
    # CPU
    echo -e "${GREEN}💻 CPU:${RESET}"
    if command_exists nproc; then
        echo -e "  • Ядер: ${BOLD}$(nproc)${RESET}"
    fi
    if command_exists lscpu; then
        echo -e "  • Модель: ${BOLD}$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)${RESET}"
    fi
    echo ""
    
    # Память
    echo -e "${GREEN}🧠 ПАМЯТЬ:${RESET}"
    if command_exists free; then
        local mem_total=$(free -h | grep -i mem | awk '{print $2}')
        local mem_used=$(free -h | grep -i mem | awk '{print $3}')
        local mem_percent=$(free | grep -i mem | awk '{print $3/$2 * 100.0}' | cut -d'.' -f1)
        echo -e "  • Всего: ${BOLD}$mem_total${RESET}"
        echo -e "  • Использовано: ${BOLD}$mem_used${RESET}"
        echo -e "  • Загруженность: ${BOLD}${mem_percent}%${RESET}"
        
        # Визуальный индикатор памяти
        local bar_width=30
        local filled=$((mem_percent * bar_width / 100))
        echo -ne "  • "
        for ((i=0; i<bar_width; i++)); do
            if [ $i -lt $filled ]; then
                echo -ne "${BG_GREEN}${BLACK} ${RESET}"
            else
                echo -ne "${BG_BLACK}${WHITE} ${RESET}"
            fi
        done
        echo ""
    fi
    echo ""
    
    # Диск
    echo -e "${GREEN}💾 ДИСК:${RESET}"
    if command_exists df; then
        df -h / | tail -1 | while read -r line; do
            local total=$(echo $line | awk '{print $2}')
            local used=$(echo $line | awk '{print $3}')
            local avail=$(echo $line | awk '{print $4}')
            local percent=$(echo $line | awk '{print $5}' | sed 's/%//')
            echo -e "  • Всего: ${BOLD}$total${RESET}"
            echo -e "  • Использовано: ${BOLD}$used${RESET}"
            echo -e "  • Свободно: ${BOLD}$avail${RESET}"
            echo -e "  • Занято: ${BOLD}${percent}%${RESET}"
        done
    fi
    echo ""
    
    # Процессы
    echo -e "${GREEN}📊 ПРОЦЕССЫ:${RESET}"
    if command_exists ps; then
        local total_procs=$(ps aux | wc -l)
        local user_procs=$(ps aux | grep "^$(whoami)" | wc -l)
        echo -e "  • Всего: ${BOLD}$total_procs${RESET}"
        echo -e "  • Пользовательских: ${BOLD}$user_procs${RESET}"
    fi
    echo ""
    
    # Загрузка системы
    echo -e "${GREEN}📈 ЗАГРУЗКА:${RESET}"
    if command_exists uptime; then
        uptime | awk -F'load average:' '{print $2}' | while read -r load; do
            echo -e "  • Load Average: ${BOLD}$load${RESET}"
        done
    fi
    echo ""
    
    log "Показана системная информация"
}

# Команда: info - информация о CLI
cmd_info() {
    echo ""
    draw_box "ℹ️ ИНФОРМАЦИЯ О CLI" "$MAGENTA"
    echo ""
    
    # ASCII лого
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
    ███╗   ███╗██╗   ██╗ ██████╗██╗     ██╗
    ████╗ ████║╚██╗ ██╔╝██╔════╝██║     ██║
    ██╔████╔██║ ╚████╔╝ ██║     ██║     ██║
    ██║╚██╔╝██║  ╚██╔╝  ██║     ██║     ██║
    ██║ ╚═╝ ██║   ██║   ╚██████╗███████╗██║
    ╚═╝     ╚═╝   ╚═╝    ╚═════╝╚══════╝╚═╝
EOF
    echo -e "${RESET}"
    
    echo -e "${BOLD}${CYAN}MyCLI - Modern Command Line Interface${RESET}"
    echo -e "${DIM}Версия: ${BOLD}$VERSION${RESET}"
    echo ""
    
    # Информация в таблице
    echo -e "${GRAY}┌─────────────────┬────────────────────────────────────┐${RESET}"
    echo -e "${GRAY}│${RESET} ${CYAN}Свойство${RESET}         ${GRAY}│${RESET} ${CYAN}Значение${RESET}                            ${GRAY}│${RESET}"
    echo -e "${GRAY}├─────────────────┼────────────────────────────────────┤${RESET}"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-30s ${GRAY}│${RESET}\n" "Название" "MyCLI"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-30s ${GRAY}│${RESET}\n" "Версия" "$VERSION"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-30s ${GRAY}│${RESET}\n" "Автор" "Your Name"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-30s ${GRAY}│${RESET}\n" "Лицензия" "MIT"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-30s ${GRAY}│${RESET}\n" "Язык" "Bash"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-30s ${GRAY}│${RESET}\n" "Платформы" "Linux, macOS"
    printf "${GRAY}│${RESET} %-15s ${GRAY}│${RESET} %-30s ${GRAY}│${RESET}\n" "Установлено" "$(date '+%Y-%m-%d')"
    echo -e "${GRAY}└─────────────────┴────────────────────────────────────┘${RESET}"
    echo ""
    
    # Статистика использования
    echo -e "${YELLOW}📊 Статистика:${RESET}"
    local cmd_count=$(grep -c "^cmd_" "$0" || echo "0")
    local plugins_count=$(find "$PLUGIN_DIR" -name "*.plugin" 2>/dev/null | wc -l)
    local total_lines=$(wc -l < "$0")
    echo -e "  • Команд: ${BOLD}$cmd_count${RESET}"
    echo -e "  • Плагинов: ${BOLD}$plugins_count${RESET}"
    echo -e "  • Строк кода: ${BOLD}$total_lines${RESET}"
    echo ""
    
    log "Показана информация о CLI"
}

# Команда: config - управление конфигурацией
cmd_config() {
    local action="$1"
    local key="$2"
    local value="$3"
    
    case "$action" in
        set)
            if [[ -z "$key" ]] || [[ -z "$value" ]]; then
                echo -e "${RED}❌ Использование: config set <ключ> <значение>${RESET}"
                return 1
            fi
            echo "$key=$value" >> "$CONFIG_DIR/default.conf"
            echo -e "${GREEN}✅ Установлено: $key = $value${RESET}"
            log "Конфиг установлен: $key=$value"
            ;;
        get)
            if [[ -z "$key" ]]; then
                echo -e "${RED}❌ Использование: config get <ключ>${RESET}"
                return 1
            fi
            local value=$(grep "^$key=" "$CONFIG_DIR/default.conf" 2>/dev/null | cut -d'=' -f2)
            if [[ -n "$value" ]]; then
                echo -e "${CYAN}$key${RESET} = ${GREEN}$value${RESET}"
            else
                echo -e "${YELLOW}⚠️  Ключ '$key' не найден${RESET}"
            fi
            ;;
        list)
            echo -e "${CYAN}${BOLD}📋 Конфигурация:${RESET}"
            echo ""
            if [ -f "$CONFIG_DIR/default.conf" ]; then
                cat "$CONFIG_DIR/default.conf" | while read -r line; do
                    if [[ -n "$line" ]]; then
                        echo -e "  ${GREEN}•${RESET} $line"
                    fi
                done
            else
                echo -e "  ${YELLOW}⚠️  Файл конфигурации не найден${RESET}"
            fi
            echo ""
            ;;
        *)
            echo -e "${RED}❌ Неизвестное действие: $action${RESET}"
            echo -e "${CYAN}Доступные действия: set, get, list${RESET}"
            return 1
            ;;
    esac
}

# Команда: plugin - управление плагинами
cmd_plugin() {
    local action="$1"
    local name="$2"
    
    case "$action" in
        install)
            if [[ -z "$name" ]]; then
                echo -e "${RED}❌ Использование: plugin install <имя>${RESET}"
                return 1
            fi
            echo -e "${CYAN}📦 Установка плагина '$name'...${RESET}"
            # Создаём заглушку плагина
            cat > "$PLUGIN_DIR/${name}.plugin" << EOF
#!/bin/bash
# Плагин: $name
# Установлен: $(date)

plugin_${name}_hello() {
    echo "Привет от плагина $name!"
}

plugin_${name}_info() {
    echo "Плагин $name версии 1.0"
}
EOF
            chmod +x "$PLUGIN_DIR/${name}.plugin"
            echo -e "${GREEN}✅ Плагин '$name' установлен!${RESET}"
            log "Установлен плагин: $name"
            ;;
        remove)
            if [[ -z "$name" ]]; then
                echo -e "${RED}❌ Использование: plugin remove <имя>${RESET}"
                return 1
            fi
            if [ -f "$PLUGIN_DIR/${name}.plugin" ]; then
                rm "$PLUGIN_DIR/${name}.plugin"
                echo -e "${GREEN}✅ Плагин '$name' удалён${RESET}"
                log "Удалён плагин: $name"
            else
                echo -e "${YELLOW}⚠️  Плагин '$name' не найден${RESET}"
            fi
            ;;
        list)
            echo -e "${CYAN}${BOLD}📦 Установленные плагины:${RESET}"
            echo ""
            if [ -d "$PLUGIN_DIR" ]; then
                local plugins=$(find "$PLUGIN_DIR" -name "*.plugin" 2>/dev/null)
                if [[ -n "$plugins" ]]; then
                    echo "$plugins" | while read -r plugin; do
                        local name=$(basename "$plugin" .plugin)
                        echo -e "  ${GREEN}•${RESET} ${BOLD}$name${RESET}"
                    done
                else
                    echo -e "  ${YELLOW}⚠️  Нет установленных плагинов${RESET}"
                fi
            else
                echo -e "  ${YELLOW}⚠️  Директория плагинов не найдена${RESET}"
            fi
            echo ""
            ;;
        enable)
            if [[ -z "$name" ]]; then
                echo -e "${RED}❌ Использование: plugin enable <имя>${RESET}"
                return 1
            fi
            if [ -f "$PLUGIN_DIR/${name}.plugin" ]; then
                source "$PLUGIN_DIR/${name}.plugin"
                echo -e "${GREEN}✅ Плагин '$name' активирован${RESET}"
                log "Активирован плагин: $name"
            else
                echo -e "${YELLOW}⚠️  Плагин '$name' не найден${RESET}"
            fi
            ;;
        *)
            echo -e "${RED}❌ Неизвестное действие: $action${RESET}"
            echo -e "${CYAN}Доступные действия: install, remove, list, enable${RESET}"
            return 1
            ;;
    esac
}

# Команда: help - справка
cmd_help() {
    echo ""
    draw_box "📖 СПРАВКА MYCLI" "$CYAN"
    echo ""
    
    echo -e "${BOLD}${CYAN}Использование:${RESET} ${WHITE}mycli [КОМАНДА] [АРГУМЕНТЫ]${RESET}"
    echo ""
    
    echo -e "${BOLD}${YELLOW}📌 Основные команды:${RESET}"
    echo ""
    
    # Форматированный список команд
    cat << 'EOF'
  ${GREEN}hello${RESET} [--name ИМЯ] [--lang ЯЗЫК] [--emoji СМАЙЛ]
      👋 Поздороваться с пользователем

  ${GREEN}world${RESET}
      🌍 Показать информацию о мире

  ${GREEN}date${RESET} [--format ФОРМАТ] [--timezone ЗОНА]
      📅 Показать дату и время

  ${GREEN}weather${RESET} [ГОРОД]
      🌤️ Показать погоду в городе

  ${GREEN}system${RESET}
      🖥️ Показать информацию о системе

  ${GREEN}info${RESET}
      ℹ️ Показать информацию о CLI

  ${GREEN}config${RESET} [set|get|list] [КЛЮЧ] [ЗНАЧЕНИЕ]
      ⚙️ Управление конфигурацией

  ${GREEN}plugin${RESET} [install|remove|list|enable] [ИМЯ]
      🔌 Управление плагинами

  ${GREEN}version${RESET}
      📌 Показать версию

  ${GREEN}help${RESET}
      📖 Показать эту справку
EOF
    
    echo ""
    echo -e "${BOLD}${CYAN}📚 Примеры:${RESET}"
    echo -e "  ${DIM}$ mycli hello --name Алексей --lang en${RESET}"
    echo -e "  ${DIM}$ mycli weather Лондон${RESET}"
    echo -e "  ${DIM}$ mycli config set theme dark${RESET}"
    echo -e "  ${DIM}$ mycli plugin install awesome${RESET}"
    echo ""
    
    echo -e "${BOLD}${YELLOW}🔧 Полезные алиасы:${RESET}"
    echo -e "  ${DIM}mycli h${RESET}   -> mycli help"
    echo -e "  ${DIM}mycli v${RESET}   -> mycli version"
    echo -e "  ${DIM}mycli w${RESET}   -> mycli weather"
    echo -e "  ${DIM}mycli s${RESET}   -> mycli system"
    echo ""
    
    log "Показана справка"
}

# Команда: version - версия
cmd_version() {
    echo -e "${CYAN}${BOLD}MyCLI v${VERSION}${RESET}"
    echo -e "${DIM}Build: $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo -e "${DIM}Bash: ${BASH_VERSION}${RESET}"
}

# ========== АЛИАСЫ ДЛЯ КОМАНД ==========
# Создаём короткие алиасы для часто используемых команд
alias_commands() {
    # Эти алиасы будут доступны внутри скрипта
    # Для внешнего использования они добавляются в .bashrc при установке
    alias h='cmd_help'
    alias v='cmd_version'
    alias w='cmd_weather'
    alias s='cmd_system'
}

# ========== MAIN ==========
main() {
    # Если нет аргументов, показываем help
    if [ $# -eq 0 ]; then
        cmd_help
        return 0
    fi
    
    # Получаем команду
    local command="$1"
    shift
    
    # Обработка команд
    case "$command" in
        hello|hlo) cmd_hello "$@" ;;
        world|wrl) cmd_world "$@" ;;
        date|dte) cmd_date "$@" ;;
        weather|wth|w) cmd_weather "$@" ;;
        system|sys|s) cmd_system "$@" ;;
        info|inf) cmd_info "$@" ;;
        config|cfg) cmd_config "$@" ;;
        plugin|plg) cmd_plugin "$@" ;;
        help|h|--help|-h) cmd_help "$@" ;;
        version|v|--version|-v) cmd_version "$@" ;;
        *)
            echo -e "${RED}❌ Неизвестная команда: $command${RESET}"
            echo -e "${CYAN}Используйте 'mycli help' для справки${RESET}"
            return 1
            ;;
    esac
}

# ========== ЗАПУСК ==========
# Подключаем плагины
if [ -d "$PLUGIN_DIR" ]; then
    for plugin in "$PLUGIN_DIR"/*.plugin; do
        if [ -f "$plugin" ]; then
            source "$plugin" 2>/dev/null || true
        fi
    done
fi

# Выполняем основную функцию
main "$@"
