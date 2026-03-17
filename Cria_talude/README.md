⛰️ Criador Automático de Talude (AutoLISP)

⚙️ Como funciona?
Em vez de utilizar o método tradicional que sobrecarrega o sistema chamando o comando LINE repetidas vezes, este script atua de forma muito mais inteligente:

Matemática Avançada: Utiliza as funções vlax-curve para calcular as perpendiculares com extrema precisão.

Acesso Direto: Usa a função entmake para injetar as linhas transversais do talude (alternando entre linha inteira e meia linha) diretamente no banco de dados do CAD, contornando a interface gráfica.

✨ Principais Vantagens
⚡ Velocidade Instantânea: Geração imediata das linhas, mesmo em taludes com quilômetros de extensão.

🛡️ Zero Travamentos: Otimização máxima de memória para evitar que o AutoCAD congele.

↩️ Undo Agrupado: Todo o processamento fica agrupado. Se não gostar do resultado, basta um único Ctrl+Z (Desfazer) para limpar todo o talude gerado de uma só vez.


🛠️ Como Utilizar
Faça o download do arquivo .lsp neste repositório.

Abra o AutoCAD e digite o comando APPLOAD.

Selecione e carregue o arquivo baixado.

Digite o comando TALUDE para iniciar a rotina e pressione Enter.
