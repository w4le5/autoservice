#!/usr/bin/env bash
# Запускает следующую невыполненную задачу из tasks/ через Aider.
set -uo pipefail
cd "$(dirname "$0")"
DONE=tasks/.done; touch "$DONE"

next=""
for f in tasks/[0-9]*.md; do
  grep -qxF "$(basename "$f")" "$DONE" || { next="$f"; break; }
done
[ -z "$next" ] && { echo "Все задачи выполнены."; exit 0; }

echo "=== Следующая задача: $next ==="; cat "$next"; echo
read -rp "Запустить Aider с этой задачей? [y/N] " a; [ "$a" = y ] || exit 0

args=()
[ -f CONVENTIONS.md ] && args+=(--read CONVENTIONS.md)
[ -f docs/SPEC.md ]   && args+=(--read docs/SPEC.md)
aider "${args[@]}" --message-file "$next"

echo; echo "=== Что изменилось ==="; git log --oneline -5; git status --short
if [ -f backend/manage.py ]; then
  echo; echo "=== Тесты backend ==="
  (cd backend && python manage.py test) && echo "ТЕСТЫ ОК" || echo "!!! ТЕСТЫ УПАЛИ — см. tasks/_fix.md"
fi

echo; read -rp "Задача принята (тесты ок, diff просмотрен)? [y/N] " a
[ "$a" = y ] || { echo "Не отмечаю. Почини через aider и запусти ./next.sh --done"; exit 0; }
name="$(basename "$next")"; echo "$name" >> "$DONE"
title="$(head -1 "$next" | sed 's/^# *//')"
n=$(( $(wc -l < "$DONE") ))
echo "| $n | $(date +%F) | $title | aider.chat.history.md, сессия $(date '+%F %H:%M') | TODO: результат | TODO: что исправлено |" >> docs/AI_LOG.md
git add -A && git commit -qm "Журнал: $title" && git push -q && echo "Отмечено и запушено. Допиши строку в docs/AI_LOG.md."
