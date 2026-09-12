#!/bin/bash
# check_codespace.sh — проверка целостности окружения GitHub Codespaces

INVALID=0
WARNINGS=0

echo "=========================================="
echo "  Проверка статуса Codespace"
echo "  Дата: $(date)"
echo "=========================================="
echo ""

# --- 1. Проверка базовых утилит в /bin и /usr/bin ---
echo "[1] Проверка базовых утилит..."
BASIC_UTILS=(bash sh ls cp mv rm cat echo grep sed awk find chmod chown mkdir rmdir touch tar gzip)
for util in "${BASIC_UTILS[@]}"; do
    if ! command -v "$util" >/dev/null 2>&1; then
        echo "  ❌ ОТСУТСТВУЕТ: $util"
        INVALID=1
    fi
done
[ $INVALID -eq 0 ] && echo "  ✅ Базовые утилиты на месте"

# --- 2. Проверка критичных системных бинарников ---
echo ""
echo "[2] Проверка критичных системных бинарников..."
CRITICAL=(/bin/bash /bin/sh /bin/ls /bin/cat /bin/cp /bin/mv /bin/rm /bin/mkdir /bin/chmod /usr/bin/env /usr/bin/sudo)
for bin in "${CRITICAL[@]}"; do
    if [ ! -x "$bin" ]; then
        echo "  ❌ ОТСУТСТВУЕТ или не исполняется: $bin"
        INVALID=1
    fi
done
[ $INVALID -eq 0 ] && echo "  ✅ Критичные бинарники на месте"

# --- 3. Проверка динамического линкера (ld-linux) ---
echo ""
echo "[3] Проверка динамического линкера..."
if [ ! -f /lib64/ld-linux-x86-64.so.2 ] && [ ! -f /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 ]; then
    echo "  ❌ КРИТИЧНО: динамический линкер отсутствует!"
    INVALID=1
else
    echo "  ✅ Динамический линкер на месте"
fi

# --- 4. Проверка окружения Codespaces ---
echo ""
echo "[4] Проверка окружения Codespaces..."
if [ -d "/vscode" ] || [ -d "/home/codespace" ] || [ -n "$CODESPACES" ]; then
    echo "  ✅ Признаки Codespace обнаружены"
else
    echo "  ⚠️  Признаки Codespace не обнаружены (возможно, вы не в Codespace)"
    WARNINGS=$((WARNINGS+1))
fi

# --- 5. Проверка VS Code Server ---
echo ""
echo "[5] Проверка VS Code Server..."
if [ -d "$HOME/.vscode-remote" ] || [ -d "/vscode" ]; then
    echo "  ✅ VS Code Server присутствует"
else
    echo "  ⚠️  VS Code Server не найден"
    WARNINGS=$((WARNINGS+1))
fi

# --- 6. Проверка конфигов dev-containers ---
echo ""
echo "[6] Проверка конфигов vscode-dev-containers..."
if [ -d "/usr/local/etc/vscode-dev-containers" ]; then
    echo "  ✅ Конфиги на месте"
else
    echo "  ❌ Конфиги /usr/local/etc/vscode-dev-containers ОТСУТСТВУЮТ"
    INVALID=1
fi

# --- 7. Проверка прав и владельца /usr/local ---
echo ""
echo "[7] Проверка прав /usr/local..."
if [ -w "/usr/local" ]; then
    echo "  ⚠️  /usr/local доступен на запись обычному пользователю (подозрительно)"
    WARNINGS=$((WARNINGS+1))
else
    echo "  ✅ Права на /usr/local корректные"
fi

# --- 8. Проверка Git ---
echo ""
echo "[8] Проверка Git..."
if command -v git >/dev/null 2>&1; then
    echo "  ✅ git установлен: $(git --version)"
else
    echo "  ❌ git ОТСУТСТВУЕТ"
    INVALID=1
fi

# --- 9. Проверка Python ---
echo ""
echo "[9] Проверка Python..."
if command -v python3 >/dev/null 2>&1; then
    echo "  ✅ python3 установлен: $(python3 --version)"
else
    echo "  ⚠️  python3 не найден"
    WARNINGS=$((WARNINGS+1))
fi

# --- 10. Проверка сетевых утилит ---
echo ""
echo "[10] Проверка сетевых утилит..."
for util in curl wget ping; do
    if ! command -v "$util" >/dev/null 2>&1; then
        echo "  ⚠️  отсутствует: $util"
        WARNINGS=$((WARNINGS+1))
    fi
done
[ $WARNINGS -eq 0 ] && echo "  ✅ Сетевые утилиты на месте"

# --- 11. Проверка критичных библиотек ---
echo ""
echo "[11] Проверка критичных библиотек..."
LIBS=(/lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libpthread.so.0)
for lib in "${LIBS[@]}"; do
    if [ ! -f "$lib" ]; then
        echo "  ❌ ОТСУТСТВУЕТ: $lib"
        INVALID=1
    fi
done
[ $INVALID -eq 0 ] && echo "  ✅ Критичные библиотеки на месте"

# --- 12. Проверка возможности запуска процессов ---
echo ""
echo "[12] Проверка запуска процессов..."
if /bin/true 2>/dev/null; then
    echo "  ✅ Процессы запускаются"
else
    echo "  ❌ НЕ удаётся запустить /bin/true"
    INVALID=1
fi

# --- ИТОГ ---
echo ""
echo "=========================================="
if [ $INVALID -eq 1 ]; then
    echo "  СТАТУС: ❌ INVALID"
    echo "  Система повреждена. Требуется пересоздание Codespace."
elif [ $WARNINGS -gt 0 ]; then
    echo "  СТАТУС: ⚠️  VALID (с предупреждениями: $WARNINGS)"
    echo "  Основные компоненты на месте, но есть замечания."
else
    echo "  СТАТУС: ✅ VALID"
    echo "  Система в порядке."
fi
echo "=========================================="

exit $INVALID
