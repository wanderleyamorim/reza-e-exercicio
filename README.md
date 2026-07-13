# reza-e-exercicio

Lembrete de hora em hora, das 5h às 20h (horário de Brasília), com um
exercício rápido, uma explicação acessível e uma reza no tom de "Mentor de
Monoteísmo Racional e Ética Universal". Mesma grade nos 7 dias da semana.

## Como funciona

Um **cron da VPS** roda de hora em hora, das 5h às 20h em horário de Brasília,
e manda a mensagem direto para um bot do Telegram.

1. `scripts/send-lembrete.mjs` calcula a hora e o dia atuais em Brasília e
   escolhe o texto em `config/rezas.json`.
2. `scripts/enviar-cron.sh <hora>` valida o conteúdo, carrega o `.env` local e
   chama o envio com a hora pretendida pelo agendamento.
3. O envio usa a API do Telegram (`sendMessage`) com `TELEGRAM_BOT_TOKEN` e
   `TELEGRAM_CHAT_ID` definidos em `/home/vps/projetos/reza-e-exercicio/.env`.

### Formato de cada mensagem

Cada reflexão é apresentada em camadas para facilitar a compreensão:

- **Movimento** — o exercício curto daquele horário.
- **Tema** — o princípio central da reflexão.
- **Em palavras simples** — tradução direta, sem linguagem filosófica.
- **Exemplo do dia a dia** — analogia concreta com situações comuns.
- **Faça agora** — uma ação pequena para aplicar imediatamente.
- **Reflexão** — o texto completo, para aprofundar depois de entender a ideia.

Os 60 temas têm explicações próprias em `config/explicacoes.json`. O wrapper
do cron executa `scripts/validate-content.mjs` antes de cada envio para impedir que um
tema novo seja publicado sem explicação, exemplo ou prática.

### Grade do dia

- **5h — abertura** (reza longa): banco de 4 aberturas, rotacionando por dia.
- **12h — reza completa** (longa): banco de 15 rezas, uma Lei de Noé cada,
  rotacionando por dia.
- **20h — encerramento** (reza longa): banco de 4 encerramentos,
  rotacionando por dia.
- **Demais 13 horas — rezas curtas** (2 parágrafos, ~90s de leitura
  somando as camadas de apoio): banco de 29 (inclui
  três "perguntas abertas"), em bloco consecutivo que desliza um índice
  por dia. Nada se repete no mesmo dia e o conjunto muda de um dia para o
  outro.
- **Exercício**: rodízio de 8, deslocado pelo dia. Às 5h só entram os 4
  leves (ver `config/exercicios.md`).

### Ritmo semanal

- **Sábado**: as horas curtas trocam revisão por contemplação (banco
  `contemplativas`) — mesmos horários, tom de apreciação em vez de
  correção.
- **Domingo, 20h**: em vez do encerramento diário, entra o **balanço da
  semana** (banco `encerramentosSemanais`), no espírito do cheshbon
  hanefesh — revisar a semana inteira e escolher um ajuste para a próxima.

## Configuração necessária

Na VPS, crie o arquivo `.env` na raiz do projeto e preencha:

- `TELEGRAM_BOT_TOKEN` — token do bot (via @BotFather).
- `TELEGRAM_CHAT_ID` — id do chat que vai receber as mensagens.

## Arquivos

- `config/mentor-persona.md` — a persona e os formatos (longo e curto)
  usados para escrever as rezas.
- `config/rezas.json` — bancos de texto: `exercicios`, `aberturas`,
  `longas`, `encerramentos`, `curtas`.
- `config/explicacoes.json` — tradução simples, exemplo cotidiano e ação
  prática de cada tema.
- `config/exercicios.md` — rodízio de exercícios e contexto de saúde.
- `scripts/send-lembrete.mjs` — escolhe e envia a mensagem do horário.
- `scripts/enviar-cron.sh` — carrega `.env`, valida conteúdo e envia com a
  hora pretendida pelo cron.
- `docs/leituras.md` — a linhagem intelectual da filosofia: Maimônides,
  estoicos, Mussar, 7 Leis de Noé, com ordem de leitura sugerida.

## Comportamento de horário

- O envio só é agendado entre **5h e 20h em Brasília**.
- Cada linha do cron passa explicitamente a hora pretendida (`5`, `6`, ...,
  `20`), então um atraso de alguns minutos não troca a mensagem de horário.
- O wrapper tenta enviar até 3 vezes, com intervalo de 5 minutos entre
  tentativas.
- Para teste manual fora da janela, use `DRY_RUN=1` com uma hora simulada.

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
node scripts/validate-content.mjs                  # valida os 60 temas
bash scripts/enviar-cron.sh 12                     # valida, carrega .env e envia 12h
```
