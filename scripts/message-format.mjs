export const TELEGRAM_TEXT_LIMIT = 4096;

export function formatarMensagem({ exercicio, reza, apoio }) {
  return [
    `⏰ MOVIMENTO\n${exercicio}`,
    `🧭 TEMA\n${reza.lei}`,
    `💬 EM PALAVRAS SIMPLES\n${apoio.simples}`,
    `🏠 EXEMPLO DO DIA A DIA\n${apoio.exemplo}`,
    `✅ FAÇA AGORA\n${apoio.acao}`,
    `🙏 REFLEXÃO\n${reza.texto}`,
  ].join("\n\n");
}
