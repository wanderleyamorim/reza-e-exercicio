import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import {
  formatarMensagem,
  TELEGRAM_TEXT_LIMIT,
} from "./message-format.mjs";

const __dirname = dirname(fileURLToPath(import.meta.url));

function readJson(file) {
  return JSON.parse(readFileSync(join(__dirname, "..", "config", file), "utf-8"));
}

const rezas = readJson("rezas.json");
const explicacoes = readJson("explicacoes.json");
const temas = new Set();
const reflexoes = [];

for (const banco of Object.values(rezas)) {
  if (!Array.isArray(banco)) continue;
  for (const item of banco) {
    if (item && typeof item === "object" && "lei" in item) {
      temas.add(item.lei);
      reflexoes.push(item);
    }
  }
}

const erros = [];
for (const tema of temas) {
  const apoio = explicacoes[tema];
  if (!apoio) {
    erros.push(`Tema sem explicação: ${tema}`);
    continue;
  }

  for (const campo of ["simples", "exemplo", "acao"]) {
    if (typeof apoio[campo] !== "string" || apoio[campo].trim().length < 10) {
      erros.push(`Campo '${campo}' ausente ou muito curto: ${tema}`);
    }
  }
}

for (const tema of Object.keys(explicacoes)) {
  if (!temas.has(tema)) erros.push(`Explicação sem tema correspondente: ${tema}`);
}

const maiorExercicio = rezas.exercicios.reduce((maior, atual) =>
  atual.length > maior.length ? atual : maior
);
let maiorMensagem = { tamanho: 0, tema: "" };

for (const reza of reflexoes) {
  const apoio = explicacoes[reza.lei];
  if (!apoio) continue;

  const tamanho = formatarMensagem({
    exercicio: maiorExercicio,
    reza,
    apoio,
  }).length;

  if (tamanho > maiorMensagem.tamanho) {
    maiorMensagem = { tamanho, tema: reza.lei };
  }
  if (tamanho > TELEGRAM_TEXT_LIMIT) {
    erros.push(
      `Mensagem excede ${TELEGRAM_TEXT_LIMIT} caracteres: ${reza.lei} (${tamanho})`
    );
  }
}

if (erros.length > 0) {
  console.error(erros.join("\n"));
  process.exit(1);
}

console.log(`${temas.size} temas com explicação simples, exemplo e ação prática.`);
console.log(
  `Maior mensagem: ${maiorMensagem.tamanho}/${TELEGRAM_TEXT_LIMIT} caracteres (${maiorMensagem.tema}).`
);
