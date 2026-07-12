import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));

const cfg = JSON.parse(
  readFileSync(join(__dirname, "..", "config", "rezas.json"), "utf-8")
);

// Hora e dia em Brasília (UTC-3; o Brasil não adota mais horário de verão).
// Para testar: node send-lembrete.mjs [hora 0-23] [índice do dia]
const agoraBrasilia = new Date(Date.now() - 3 * 60 * 60 * 1000);
const horaBrasilia =
  process.argv[2] !== undefined
    ? Number(process.argv[2])
    : agoraBrasilia.getUTCHours();
const dia =
  process.argv[3] !== undefined
    ? Number(process.argv[3])
    : Math.floor(agoraBrasilia.getTime() / 86_400_000);

// Janela 5h-20h -> slots 0-15. O clamp absorve atrasos do cron do GitHub:
// um disparo que passe da hora ainda envia a mensagem da janela mais próxima.
const slot = Math.min(Math.max(horaBrasilia - 5, 0), 15);

// Âncoras com reza completa: 5h (abertura), 12h (longa), 20h (encerramento).
// As outras 13 horas recebem rezas curtas: um bloco de 13 consecutivas do
// banco, deslizando um índice por dia — nunca repete no mesmo dia e o
// conjunto muda de um dia para o outro.
//
// Ritmo semanal: no sábado as horas curtas trocam revisão por contemplação
// (banco `contemplativas`); no domingo às 20h entra o balanço da semana
// (banco `encerramentosSemanais`), no espírito do cheshbon hanefesh.
const SLOTS_CURTA = [1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14];
const diaSemana = new Date(dia * 86_400_000).getUTCDay(); // 0=domingo, 6=sábado
const semana = Math.floor(dia / 7);

let reza;
if (slot === 0) {
  reza = cfg.aberturas[dia % cfg.aberturas.length];
} else if (slot === 7) {
  reza = cfg.longas[dia % cfg.longas.length];
} else if (slot === 15) {
  reza =
    diaSemana === 0
      ? cfg.encerramentosSemanais[semana % cfg.encerramentosSemanais.length]
      : cfg.encerramentos[dia % cfg.encerramentos.length];
} else {
  const pos = SLOTS_CURTA.indexOf(slot);
  reza =
    diaSemana === 6
      ? cfg.contemplativas[(semana + pos) % cfg.contemplativas.length]
      : cfg.curtas[(dia + pos) % cfg.curtas.length];
}

// Às 5h só entram os 4 primeiros exercícios (leves): a pressão arterial é
// naturalmente mais alta ao acordar, então o esforço isométrico/resistido
// fica para o restante do dia. Nas demais horas, o rodízio desloca com o
// dia para não fixar o mesmo exercício no mesmo horário.
const EXERCICIOS_LEVES = 4;
const exercicio =
  slot === 0
    ? cfg.exercicios[dia % EXERCICIOS_LEVES]
    : cfg.exercicios[(dia + slot) % cfg.exercicios.length];

const texto = `⏰ ${exercicio}\n\n${reza.texto}`;

if (process.env.DRY_RUN === "1") {
  console.log(`[dry-run] slot ${slot} (${horaBrasilia}h), dia ${dia}, ${reza.lei}`);
  console.log(texto);
  process.exit(0);
}

const token = process.env.TELEGRAM_BOT_TOKEN;
const chatId = process.env.TELEGRAM_CHAT_ID;

if (!token || !chatId) {
  console.error("Faltam TELEGRAM_BOT_TOKEN e/ou TELEGRAM_CHAT_ID no ambiente.");
  process.exit(1);
}

const url = `https://api.telegram.org/bot${token}/sendMessage`;
const resp = await fetch(url, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ chat_id: chatId, text: texto }),
});

const data = await resp.json();
if (!resp.ok || !data.ok) {
  console.error("Falha ao enviar para o Telegram:", JSON.stringify(data));
  process.exit(1);
}

console.log(`Enviado (slot ${slot}, ${reza.lei}).`);
