#!/usr/bin/env bash

set -e

echo "🗑️ Удаление syscraft..."

PATHS=(
    "/usr/local/bin/syscraft"
    "$HOME/.local/bin/syscraft"
)

REMOVED=0
for TARGET in "${PATHS[@]}"; do
    if [ -f "$TARGET" ]; then
        rm -f "$TARGET"
        echo "✓ Удален: $TARGET"
        REMOVED=1
    fi
done

if [ $REMOVED -eq 1 ]; then
    echo "✅ syscraft успешно удален из системы!"
else
    echo "⚠️  Исполняемый файл syscraft не найден."
fi
