#!/usr/bin/env bash

set -e

REPO_USER="bankmishek-afk"
REPO_NAME="My-curl-test-CLI"
BRANCH="main"

RAW_BASE_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/refs/heads/${BRANCH}"

echo "🚀 Установка CLI-инструмента..."

# Проверяем базовый curl
if ! command -v curl >/dev/null 2>&1; then
    echo "❌ Ошибка: curl не установлен в системе."
    exit 1
fi

# Выбираем папку для установки
if [ "$(id -u)" -eq 0 ]; then
    INSTALL_DIR="/usr/local/bin"
elif [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

echo "📦 Скачиваем cli.sh в $INSTALL_DIR/syscraft..."

# Скачивание файла
curl -sSL "${RAW_BASE_URL}/cli.sh" -o "${INSTALL_DIR}/syscraft"
chmod +x "${INSTALL_DIR}/syscraft"

echo "✅ Установка успешно завершена!"

# Проверка PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "⚠️  Замечание: $INSTALL_DIR не находится в вашем PATH."
    echo "👉 Добавьте путь командой: export PATH=\"\$PATH:$INSTALL_DIR\""
fi

echo ""
echo "🎉 Готово! Проверьте запуск: syscraft help"
