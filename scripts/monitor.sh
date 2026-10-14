#!/usr/bin/env bash

set -uo pipefail

SERVICE="${1:-docker}"
ERRORS=0

echo "========================================"
echo " DevOps monitoring"
echo " Host: $(hostname)"
echo " Service: ${SERVICE}"
echo " Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"

# 1. Проверяем systemd-сервис
echo
echo "[1] Service status"

if systemctl is-active --quiet "$SERVICE"; then
    echo "OK: service '$SERVICE' is active"
else
    echo "ERROR: service '$SERVICE' is not active"
    ERRORS=$((ERRORS + 1))
fi

# 2. Последние 10 записей журнала сервиса
echo
echo "[2] Last 10 service log entries"

journalctl -u "$SERVICE" -n 10 --no-pager \
    --output=short-iso || {
        echo "WARNING: cannot read service journal"
        ERRORS=$((ERRORS + 1))
    }

# 3. Ошибки за последний час
echo
echo "[3] System errors during the last hour"

ERROR_LOGS="$(journalctl --since "1 hour ago" \
    --priority=err \
    --no-pager \
    --output=short-iso 2>&1)"

JOURNAL_EXIT=$?

if [ "$JOURNAL_EXIT" -ne 0 ]; then
    echo "ERROR: cannot read system journal"
    echo "$ERROR_LOGS"
    ERRORS=$((ERRORS + 1))
elif [ -z "$ERROR_LOGS" ] || [ "$ERROR_LOGS" = "-- No entries --" ]; then
    echo "OK: no errors found"
else
    echo "$ERROR_LOGS"
fi

# 4. Итог
echo
echo "========================================"

if [ "$ERRORS" -eq 0 ]; then
    echo "Monitoring completed successfully"
    exit 0
else
    echo "Monitoring detected $ERRORS problem(s)"
    exit 1
fi

