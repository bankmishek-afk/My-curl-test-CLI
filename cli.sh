#!/usr/bin/env bash

# Название и версия
CLI_NAME="syscraft"
VERSION="1.0.0"

# Цветной вывод
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Опциональная проверка утилит (не ломает запуск, а предупреждает)
check_optional_tools() {
    local missing=()
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing+=("$tool")
        fi
    done
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${YELLOW}⚠️ Предупреждение: не найдены утилиты: ${missing[*]}${NC}"
    fi
}

show_help() {
    echo -e "${BLUE}=== ${CLI_NAME} v${VERSION} ===${NC}"
    echo "Использование: syscraft [команда] [опции]"
    echo ""
    echo "Команды:"
    echo "  sysinfo       Показать информацию о системе"
    echo "  greet [имя]   Поприветствовать"
    echo "  ping [host]   Проверить доступность хоста"
    echo "  version       Показать версию"
    echo "  help          Показать эту справку"
}

case "$1" in
    sysinfo)
        echo -e "${GREEN}📊 Информация о системе:${NC}"
        echo "ОС: $(uname -s)"
        echo "Ядро: $(uname -r)"
        echo "Архитектура: $(uname -m)"
        echo "Аптайм: $(uptime -p 2>/dev/null || uptime)"
        ;;
    greet)
        NAME="${2:-Друг}"
        echo -e "${GREEN}👋 Привет, $NAME! Добро пожаловать в syscraft.${NC}"
        ;;
    ping)
        HOST="${2:-google.com}"
        echo -e "${BLUE}📡 Пингуем $HOST...${NC}"
        ping -c 3 "$HOST"
        ;;
    version|-v|--version)
        echo "syscraft version $VERSION"
        ;;
    help|-h|--help|"")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Неизвестная команда: $1${NC}"
        show_help
        exit 1
        ;;
esac
