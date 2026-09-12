#!/bin/bash
# check_codespace.sh — подробная проверка целостности Codespace с огромным логом

LOG="$HOME/codespace_check.log"
: > "$LOG"   # очистить/создать лог

# ---------- вспомогательные функции ----------
log()  { echo "$1" | tee -a "$LOG"; }
ok()   { echo "  ПРОВЕРКА $1....✅" | tee -a "$LOG"; }
fail() { echo "  ПРОВЕРКА $1....❌" | tee -a "$LOG"; }
warn() { echo "  ПРОВЕРКА $1....⚠️"  | tee -a "$LOG"; }

# проверка команды в PATH
check_cmd() {
    local name="$1"
    if command -v "$name" >/dev/null 2>&1; then
        ok "$name"
    else
        fail "$name"
    fi
}

# проверка файла (существование и исполняемость)
check_file() {
    local path="$1"
    if [ -x "$path" ]; then
        ok "$path"
    elif [ -e "$path" ]; then
        warn "$path (есть, но не исполняется)"
    else
        fail "$path"
    fi
}

# проверка директории
check_dir() {
    local path="$1"
    if [ -d "$path" ]; then
        ok "$path"
    else
        fail "$path"
    fi
}

# ---------- заголовок ----------
log "================================================================"
log "        ПОЛНАЯ ПРОВЕРКА ОКРУЖЕНИЯ CODESPACE"
log "        Дата: $(date)"
log "        Хост: $(hostname 2>/dev/null || echo '?')"
log "        Пользователь: $(whoami 2>/dev/null || echo '?')"
log "        PWD: $(pwd 2>/dev/null || echo '?')"
log "================================================================"
log ""

# ================================================================
log "=== РАЗДЕЛ 1: БАЗОВЫЕ КОМАНДЫ SHELL ==="
log "----------------------------------------------------------------"
for c in bash sh dash zsh ksh csh fish; do check_cmd "$c"; done
log ""

# ================================================================
log "=== РАЗДЕЛ 2: ФАЙЛОВЫЕ УТИЛИТЫ ==="
log "----------------------------------------------------------------"
for c in ls cd pwd cp mv rm rmdir mkdir touch ln cat tac less more head tail \
         find locate which whereis file stat du df tree mount umount; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 3: ТЕКСТОВЫЕ УТИЛИТЫ ==="
log "----------------------------------------------------------------"
for c in echo printf grep egrep fgrep sed awk cut sort uniq wc tr tee \
         diff patch comm join split csplit paste nl od xxd hexdump strings; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 4: АРХИВЫ И СЖАТИЕ ==="
log "----------------------------------------------------------------"
for c in tar gzip gunzip bzip2 bunzip2 xz unxz zip unzip 7z 7za rar unrar \
         zstd lz4 compress uncompress cpio ar; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 5: СИСТЕМНЫЕ УТИЛИТЫ ==="
log "----------------------------------------------------------------"
for c in ps top htop kill killall pkill pgrep nice renice nohup \
         df du free uptime uname hostname whoami id groups \
         chmod chown chgrp umask sudo su env export set unset \
         date sleep timeout watch systemctl service; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 6: СЕТЕВЫЕ УТИЛИТЫ ==="
log "----------------------------------------------------------------"
for c in curl wget ping ping6 traceroute tracepath nslookup dig host \
         ip ifconfig netstat ss route nc netcat telnet ssh scp sftp \
         rsync ftp tftp whois; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 7: БЕЗОПАСНОСТЬ И ХЕШИ ==="
log "----------------------------------------------------------------"
for c in md5sum sha1sum sha224sum sha256sum sha384sum sha512sum \
         b2sum cksum gpg openssl ssh-keygen; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 8: GIT И VCS ==="
log "----------------------------------------------------------------"
for c in git git-lfs gitk git-gui svn hg bzr repo; do check_cmd "$c"; done
log ""

# ================================================================
log "=== РАЗДЕЛ 9: PYTHON ==="
log "----------------------------------------------------------------"
for c in python python2 python3 pip pip2 pip3 pipx poetry virtualenv \
         conda mamba uv pytest ipython jupyter; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 10: NODE.JS И JS-ЭКОСИСТЕМА ==="
log "----------------------------------------------------------------"
for c in node npm npx yarn pnpm bun deno tsc ts-node eslint prettier; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 11: ДРУГИЕ ЯЗЫКИ ==="
log "----------------------------------------------------------------"
for c in ruby gem bundle irb rails go gofmt golangci-lint rustc cargo rustup \
         java javac jar mvn gradle ant kotlin kotlinc scala sbt \
         php composer php8 perl cpan cpanm lua luajit Rscript julia swift \
         dotnet mono csc gcc g++ clang clang++ make cmake ninja; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 12: DOCKER И КОНТЕЙНЕРЫ ==="
log "----------------------------------------------------------------"
for c in docker docker-compose docker-buildx podman buildah skopeo \
         kubectl helm minikube kind k3s k3d terraform ansible; do
    check_cmd "$c"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 13: РЕДАКТОРЫ ==="
log "----------------------------------------------------------------"
for c in nano vim vi emacs pico ed code cursor; do check_cmd "$c"; done
log ""

# ================================================================
log "=== РАЗДЕЛ 14: VS CODE SERVER ==="
log "----------------------------------------------------------------"
check_dir "$HOME/.vscode-remote"
check_dir "$HOME/.vscode-server"
check_dir "/vscode"
check_cmd "code"
check_cmd "code-server"
log ""

# ================================================================
log "=== РАЗДЕЛ 15: КОНФИГИ CODESPACE / DEV CONTAINERS ==="
log "----------------------------------------------------------------"
check_dir "/usr/local/etc/vscode-dev-containers"
check_file "/usr/local/etc/vscode-dev-containers/first-run-notice.txt"
check_file "/usr/local/etc/vscode-dev-containers/conda-notice.txt"
check_file "/usr/local/etc/vscode-dev-containers/go.log"
check_file "/usr/local/etc/vscode-dev-containers/meta.env"
check_dir "/usr/local/etc/vscode-dev-containers/common"
log ""

# ================================================================
log "=== РАЗДЕЛ 16: КРИТИЧНЫЕ БИНАРНИКИ ПО ПУТЯМ ==="
log "----------------------------------------------------------------"
for f in /bin/bash /bin/sh /bin/ls /bin/cat /bin/cp /bin/mv /bin/rm \
         /bin/mkdir /bin/rmdir /bin/chmod /bin/chown /bin/echo \
         /usr/bin/env /usr/bin/sudo /usr/bin/which /usr/bin/command \
         /usr/bin/curl /usr/bin/wget /usr/bin/git \
         /usr/local/bin/git /usr/local/bin/code \
         /usr/local/bin/ruby-build /usr/local/bin/helm \
         /usr/local/bin/kubectl /usr/local/bin/minikube \
         /usr/local/bin/docker-compose /usr/local/bin/composer; do
    check_file "$f"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 17: ДИНАМИЧЕСКИЙ ЛИНКЕР И БИБЛИОТЕКИ ==="
log "----------------------------------------------------------------"
for f in /lib64/ld-linux-x86-64.so.2 \
         /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \
         /lib/x86_64-linux-gnu/libc.so.6 \
         /lib/x86_64-linux-gnu/libm.so.6 \
         /lib/x86_64-linux-gnu/libpthread.so.0 \
         /lib/x86_64-linux-gnu/libdl.so.2 \
         /lib/x86_64-linux-gnu/librt.so.1; do
    check_file "$f"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 18: ДИРЕКТОРИИ СИСТЕМЫ ==="
log "----------------------------------------------------------------"
for d in / /bin /sbin /usr /usr/bin /usr/sbin /usr/local /usr/local/bin \
         /usr/local/share /usr/libexec /usr/lib /etc /home /home/codespace \
         /tmp /var /opt /workspaces; do
    check_dir "$d"
done
log ""

# ================================================================
log "=== РАЗДЕЛ 19: ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ CODESPACE ==="
log "----------------------------------------------------------------"
for v in CODESPACES CODESPACE_NAME GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN \
         CODESPACES_REPO_NAME CODESPACES_BRANCH VSCODE_IPC_HOOK_CLI \
         HOME USER SHELL PATH PWD LANG TERM; do
    val="${!v}"
    if [ -n "$val" ]; then
        ok "$v = $val"
    else
        fail "$v (не задана)"
    fi
done
log ""

# ================================================================
log "=== РАЗДЕЛ 20: ФУНКЦИОНАЛЬНЫЕ ТЕСТЫ ==="
log "----------------------------------------------------------------"

# тест запуска процессов
if /bin/true 2>/dev/null; then ok "запуск /bin/true"; else fail "запуск /bin/true"; fi
if /bin/false 2>/dev/null; then fail "запуск /bin/false (должен вернуть 1)"; else ok "запуск /bin/false"; fi

# тест echo через /bin/echo
if /bin/echo "test" >/dev/null 2>&1; then ok "/bin/echo работает"; else fail "/bin/echo не работает"; fi

# тест записи в /tmp
if touch /tmp/__cs_test__ 2>/dev/null; then ok "запись в /tmp"; rm -f /tmp/__cs_test__; else fail "запись в /tmp"; fi

# тест записи в $HOME
if touch "$HOME/__cs_test__" 2>/dev/null; then ok "запись в \$HOME"; rm -f "$HOME/__cs_test__"; else fail "запись в \$HOME"; fi

# тест записи в рабочую директорию
if touch "./__cs_test__" 2>/dev/null; then ok "запись в PWD"; rm -f "./__cs_test__"; else fail "запись в PWD"; fi

# тест сети (если curl есть)
if command -v curl >/dev/null 2>&1; then
    if curl -s --max-time 5 https://github.com >/dev/null 2>&1; then
        ok "сеть (curl https://github.com)"
    else
        fail "сеть (curl https://github.com)"
    fi
else
    warn "сеть: curl отсутствует, пропуск"
fi

# тест DNS
if command -v nslookup >/dev/null 2>&1; then
    if nslookup github.com >/dev/null 2>&1; then ok "DNS (nslookup)"; else fail "DNS (nslookup)"; fi
elif command -v host >/dev/null 2>&1; then
    if host github.com >/dev/null 2>&1; then ok "DNS (host)"; else fail "DNS (host)"; fi
else
    warn "DNS: нет nslookup/host, пропуск"
fi

log ""

# ================================================================
log "=== РАЗДЕЛ 21: ПРАВА ДОСТУПА ==="
log "----------------------------------------------------------------"
if [ -w "/usr/local" ]; then warn "/usr/local доступен на запись"; else ok "/usr/local защищён"; fi
if [ -w "/usr/bin" ];   then warn "/usr/bin доступен на запись";   else ok "/usr/bin защищён"; fi
if [ -w "/bin" ];       then warn "/bin доступен на запись";       else ok "/bin защищён"; fi
if [ -r "/etc/passwd" ]; then ok "чтение /etc/passwd"; else fail "чтение /etc/passwd"; fi
log ""

# ================================================================
log "=== РАЗДЕЛ 22: ИТОГОВАЯ СТАТИСТИКА ==="
log "----------------------------------------------------------------"

TOTAL_OK=$(grep -c "✅" "$LOG")
TOTAL_FAIL=$(grep -c "❌" "$LOG")
TOTAL_WARN=$(grep -c "⚠️" "$LOG")

log "  Всего проверок:      $((TOTAL_OK + TOTAL_FAIL + TOTAL_WARN))"
log "  Успешно (✅):         $TOTAL_OK"
log "  Провалено (❌):       $TOTAL_FAIL"
log "  Предупреждений (⚠️):  $TOTAL_WARN"
log ""

if [ "$TOTAL_FAIL" -eq 0 ]; then
    log "  ИТОГОВЫЙ СТАТУС: ✅ VALID"
elif [ "$TOTAL_FAIL" -lt 10 ]; then
    log "  ИТОГОВЫЙ СТАТУС: ⚠️ VALID (с ошибками: $TOTAL_FAIL)"
else
    log "  ИТОГОВЫЙ СТАТУС: ❌ INVALID"
fi

log ""
log "================================================================"
log "  Лог сохранён в: $LOG"
log "  Размер лога: $(wc -l < "$LOG") строк"
log "================================================================"

echo ""
echo "Готово! Лог: $LOG"
