# 🏬 Analytics Stack — облачная аналитическая платформа для розничной сети

> Полноценный DWH-стек на базе Docker, развёрнутый на облачной ВМ: от сырых данных о продажах до BI-дашбордов и оркестрации.

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![ClickHouse](https://img.shields.io/badge/ClickHouse-FFCC01?style=for-the-badge&logo=clickhouse&logoColor=black)](https://clickhouse.com/)
[![Airflow](https://img.shields.io/badge/Airflow-017CEE?style=for-the-badge&logo=apacheairflow&logoColor=white)](https://airflow.apache.org/)
[![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![Metabase](https://img.shields.io/badge/Metabase-509EE3?style=for-the-badge&logo=metabase&logoColor=white)](https://www.metabase.com/)

---

## ⚠️ О проекте (честно)

Это учебный / демонстрационный проект на **синтетических данных** розничной сети супермаркетов, развёрнутый на облачной ВМ (Cloud.ru Evolution) для практики инфраструктурных навыков: провижининг ВМ, Docker-оркестрация 10+ сервисов, диагностика и восстановление после нехватки диска. Данные сгенерированы, а не взяты из реального бизнеса.

**Зачем этот проект существует:** показать не только «умею писать SQL и строить дашборды», но и «умею развернуть и поддерживать инфраструктуру для аналитики» — то есть навыки на стыке Data Analyst и Analytics/Data Engineer.

---

## 📊 Бизнес-кейс (синтетический)

Модель данных — розничная сеть супермаркетов: товары, категории, поставщики, филиалы, сотрудники, клиенты, продажи.

- **Объём данных:** ~10 000 заказов, 5 914 клиентов, 30 филиалов, 2 500 товаров
- **Выручка:** 10 601 006 ₽ | Средний чек: 1 133 ₽

Вопросы, на которые отвечает система: динамика продаж по филиалам и категориям, средний чек, топ товаров/поставщиков.

---

## 🏗️ Архитектура

```
PostgreSQL (raw retail data)
        │
        ▼  Apache Airflow (оркестрация)
        │
dbt (staging → marts)  →  ClickHouse (sales_daily, MergeTree)
        │
        ▼
Metabase / Grafana (BI-слой)
```

| Компонент | Роль | Порт |
|---|---|---|
| PostgreSQL | Операционная БД / staging | 5432 |
| ClickHouse | DWH (OLAP) | 8123, 9005 |
| Apache Airflow | Оркестрация | 8080 |
| dbt | Трансформация (staging/marts) | — |
| Metabase | BI, data discovery | 3000 |
| Grafana | Дашборды, мониторинг | 3001 |
| Redis | Кэш / очередь задач | 6379 |
| MinIO | S3-совместимое хранилище | 9105, 9001 |

*(Superset, Redash, NiFi, Kafka, MongoDB, Qdrant, Node-RED — поднимались в рамках экспериментов со стеком; в финальную версию включай только то, что реально показываешь в скриншотах.)*

---

## ▶️ Как запустить локально

```bash
git clone https://github.com/<username>/analytics-stack.git
cd analytics-stack
docker compose up -d
docker compose ps
```

Дашборды: Metabase — `localhost:3000`, Grafana — `localhost:3001`, Airflow — `localhost:8080`.

---

## 🖼️ Скриншоты

*(вставь сюда: Metabase-дашборд с выручкой по филиалам, Grafana-панель, Airflow UI со списком DAG, вывод `docker compose ps`)*

---

## 🧠 Что этот проект показывает работодателю

- Развёртывание и диагностика Docker-инфраструктуры из 10+ сервисов на облачной ВМ (Cloud.ru Evolution)
- Устранение проблемы 98.9% заполненного диска под "боевой" нагрузкой: анализ через `docker system df`, `ctr snapshots`, чистка образов/volume'ов, восстановление сервисов — без потери данных (бэкапы БД)
- Оркестрация ETL через Airflow, трансформация через dbt (staging → marts)
- OLAP-хранилище на ClickHouse для быстрой аналитики

---

## 📬 Автор

Артур Минин — Data Analyst / Analytics Engineer
GitHub: https://github.com/MartinMinart
