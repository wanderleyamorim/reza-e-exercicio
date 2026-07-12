# reza-e-exercicio

Projeto pessoal (privado na prática, hospedado aqui só como registro) para
lembretes de hora em hora, das 5h às 20h, com dois blocos:

1. **Exercício rápido** — alterna entre alongamento, caminhada/levantar,
   respiração/postura, flexão, prancha e agachamento.
2. **Reflexão espiritual** — gerada seguindo a persona definida em
   `config/mentor-persona.md`: um mentor de monoteísmo racional que traduz
   as 7 Leis de Noé e a prática de Hitbodedut em termos lógicos e práticos,
   sem dogma, sem medo, sem intermediários.

## Como funciona

Não há aplicativo rodando 24/7 aqui — o disparo é uma Rotina (trigger
agendado) do Claude Code Remote, configurada com cron `5 5-20 * * *`
(a cada hora, das 5h05 às 20h05). Cada disparo abre uma sessão nova que:

1. Escolhe o próximo exercício do rodízio em `config/exercicios.md`.
2. Gera uma reflexão curta seguindo `config/mentor-persona.md`.
3. Envia uma notificação push para o celular (Claude Code Remote Control).

## Contexto de saúde (para calibrar intensidade)

Usuário: 45 anos, escore de cálcio coronariano 256, sem outras restrições
conhecidas. Os exercícios sugeridos são de baixa/moderada intensidade por
padrão — não substituem orientação médica/cardiológica individual.

## Arquivos

- `config/mentor-persona.md` — a persona/voz usada para gerar as reflexões.
- `config/exercicios.md` — a lista de exercícios em rodízio.
