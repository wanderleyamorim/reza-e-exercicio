import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));

const token = process.env.TELEGRAM_BOT_TOKEN;
const chatId = process.env.TELEGRAM_CHAT_ID;

if (!token || !chatId) {
  console.error("Faltam TELEGRAM_BOT_TOKEN e/ou TELEGRAM_CHAT_ID no ambiente.");
  process.exit(1);
}

const { exercicios, rezas } = JSON.parse(
  readFileSync(join(__dirname, "..", "config", "rezas.json"), "utf-8")
);

// O workflow só roda entre 8h e 23h UTC (5h-20h em horário de Brasília, UTC-3).
// Slot 0 = 5h, slot 15 = 20h — 16 slots, um por horário, sem repetir reza no mesmo dia.
const horaBrasilia = (new Date().getUTCHours() - 3 + 24) % 24;
const slot = Math.min(Math.max(horaBrasilia - 5, 0), rezas.length - 1);

const exercicio = exercicios[slot % exercicios.length];
const reza = rezas[slot];

const texto = `⏰ ${exercicio}\n\n${reza.texto}`;

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

console.log(`Enviado (slot ${slot}, lei: ${reza.lei}).`);
