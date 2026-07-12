# reza-e-exercicio

Lembrete de hora em hora, das 5h às 20h (horário de Brasília), com dois
blocos: um exercício rápido e uma reza no tom de "Mentor de Monoteísmo
Racional e Ética Universal". Mesma grade nos 7 dias da semana.

## Como funciona

Um **GitHub Action agendado** (`.github/workflows/lembrete-horario.yml`)
roda de hora em hora e manda a mensagem direto para um bot do Telegram —
não depende de nenhuma sessão do Claude estar aberta.

1. `scripts/send-lembrete.mjs` calcula a hora e o dia atuais em Brasília e
   escolhe o texto em `config/rezas.json`.
2. Envia a mensagem (exercício + reza) via API do Telegram
   (`sendMessage`), usando os secrets `TELEGRAM_BOT_TOKEN` e
   `TELEGRAM_CHAT_ID` configurados no repositório.

### Grade do dia

- **5h — abertura** (reza longa): banco de 4 aberturas, rotacionando por dia.
- **12h — reza completa** (longa): banco de 15 rezas, uma Lei de Noé cada,
  rotacionando por dia.
- **20h — encerramento** (reza longa): banco de 4 encerramentos,
  rotacionando por dia.
- **Demais 13 horas — rezas curtas** (1 parágrafo): banco de 26, em bloco
  consecutivo que desliza um índice por dia. Nada se repete no mesmo dia e
  o conjunto muda de um dia para o outro.
- **Exercício**: rodízio de 8, deslocado pelo dia. Às 5h só entram os 4
  leves (ver `config/exercicios.md`).

### Keepalive

O GitHub desativa workflows agendados após 60 dias sem atividade no
repositório. O modelo `docs/keepalive-workflow.yml` faz um commit pequeno
todo mês (arquivo `.github/keepalive`) para manter o lembrete vivo
indefinidamente.

**Passo manual pendente**: copiar `docs/keepalive-workflow.yml` para
`.github/workflows/keepalive.yml` (o token do Claude não tem permissão
para criar arquivos de workflow — precisa ser feito pela interface do
GitHub ou por um push seu).

## Configuração necessária

No GitHub: **Settings → Secrets and variables → Actions**, criar:

- `TELEGRAM_BOT_TOKEN` — token do bot (via @BotFather).
- `TELEGRAM_CHAT_ID` — id do chat que vai receber as mensagens.

## Arquivos

- `config/mentor-persona.md` — a persona e os formatos (longo e curto)
  usados para escrever as rezas.
- `config/rezas.json` — bancos de texto: `exercicios`, `aberturas`,
  `longas`, `encerramentos`, `curtas`.
- `config/exercicios.md` — rodízio de exercícios e contexto de saúde.
- `scripts/send-lembrete.mjs` — escolhe e envia a mensagem do horário.
- `.github/workflows/lembrete-horario.yml` — agenda o disparo horário.
- `docs/keepalive-workflow.yml` — modelo do commit mensal anti-desativação
  (copiar para `.github/workflows/keepalive.yml`).

## Contexto de saúde (para calibrar intensidade dos exercícios)

Usuário: 45 anos, escore de cálcio coronariano 256, sem outras restrições
conhecidas. Exercícios de baixa/moderada intensidade por padrão — não
substituem orientação médica/cardiológica individual.

## Testar manualmente

Sem enviar nada (imprime a mensagem no terminal):

```sh
DRY_RUN=1 node scripts/send-lembrete.mjs          # hora/dia atuais
DRY_RUN=1 node scripts/send-lembrete.mjs 12       # simula 12h de hoje
DRY_RUN=1 node scripts/send-lembrete.mjs 9 20650  # simula 9h de outro dia
```

Com os secrets configurados, rode o workflow pela aba **Actions** do
GitHub (`workflow_dispatch`), ou peça para o Claude disparar via
`actions_run_trigger`.
