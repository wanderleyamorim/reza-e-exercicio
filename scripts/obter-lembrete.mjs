import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const TIME_ZONE = "America/Sao_Paulo";
const DAY_MS = 86_400_000;

const cfg = JSON.parse(
  readFileSync(join(__dirname, "..", "config", "rezas.json"), "utf-8")
);
const explicacoes = JSON.parse(
  readFileSync(join(__dirname, "..", "config", "explicacoes.json"), "utf-8")
);

export function getBrasiliaParts(date = new Date()) {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone: TIME_ZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    weekday: "short",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  });

  const parts = Object.fromEntries(
    formatter
      .formatToParts(date)
      .filter((part) => part.type !== "literal")
      .map((part) => [part.type, part.value])
  );

  return {
    year: Number(parts.year),
    month: Number(parts.month),
    dayOfMonth: Number(parts.day),
    hour: Number(parts.hour),
  };
}

export function obterLembrete(horaForcada, diaForcado) {
  const agoraBrasilia = getBrasiliaParts();
  const horaBrasilia =
    horaForcada !== undefined && horaForcada !== ""
      ? Number(horaForcada)
      : agoraBrasilia.hour;
  const dia =
    diaForcado !== undefined && diaForcado !== ""
      ? Number(diaForcado)
      : Math.floor(
          Date.UTC(
            agoraBrasilia.year,
            agoraBrasilia.month - 1,
            agoraBrasilia.dayOfMonth
          ) / DAY_MS
        );
  const slot = horaBrasilia - 5;

  if (horaBrasilia < 5 || horaBrasilia > 19) {
    return {
      dentroDaJanela: false,
      hora: horaBrasilia,
      dia,
      mensagem: `Fora da janela de lembretes (5h às 19h): ${horaBrasilia}h`,
    };
  }

  const SLOTS_CURTA = [1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13];
  const diaSemana = new Date(dia * DAY_MS).getUTCDay();
  const semana = Math.floor(dia / 7);
  const slotEfetivo = horaBrasilia === 19 ? 15 : slot;

  let reza;
  let tipoReza = "curta";
  if (slotEfetivo === 0) {
    reza = cfg.aberturas[dia % cfg.aberturas.length];
    tipoReza = "abertura";
  } else if (slotEfetivo === 7) {
    reza = cfg.longas[dia % cfg.longas.length];
    tipoReza = "longa";
  } else if (slotEfetivo === 15) {
    reza =
      diaSemana === 0
        ? cfg.encerramentosSemanais[semana % cfg.encerramentosSemanais.length]
        : cfg.encerramentos[dia % cfg.encerramentos.length];
    tipoReza = "encerramento";
  } else {
    const pos = SLOTS_CURTA.indexOf(slotEfetivo);
    reza =
      diaSemana === 6
        ? cfg.contemplativas[(semana + pos) % cfg.contemplativas.length]
        : cfg.curtas[(dia + pos) % cfg.curtas.length];
  }

  const EXERCICIOS_LEVES = 4;
  const exercicio =
    slotEfetivo === 0
      ? cfg.exercicios[dia % EXERCICIOS_LEVES]
      : cfg.exercicios[(dia + slotEfetivo) % cfg.exercicios.length];

  const apoio = explicacoes[reza.lei] || {
    simples: "",
    exemplo: "",
    acao: "",
  };

  return {
    dentroDaJanela: true,
    hora: horaBrasilia,
    slot: slotEfetivo,
    dia,
    tipoReza,
    exercicio,
    tema: reza.lei,
    simples: apoio.simples,
    exemplo: apoio.exemplo,
    acao: apoio.acao,
    reflexao: reza.texto,
  };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const isBase64 = process.argv.includes("--base64");
  const filteredArgs = process.argv.slice(2).filter((arg) => arg !== "--base64");
  const hora = filteredArgs[0];
  const dia = filteredArgs[1];
  const resultado = obterLembrete(hora, dia);
  const jsonStr = JSON.stringify(resultado, null, 2);
  if (isBase64) {
    console.log(Buffer.from(jsonStr, "utf-8").toString("base64"));
  } else {
    console.log(jsonStr);
  }
}