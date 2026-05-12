# Conversor DBC para DBF

Mini sistema em Python para converter arquivos `.dbc` compactados do DATASUS para `.dbf`.

## Como instalar

1. Abra esta pasta no Windows.
2. Execute `instalar.bat`.

## Como usar com interface

Execute `abrir_conversor.bat`, selecione o arquivo `.dbc` e clique em `Converter agora`.

Tambem e possivel selecionar `Pasta inteira` para transformar todos os `.dbc` de uma pasta.

Se preferir abrir sem janela de terminal, execute `Conversor_DBC_DBF.pyw`.

## Como usar pelo terminal

Converter um arquivo:

```powershell
py -3 converter.py caminho\arquivo.dbc caminho\arquivo.dbf
```

Converter uma pasta:

```powershell
py -3 converter.py caminho\pasta caminho\saida --pasta
```

## Observacao

O conversor usa a biblioteca `dbc-to-dbf`, que implementa a descompactacao BLAST/PKWare usada nos arquivos `.dbc` do DATASUS.

## Versao web

A versao web usa FastAPI no backend e React com TypeScript no frontend.
Ela possui duas funcoes:

- conversao manual de um arquivo `.dbc` anexado pelo usuario;
- automacao DATASUS PAPA, que lista os `PAPA26*.dbc` disponiveis no FTP, permite escolher os meses, converte, filtra Belem e disponibiliza os CSVs para download.

Instalar dependencias:

```powershell
instalar_web.bat
```

Rodar o backend em um terminal:

```powershell
iniciar_backend.bat
```

Rodar o frontend em outro terminal:

```powershell
iniciar_frontend.bat
```

Depois acesse:

```text
http://127.0.0.1:5173
```

## Automacao DATASUS PAPA 2026

O script `automacao_papa_datasus.py` baixa os arquivos `PAPA26*.dbc`
selecionados no FTP do DATASUS, converte DBC para DBF, filtra Belem pelo
codigo `150140` e gera CSVs locais para download pela versao web.

Tambem e possivel executar a automacao fora da web:

```powershell
executar_automacao_papa.bat
```

As configuracoes de FTP, destino, municipio, colunas e tamanho de lote ficam no
topo do arquivo `automacao_papa_datasus.py`.

Na versao web, o usuario escolhe onde salvar o CSV no momento do download pelo
navegador.

## Deploy

A opcao recomendada para producao e Render com Docker, porque o backend precisa
baixar e converter arquivos grandes antes de entregar os CSVs.

Arquivos de deploy:

- `Dockerfile`: builda o frontend React e executa o FastAPI com Uvicorn.
- `render.yaml`: blueprint para criar o Web Service no Render.
- `.dockerignore`: evita enviar bases DATASUS, CSVs, caches e `node_modules` para a imagem.
- `.env.example`: lista as variaveis de ambiente usadas pelo app.

Variaveis principais:

```text
FTP_HOST=ftp.datasus.gov.br
FTP_DIR=/dissemin/publicos/SIASUS/200801_/Dados
PAPA_WORK_DIR=/tmp/datasus-papa/work
PAPA_OUTPUT_DIR=/tmp/datasus-papa/output
MAX_MONTHS_PER_JOB=3
MAX_UPLOAD_MB=512
MAX_DOWNLOAD_AGE_HOURS=24
```

No Render, crie um novo Blueprint apontando para este repositorio ou crie um
Web Service com ambiente Docker. O health check deve usar `/api/health`.
