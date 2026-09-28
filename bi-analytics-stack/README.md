# BI Analytics Stack

Локальный BI-стек на Docker Compose: PostgreSQL + ClickHouse + Airflow + dbt + Grafana.

## 🏗️ Архитектура

```
PostgreSQL (10 000 sales)
    │
    ▼
Airflow DAG (etl_to_clickhouse)
    │ 4 задачи
    ▼
ClickHouse (sales_daily, 30 000 строк)
    │
    ▼
Grafana (dashboard: revenue, orders, AOV)
```

## 📦 Компоненты

| Сервис | Порт | Назначение |
|--------|------|-----------|
| PostgreSQL | 5432 | Основное OLTP-хранилище |
| ClickHouse | 8123 / 9005 | OLAP для аналитики |
| Airflow | 8080 | Оркестрация ETL |
| Metabase | 3000 | BI-дашборды |
| Superset | 8088 | BI-дашборды (альтернатива) |
| Grafana | 3001 | Мониторинг и визуализация |
| Redis | 6379 | Кэш |
| MinIO | 9001 / 9105 | S3-совместимое хранилище |
| Kafka | 9092 | Стриминг (не использован) |
| Qdrant | 6333 / 6334 | Vector DB (не использована) |
| MongoDB | 27017 | NoSQL (не использована) |
| NiFi | 8443 | Data flow (не использован) |
| Node-RED | 1880 | Визуальное программирование |
| Redash | 5000 | BI (не использован) |

## 🗄️ Базы данных PostgreSQL

| База | Назначение |
|------|-----------|
| analytics_db | Retail-данные (основная) |
| analytics_db_new | Retail-данные v2 |
| medical_analytics | Медицинские данные (5000 записей) |
| airflow_db | Метаданные Airflow |
| metabase_db | Метаданные Metabase |

## 🔄 Airflow DAG: `etl_to_clickhouse`

4 задачи:
1. `extract_from_postgres` — забор из `sales`
2. `transform_sales_daily` — агрегация по дням/категориям/филиалам
3. `load_to_clickhouse` — загрузка в `sales_daily`
4. `verify_count` — проверка количества

**Результат:** 3 успешных запуска, 30 000 строк в ClickHouse.

## 🔧 dbt

```
models/
├── staging/
│   └── stg_sales.sql       # очистка и нормализация sales
└── marts/                  # (в разработке)
    ├── mart_sales_daily.sql
    ├── mart_product_performance.sql
    ├── mart_branch_performance.sql
    └── mart_customer_insights.sql
```

**Спроектировано, часть моделей реализована и запущена.**
Lineage-граф: `dbt docs generate`.

## 📊 Grafana Dashboard

**Analytics Platform Overview:**
- Total orders: 13
- Total revenue: 12 638
- Диаграмма по датам
- Диаграмма по категориям

## 🚀 Запуск

```bash
# 1. Скопировать .env.example → .env
cp configs/.env.example .env

# 2. Заполнить пароли

# 3. Поднять стек
docker compose up -d

# 4. Инициализировать БД
docker exec -i analytics-postgres psql -U analytics < scripts/create_tables.sql
docker exec -i analytics-postgres psql -U analytics < scripts/load_basic_data.sql

# 5. Airflow
# http://localhost:8080 → включить DAG etl_to_clickhouse

# 6. Grafana
# http://localhost:3001 → добавить datasource PostgreSQL
```

## 🗂️ Файлы

- `backups/*_schema.sql` — только схемы БД
- `backups/clickhouse_sales_daily_sample.csv` — 100 строк sample
- `backups/*.sql` — полные дампы **не в git** (см. `.gitignore`)
- `configs/docker-compose.yml.original` — оригинал (с паролями в git **не идёт**)

## 🔒 Безопасность

- Все пароли вынесены в `.env` (не коммитится)
- `profiles.yml` использует `${POSTGRES_PASSWORD}`
- `etl_to_clickhouse.py` использует `${CLICKHOUSE_PASSWORD}`