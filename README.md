# 🌧️ Sistema de Alertas Climáticos — RMR

> Monitoramento e alerta contra eventos climáticos extremos para a **Região Metropolitana do Recife**.  
> Combinando previsão meteorológica, dados geoespaciais e radar em tempo real para proteger 9 municípios.

---

## 📌 Visão Geral

O sistema responde três perguntas em ordem crescente de complexidade:

| Etapa | Pergunta | Status |
|-------|----------|--------|
| 1 | **Vai chover onde?** — Pipeline meteorológico + dashboard base | 🔄 Em desenvolvimento |
| 2 | **Onde vai alagar?** — Risco geoespacial (topografia, marés, rios) | 🔜 Planejado |
| 3 | **Quando e onde exatamente?** — Nowcasting por radar + ML | 🔜 Planejado |

Cobertura: **9 municípios** da RMR em um grid de **48 pontos** com células de 5km².

---

## 🗂️ Estrutura do Repositório

```
rmr-alertas/
├── rmr-api/          # API REST em FastAPI (Python)
├── rmr-web/          # Interface pública em Next.js
└── README.md
```

---

## 🛠️ Stack Tecnológica

### Back-end (`rmr-api`)
- **Python 3.11+** — linguagem base
- **FastAPI** — API REST com documentação automática (Swagger)
- **DuckDB** — warehouse analítico local (dados do pipeline)
- **PostgreSQL** — dados do site (usuários, notificações) — Etapa 2+
- **Uvicorn** — servidor ASGI

### Front-end (`rmr-web`)
- **Next.js 14** (App Router) + **TypeScript**
- **Tailwind CSS** + **shadcn/ui**
- **SWR** — data fetching com revalidação automática

### Pipeline de Dados (responsabilidade do time de dados)
- **Apache Airflow** (Astro CLI) — orquestração
- **DLT** — ingestão das APIs
- **dbt** — transformações Bronze → Prata → Ouro

---

## ⚡ Começando

### Pré-requisitos
- Python 3.11+
- Node.js 18+
- Git

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/rmr-alertas.git
cd rmr-alertas
```

### 2. Configure as variáveis de ambiente

```bash
cp .env.example .env
# Edite o .env com seus tokens
```

### 3. Suba a API

```bash
cd rmr-api
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API disponível em: `http://localhost:8000`  
Documentação automática: `http://localhost:8000/docs`

### 4. Suba o frontend

```bash
cd rmr-web
npm install
npm run dev
```

Site disponível em: `http://localhost:3000`

---

## 🔌 Endpoints Principais

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/v1/alertas` | Nível de alerta por município |
| `GET` | `/api/v1/grid` | Status dos 48 pontos do grid |
| `GET` | `/api/v1/grid/{id}/forecast` | Previsão horária de uma célula |
| `GET` | `/api/v1/radar/latest` | Imagem de radar mais recente |
| `WS` | `/ws/alerts` | Stream de alertas em tempo real |

---

## 🗺️ Fontes de Dados

| Fonte | Dados | Etapa |
|-------|-------|-------|
| Open-Meteo Forecast API | Previsão horária de precipitação | 1 |
| Open-Meteo Historical API | Histórico 2010–hoje (backfill) | 1 |
| INMET Estações Automáticas | Validação observada (Recife, Olinda, Cabo) | 1 |
| MDT / PE 3D | Altimetria 1m de resolução | 2 |
| MapBiomas | Uso do solo (impermeabilidade) | 2 |
| IBGE Setores Censitários | População exposta por célula | 2 |
| DHN / Marinha | Tábua de marés do Porto do Recife | 2 |
| APAC Cotas dos Rios | Níveis do Capibaribe, Beberibe e Tejipió | 2 |
| Radar APAC | Imagens PPI a cada 10 minutos | 3 |
| GOES-16 (NOAA) | Satélite infravermelho + vapor d'água | 3 |

---

## 🚨 Níveis de Alerta

| Nível | Cor | Descrição |
|-------|-----|-----------|
| Normal | 🟢 | Sem risco identificado |
| Atenção | 🟡 | Chuva prevista, monitoramento ativo |
| Alerta | 🟠 | Risco elevado de alagamento |
| Emergência | 🔴 | Evento extremo em curso |

---

## 👥 Time

| Papel | Responsabilidade |
|-------|-----------------|
| Dev Pleno | API FastAPI, arquitetura, integração |
| Dev Júnior | Componentes frontend, documentação |
| Analista de Dados | Pipeline Airflow, DuckDB, dbt |
| Meteorologistas | Validação dos modelos, calibração de thresholds |

---

## 📅 Roadmap

- [x] Definição de arquitetura
- [x] Levantamento técnico
- [ ] Grid de 48 pontos definido
- [ ] API base com dados mockados
- [ ] Dashboard BI (Defesa Civil)
- [ ] Interface pública (população)
- [ ] Pipeline Open-Meteo rodando
- [ ] Integração risco geoespacial (Etapa 2)
- [ ] Nowcasting por radar (Etapa 3)

---

## 📄 Variáveis de Ambiente

Veja o arquivo [`.env.example`](.env.example) para a lista completa.

```env
API_PORT=8000
INMET_TOKEN=
NEXT_PUBLIC_MAPBOX_TOKEN=
POSTGRES_URL=
```

---

> Desenvolvido para a Defesa Civil da Região Metropolitana do Recife.
