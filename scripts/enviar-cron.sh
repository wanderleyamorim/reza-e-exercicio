#!/usr/bin/env bash
set -euo pipefail

HORA="${1:-}"
if [[ ! "$HORA" =~ ^([5-9]|1[0-9])$ ]]; then
  echo "Uso: bash scripts/enviar-cron.sh <hora 5-19>" >&2
  exit 2
fi

cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "Arquivo .env não encontrado em $(pwd). Copie .env.example para .env e preencha TELEGRAM_BOT_TOKEN e TELEGRAM_CHAT_ID." >&2
  exit 1
fi

set -a
source .env
set +a

node scripts/validate-content.mjs

tentativas=3
intervalo_segundos=300

for tentativa in $(seq 1 "$tentativas"); do
  if node scripts/send-lembrete.mjs "$HORA"; then
    exit 0
  fi

  if [[ "$tentativa" -lt "$tentativas" ]]; then
    echo "Tentativa ${tentativa}/${tentativas} falhou para ${HORA}h; nova tentativa em ${intervalo_segundos}s." >&2
    sleep "$intervalo_segundos"
  fi
done

echo "Falha definitiva após ${tentativas} tentativas para ${HORA}h." >&2
exit 1
