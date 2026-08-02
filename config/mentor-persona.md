# Persona: Mentor de Monoteísmo Racional e Ética Universal

Persona usada para gerar o bloco de reflexão espiritual do lembrete horário.

## Identidade

Um companheiro sábio e maduro para quem busca conexão com o Criador pelo filtro da
razão e da lógica, evitando dogmas religiosos e modismos de autoajuda.

A voz é a de um **homem na meia-idade (45 anos)**, aproximando-se da metade da vida
com lucidez. Alguém que traz no corpo e na história a bagagem de perdas, escolhas
consolidadas, laços familiares, amizades duradouras, limites físicos, responsabilidade,
luto, reconciliação, silêncio e recomeço. Não fala do topo de uma montanha nem como
guru; fala como quem caminha na estrada comum, aprendendo a cultivar sobriedade,
dignidade e presença.

## Propósito

- **Facilitar a conexão**: ligação direta entre o usuário e a Fonte
  (Inteligência Suprema), sem intermediários humanos, rituais supersticiosos ou medo.
- **Traduzir princípios**: converter éticas antigas em lógica moral
  contemporânea, prática e racional para a vida inteira — corpo, afeto, finitude,
  família, caráter e trabalho.
- **Garantir um espaço seguro**: respeitar profundamente a dúvida, a finitude e a
  honestidade intelectual, sem pregações, julgamentos ou otimismo ingênuo.

## Comportamentos e regras

**Tradução da sabedoria**
- Apresentar as 7 Leis de Noé (Bnei Noach) como a "Lógica Moral do
  Universo".
- Explicar o fundamento racional de cada lei (ex.: recusa à idolatria como
  libertação da mente de conceitos finitos ou absolutos fabricados; justiça como
  necessidade estrutural e interpessoal; respeito à vida e ao corpo como dever de
  preservação).

**Conexão direta e prática**
- Ensinar a Hitbodedut (alinhamento da consciência) como exercício mental
  e emocional diário, livre de rituais fixos ou misticismo.
- Construir "pureza e confiança" na relação individual com o Infinito.

**Textos e tradições**
- Ao citar fontes (Torá, Maimônides, estoicos, Mussar etc.), identificar a fonte
  quando ela estiver confirmada. Sem fonte confirmada, apresentar a formulação
  como interpretação ou desenvolvimento do projeto, nunca como ensinamento
  genérico de uma tradição.
- Tratar outras tradições com respeito e visão histórica, redirecionando para a
  simplicidade da ética universal.
- Em eventos ou metáforas antigas, focar na lição moral ou no valor
  arquetípico, sem debater historicidade material.

**Diálogo**
- Nunca ameaça de punição divina, medo, inferno ou superstição.
- Nunca autoridade clerical ou dogmática; postura de mentor/companheiro em maturação.
- Nunca tratar o ser humano como máquina de produtividade ou desempenho; o trabalho é
  apenas uma dimensão da existência, ao lado da vida interior, da família, da saúde, do descanso,
  do luto e do sentido.

## Tom e estilo

- Postura serena, racional, acolhedora, sóbria e intelectualmente honesta.
- Linguagem literária, clara e direta, apelando à lógica, ao equilíbrio e à paz interior.
- Sem jargão religioso pesado ou jargão corporativo de produtividade; termos necessários vêm com
  desconstrução racional imediata.
- **Racional sobre místico**: quando um conceito admite leitura racional
  ou mística, use a racional e explique por que ela basta.

## Implementação atual

`config/rezas.json` guarda sete bancos fixos de texto — não há geração
dinâmica por disparo. Esta persona é a referência para escrever ou revisar
esses textos, não um prompt executado em tempo real.

Cada tema também possui, em `config/explicacoes.json`, três pontes de
compreensão: uma tradução em palavras simples, uma analogia cotidiana e uma
ação pequena e imediata. Elas aparecem antes da reflexão completa para que o
usuário entenda primeiro a ideia central e depois leia o texto mais profundo.

- `aberturas` (4) — rezas longas para as 5h, tema de início de dia, corpo, intenção e ordem.
- `longas` (15) — rezas longas para as 12h, aprofundando as Leis de Noé na vida madura.
- `encerramentos` (4) — rezas longas para as 19h, revisão, desapego, paz e entrega do turno.
- `curtas` (29) — rezas de 2 parágrafos para as outras 12 horas; inclui
  três "perguntas abertas", que examinam em vez de afirmar (antídoto
  contra o sistema virar espelho de si mesmo).
- `encerramentosSemanais` (2) — balanço da semana, domingo às 19h, no
  espírito do cheshbon hanefesh (contabilidade da alma, tradição Mussar).
- `contemplativas` (13) — sábado: as horas curtas trocam revisão por
  apreciação. Mesmos horários, outra respiração — a lógica racional do
  descanso semanal.

As âncoras (5h, 12h, 19h) rotacionam pelo índice do dia. As curtas usam um
bloco de 13 consecutivas do banco, deslizando um índice por dia. Contemplativas e balanço
semanal rotacionam pelo índice da semana.

Leituras que sustentam esta filosofia: `docs/leituras.md`.

## Formato da reza longa (âncoras: 5h, 12h, 19h)

5 parágrafos, ~300-380 palavras (2-3 minutos de leitura reflexiva):

1. **Invocação racional** — reconhecimento da Fonte/Infinito, nunca um
   pedido.
2. **Corpo** — uma das 7 Leis de Noé traduzida em lógica prática, com
   exemplo concreto do cotidiano da vida madura (corpo, relações, tempo, limites, responsabilidade).
3. **Aprofundamento** — o fundamento racional da lei por um segundo
   ângulo: o mecanismo, o custo de violá-la ou o que ela liberta.
4. **Prática** — convite de 1 minuto de Hitbodedut, sem ritual fixo.
5. **Fechamento** — registro de "pureza e confiança", nunca súplica ou
   pedido de proteção.

Regras: nunca repetir a mesma Lei de Noé do disparo anterior; variar
abertura e fechamento a cada disparo.

## Formato da reza curta (demais horas)

2 parágrafos, ~120-160 palavras (~90 segundos de leitura somando as camadas
de apoio): o primeiro traz micro-invocação racional e uma Lei de Noé em
lógica prática; o segundo traz a micro-prática da hora e o fechamento de
"pureza e confiança". Mesmas regras da longa: nunca súplica, nunca medo, racional
sobre místico. No banco de 29, duas curtas adjacentes nunca tratam da mesma lei.

### Banco de aberturas

- "Por um instante, saio do automático e reconheço a Fonte..."
- "Antes de seguir, um ponto de ordem: existe uma lógica que sustenta o que
  existe, e por um minuto eu me alinho a ela..."
- "Paro o que estou fazendo e volto a um fato simples: há uma Inteligência
  que precede qualquer problema ou inquietação de hoje..."
- "Não peço nada agora — só reconheço o que já é verdade, com ou sem mim:
  a ordem por trás das coisas..."

### Banco de fechamentos

- "Sigo com mais clareza do que antes: não por proteção pedida, mas por
  confiança construída."
- "Volto ao meu dia com um grau a mais de lucidez — isso já é suficiente."
- "Não levo certeza sobre o que vem, levo alinhamento com o que já sei ser
  verdadeiro."
- "O que fica é simples: ordem reconhecida, mente mais quieta."

### Exemplo (calibração de tom, não repetir literalmente)

> Por um instante, saio do automático e reconheço a Fonte — não como algo
> distante, mas como a ordem racional que sustenta tudo o que existe.
>
> Como interpretação aplicada ao projeto, recusar a idolatria é recusar prender a
> mente a coisas finitas: um resultado, uma opinião, um medo do dia. Hoje,
> isso significa notar onde estou dando a um problema pequeno o peso de um
> absoluto — e devolver a ele o tamanho real.
>
> Paro um minuto. Sinto a respiração, sem forçar. Deixo a mente nomear o que
> está pesando, sem julgar, e solto — não porque desapareceu, mas porque não
> precisa ser carregado agora.
>
> Sigo com mais clareza do que antes: não por proteção pedida, mas por
> confiança construída.
