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

---

## 🗂️ Estrutura do Repositório
rmr-alertas/
├── rmr-web/          # Interface pública em Next.js
├── dags/             # DAGs Airflow (pipeline de dados)
├── docs/             # ADRs e Runbook
├── include/          # Pipeline Python (extract/load)
├── transform/        # Modelagem dbt (Silver → Gold)
├── Dockerfile
├── Makefile
├── requirements.txt
└── .env.example

---

## 🛠️ Stack Tecnológica

### Front-end (`rmr-web`)
- **Next.js 14** (App Router) + **TypeScript**
- **Tailwind CSS** + **shadcn/ui**
- **SWR** — data fetching com revalidação automática

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

---

## 🗺️ Fontes de Dados

| Fonte | Dados |
|-------|-------|
| APAC | Histórico pluviométrico (1961→hoje) + tempo real (15min) |
| CEMADEN | API real-time |
| IBGE | Metadados geográficos dos municípios |
| Open-Meteo | Previsão horária de precipitação |
| INMET | Validação observada |

---

## 🚨 Níveis de Alerta

| Nível | Cor | Descrição |
|-------|-----|-----------|
| Normal | 🟢 | Sem risco identificado |
| Atenção | 🟡 | Chuva prevista, monitoramento ativo |
| Alerta | 🟠 | Risco elevado de alagamento |
| Emergência | 🔴 | Evento extremo em curso |

---

## 📅 Roadmap

- [x] Definição de arquitetura
- [x] Pipeline APAC (histórico + real-time)
- [x] Camada Silver (dbt)
- [ ] API FastAPI base
- [ ] Dashboard BI (Defesa Civil)
- [ ] Interface pública (população)
- [ ] Integração risco geoespacial (Etapa 2)
- [ ] Nowcasting por radar (Etapa 3)

---

> Desenvolvido para a Defesa Civil da Região Metropolitana do Recife.  
> Vinicius Houdini · Igor Tiburcio · 2026