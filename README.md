# 🌧️ Sistema de Alertas Climáticos — RMR

> Monitoramento e alerta contra eventos climáticos extremos para a **Região Metropolitana do Recife**.  
> Combinando previsão meteorológica, dados geoespaciais e radar em tempo real para proteger 9 municípios.

---

## 📌 Visão Geral

O sistema responde três perguntas em ordem crescente de complexidade:

| Etapa | Pergunta | Status |
|-------|----------|--------|
| 1 | **Vai chover onde?** — Pipeline meteorológico + dashboard base | ✅ Concluída |
| 2 | **Onde vai alagar?** — Risco geoespacial (topografia, marés, rios) | 🔄 Em desenvolvimento |
| 3 | **Quando e onde exatamente?** — Nowcasting por radar + ML | 🔜 Planejado |

---

## 🗂️ Estrutura do Repositório

```
rmr-alertas/
├── rmr-web/              # Interface pública em Next.js
├── rmr-api/              # API REST em FastAPI (em desenvolvimento)
├── dags/                 # DAGs Airflow (pipeline de dados)
├── docs/                 # ADRs, Runbook e documentação técnica
├── include/              # Pipeline Python (extract/load)
├── transform/            # Modelagem dbt (Bronze → Silver → Gold)
├── .github/workflows/    # CI/CD
├── Dockerfile
├── Makefile
├── pyproject.toml
├── requirements.txt
├── .env.example
└── .gitignore
```

---

## 🛠️ Stack Tecnológica

### Front-end (`rmr-web`)
- **Next.js 14** (App Router) + **TypeScript**
- **Tailwind CSS** + **shadcn/ui**
- **SWR** — data fetching com revalidação automática

### Back-end (`rmr-api`) — em desenvolvimento
- **Python 3.11+** + **FastAPI**
- **DuckDB** — leitura das tabelas Ouro do pipeline
- **Uvicorn** — servidor ASGI

### Pipeline de Dados
- **Apache Airflow** (Astro CLI) — orquestração
- **DuckDB** — warehouse analítico local
- **dbt** — transformações Bronze → Silver → Gold
- **Selenium** — scraping histórico (APAC)

---

## ⚡ Começando

### Pré-requisitos
- Python 3.11+
- Node.js 18+
- [Astro CLI](https://www.astronomer.io/docs/astro/cli/install-cli)
- Docker
- Google Chrome (para o Selenium)

### 1. Clone o repositório

```bash
git clone https://github.com/vinihoudini/rmr-alertas.git
cd rmr-alertas
```

### 2. Configure as variáveis de ambiente

```bash
cp .env.example .env
# Edite o .env com seus tokens
```

### 3. Suba o frontend

```bash
cd rmr-web
npm install
npm run dev
# http://localhost:3000
```

### 4. Suba o Airflow

```bash
astro dev start
# http://localhost:8080 — admin/admin
```

### 5. Suba a API (em desenvolvimento)

```bash
cd rmr-api
python -m venv venv
venv\Scripts\activate      # Windows
# source venv/bin/activate # Linux/Mac
pip install -r requirements.txt
uvicorn app.main:app --reload
# http://localhost:8000
# Docs: http://localhost:8000/docs
```

---

## 🗺️ Fontes de Dados

| Fonte | Dados | Etapa |
|-------|-------|-------|
| APAC | Histórico pluviométrico (1961→hoje) + tempo real (15min) | 1 |
| CEMADEN | Dados de monitoramento em tempo real | 1 |
| Open-Meteo Forecast API | Previsão horária de precipitação (7 dias) | 1 |
| Open-Meteo Historical API | Histórico 2010–hoje (backfill) | 1 |
| INMET Estações Automáticas | Validação observada (Recife, Olinda, Cabo) | 1 |
| MDT / PE 3D | Altimetria 1m de resolução | 2 |
| MapBiomas | Uso do solo (impermeabilidade por célula) | 2 |
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
| Vinicius Houdini | Dev Pleno — API FastAPI, arquitetura, integração |
| Igor Tiburcio | Analista de Dados — Pipeline Airflow, DuckDB, dbt, modelos |

---

## 📅 Roadmap

### ✅ Etapa 1 — Pipeline Meteorológico + Interface Base
- [x] Definição de arquitetura
- [x] Pipeline APAC (histórico + real-time a cada 15min)
- [x] Pipeline CEMADEN
- [x] Camada Silver (dbt)
- [x] Interface pública Next.js (níveis de alerta por município)

### 🔄 Etapa 2 — Risco Geoespacial (em andamento)
- [ ] API FastAPI base com endpoints de grid e alertas
- [ ] Ingestão MDT/PE3D, MapBiomas, IBGE, DHN, APAC Rios
- [ ] Joins geoespaciais na camada Silver (DuckDB spatial)
- [ ] Índice de risco composto por célula (camada Gold)
- [ ] Dashboard BI (Metabase ou Superset) para Defesa Civil
- [ ] Interface pública: índice de risco + população exposta

### 🔜 Etapa 3 — Nowcasting + Machine Learning
- [ ] Scraper do radar meteorológico APAC (10min)
- [ ] Georreferenciamento das imagens PPI
- [ ] Optical flow para projeção de células de chuva (t+30min)
- [ ] Integração GOES-16 via S3 público
- [ ] Modelo XGBoost de probabilidade de alerta
- [ ] WebSocket para atualizações em tempo real no frontend
- [ ] Player de radar animado na interface
- [ ] PWA com notificações push

---

## 📄 Variáveis de Ambiente

Veja o arquivo [`.env.example`](.env.example) para a lista completa.

```env
# Pipeline
INMET_TOKEN=
CEMADEN_TOKEN=

# API
API_PORT=8000

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8000

# BI (Etapa 2)
METABASE_SECRET_KEY=

# Mapbox (Etapa 3)
NEXT_PUBLIC_MAPBOX_TOKEN=

# PostgreSQL (Etapa 2+)
POSTGRES_URL=
```

---

> Desenvolvido para a Defesa Civil da Região Metropolitana do Recife.  
> Vinicius Houdini · Igor Tiburcio · 2026
