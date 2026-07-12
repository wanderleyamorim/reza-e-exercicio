# reza-e-exercicio

Lembrete de hora em hora, das 5h às 20h (horário de Brasília), com dois
blocos: um exercício rápido e uma reza no tom de "Mentor de Monoteísmo
Racional e Ética Universal".

## Como funciona

Um **GitHub Action agendado** (`.github/workflows/lembrete-horario.yml`)
roda de hora em hora e manda a mensagem direto para um bot do Telegram —
não depende de nenhuma sessão do Claude estar aberta.

1. `scripts/send-lembrete.mjs` calcula a hora atual em Brasília e escolhe
   o item correspondente em `config/rezas.json` (rodízio de 6).
2. Envia a mensagem (exercício + reza) via API do Telegram
   (`sendMessage`), usando os secrets `TELEGRAM_BOT_TOKEN` e
   `TELEGRAM_CHAT_ID` configurados no repositório.

## Configuração necessária

No GitHub: **Settings → Secrets and variables → Actions**, criar:

- `TELEGRAM_BOT_TOKEN` — token do bot (via @BotFather).
- `TELEGRAM_CHAT_ID` — id do chat que vai receber as mensagens.

## Arquivos

- `config/mentor-persona.md` — a persona usada para escrever as rezas.
- `config/rezas.json` — rodízio fixo de 6 (exercício + lei de Noé + reza
  completa), usado pelo script.
- `scripts/send-lembrete.mjs` — envia a mensagem do horário atual.
- `.github/workflows/lembrete-horario.yml` — agenda o disparo.

## Contexto de saúde (para calibrar intensidade dos exercícios)

Usuário: 45 anos, escore de cálcio coronariano 256, sem outras restrições
conhecidas. Exercícios de baixa/moderada intensidade por padrão — não
substituem orientação médica/cardiológica individual.

## Testar manualmente

Com os secrets configurados, rode o workflow pela aba **Actions** do
GitHub (`workflow_dispatch`), ou peça para o Claude disparar via
`actions_run_trigger`.
