# 📊 Analytics Stack — Аналитическая платформа сети супермаркетов

**Дата документирования:** 2026-08-30  
**Версия:** 1.0  
**Статус:** 📖 Документация; инфраструктура демонтирована 28.09.2026  
**Исторический срез:** 21.09.2026

---

## 🎯 О ПРОЕКТЕ

**Analytics Stack** — учебная аналитическая платформа на синтетических данных розничной сети. В историческом окружении проверялись сбор, обработка и визуализация данных о продажах, товарах, клиентах и филиалах. Это не production-система.

### Ключевые характеристики:
- **Модель данных:** Retail (супермаркеты: товары, категории, поставщики, филиалы, сотрудники, клиенты, продажи)
- **Объём данных:** 10 000 заказов, 5 914 клиентов с завершёнными заказами, 30 филиалов, 2 500 товаров
- **Выручка:** все статусы — 11 333 254,25 ₽; `completed` — 10 601 006,25 ₽
- **Средний чек:** `completed` — 1 133,31 ₽
- **Stack:** Docker + PostgreSQL + ClickHouse + Apache Airflow + dbt + Metabase/Superset/Grafana
- **Оркестрация:** Apache Airflow (LocalExecutor)
- **Трансформация:** dbt (Data Build Tool)

---

## 🏗️ АРХИТЕКТУРА DWH (DATA WAREHOUSE)

### Общая схема потока данных:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ANALYTICS STACK                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  SOURCE (PostgreSQL)                                                 │
│  └─ Raw Tables (Retail Data)                                        │
│     ├─ Categories, Products, Suppliers                               │
│     ├─ Branches, Employees, Customers                                │
│     └─ Sales, Sale_Details                                           │
│                                                                       │
│             ⬇️ (Apache Airflow ETL)                                  │
│                                                                       │
│  TRANSFORM LAYER (dbt + PostgreSQL Views)                            │
│  ├─ STAGING (Staging Models)                                         │
│  │  └─ stg_sales.sql — подготовка и очистка данных о продажах      │
│  │                                                                    │
│  └─ MARTS (Analytics Models / Dimension & Fact Tables)               │
│     └─ [Пустая папка — готова к расширению]                         │
│                                                                       │
│             ⬇️ (ETL: Extract → Transform → Load)                    │
│                                                                       │
│  AGGREGATION & EXPORT (PostgreSQL Queries + Python)                  │
│  └─ Агрегированные данные (продажи по датам, филиалам, категориям) │
│                                                                       │
│             ⬇️ (HTTP API / SQL Connectors)                          │
│                                                                       │
│  WAREHOUSE (ClickHouse)                                              │
│  └─ sales_daily (MergeTree Engine)                                   │
│     ├─ Высокая скорость аналитических запросов                      │
│     ├─ ORDER BY (sale_date, category_id, branch_id)                 │
│     └─ 30 000 строк (исторический результат трёх запусков)          │
│                                                                       │
│             ⬇️ (SQL Connectors / APIs)                              │
│                                                                       │
│  PRESENTATION LAYER (BI Tools)                                       │
│  ├─ 🎯 Metabase (Port 3000) — Data Discovery                        │
│  ├─ 📊 Apache Superset (Port 8088) — Self-Service Analytics         │
│  ├─ 📈 Grafana (Port 3001) — Dashboards & Monitoring                │
│  ├─ 🔍 Re:Dash (Port 5000) — Query & Visualization                  │
│  ├─ 📱 Node-RED (Port 1880) — Workflow Automation                   │
│  └─ 📋 Metabase UI (native SQL editor)                              │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

### Основные компоненты:

| Компонент | Роль | Порт | Контейнер |
|-----------|------|------|-----------|
| **PostgreSQL** | Operational DB + Staging | 5432 | `analytics-postgres` |
| **ClickHouse** | Warehouse (OLAP) | 8123, 9005 | `analytics-clickhouse` |
| **Apache Airflow** | Orchestration & Scheduling | 8080 | `airflow` + `airflow-scheduler` |
| **dbt** | Transformation Layer | - | `analytics-dbt` |
| **Metabase** | BI & Data Discovery | 3000 | `analytics-metabase` |
| **Apache Superset** | Self-Service Analytics | 8088 | `analytics-superset` |
| **Grafana** | Monitoring & Dashboards | 3001 | `grafana` |
| **Re:Dash** | SQL Query & Vis. | 5000 | `redash` |
| **Redis** | Cache & Job Queue | 6379 | `analytics-redis` |
| **Kafka** | Event Streaming | 9092, 9093 | `analytics-kafka` |
| **MinIO** | S3-Compatible Storage | 9105, 9001 | `analytics-minio` |
| **Qdrant** | Vector DB (для embeddings) | 6333, 6334 | `analytics-qdrant` |
| **MongoDB** | NoSQL Storage | 27017 | `mongodb` |
| **Apache NiFi** | Data Flow Automation | 8443 | `nifi` |
| **Node-RED** | Low-Code Workflows | 1880 | `node-red` |

---

## 🔀 СЛОИ АРХИТЕКТУРЫ DWH

### 1️⃣ **RAW Layer** (Сырые данные)
**Расположение:** PostgreSQL `analytics_db_new`  
**Характеристика:** Точная копия исходных данных OLTP-системы  
**Таблицы:**
- `Categories` — 9 категорий товаров
- `Suppliers` — 20 поставщиков
- `Products` — 2,500 товаров с характеристиками
- `Branches` — 30 филиалов/магазинов
- `Employees` — 210 сотрудников
- `Customers` — 10,000 клиентов
- `Sales` — 10,000 заказов (9,354 завершены)
- `Sale_Details` — 20 000 позиций заказов по SQL-дампу

**Управление:** [database/schemas/](../bi-analytics-stack/database/schemas/)
- `01_create_tables.sql` — Создание полной схемы
- `02_load_categories.sql` — Загрузка справочников
- `03_load_suppliers.sql`
- `04_load_products.sql`
- `05_load_branches.sql`
- `06_load_employees.sql`
- `07_load_customers.sql`

---

### 2️⃣ **STAGING Layer** (Подготовка и очистка)
**Расположение:** PostgreSQL (views + dbt staging models)  
**Инструмент:** **dbt** (Data Build Tool)  
**Путь:** [dbt/models/staging/](../bi-analytics-stack/dbt/models/staging/)

#### dbt-модели Staging:
```
dbt/models/staging/
└── stg_sales.sql
    ├─ Фильтрует только завершенные заказы (status = 'completed')
    ├─ Выбирает релевантные поля
    ├─ Переименовывает колонки для ясности
    ├─ Удаляет дубликаты
    └─ Тип материализации: VIEW (быстро, но без сохранения)
```

**Что делает stg_sales:**
```sql
SELECT 
    sale_id,
    branch_id,
    customer_id,
    employee_id,
    sale_date,
    sale_time,
    total_amount,
    discount_amount,
    payment_method,
    status
FROM sales
WHERE status = 'completed'  -- 🔍 ФИЛЬТРАЦИЯ
```

**Цель:**
- Унификация данных
- Очистка и валидация
- Подготовка к трансформации
- Отделение "хорошего" от "плохого" (статус != failed, cancelled и т.д.)

---

### 3️⃣ **MARTS Layer** (Аналитические таблицы)
**Расположение:** PostgreSQL / ClickHouse  
**Путь:** [dbt/models/marts/](../bi-analytics-stack/dbt/models/marts/)  
**Статус:** 📝 Готовы к расширению

**Ожидаемые Mart Models:**
```
dbt/models/marts/
├── fct_sales.sql          # Fact Table: все транзакции продаж
├── dim_products.sql       # Dimension: товары + характеристики
├── dim_customers.sql      # Dimension: клиенты + сегментация
├── dim_branches.sql       # Dimension: филиалы + геолокация
├── dim_time.sql           # Dimension: время (дата, неделя, месяц, квартал, год)
└── agg_sales_daily.sql    # Aggregate: ежедневные продажи по филиалам/категориям
```

**Каждый Mart это либо:**
- **Fact Table** (✗ — множество строк, денормализовано) — все транзакции
- **Dimension Table** (✓ — мало строк, стабильно) — справочники

**Тип материализации (в dbt_project.yml):**
```yaml
models:
  analytics:
    staging:
      materialized: view          # VIEW: определение, без сохранения
    marts:
      materialized: table         # TABLE: хранится в БД, индексы
```

---

### 4️⃣ **DATA WAREHOUSE Layer** (OLAP-хранилище)
**Расположение:** ClickHouse  
**Тип:** Columnar OLAP Database (оптимизирована для аналитики)  
**Таблицы:**

#### sales_daily (MergeTree)
```sql
CREATE TABLE sales_daily (
    sale_date Date,                   -- 📅 Дата продажи
    category_id UInt32,               -- 🏷️  ID категории
    category_name String,             -- 🏷️  Название категории
    branch_id UInt32,                 -- 🏢 ID филиала
    branch_name String,               -- 🏢 Название филиала
    city String,                      -- 🌆 Город
    total_orders UInt32,              -- 📊 Количество заказов
    total_revenue Float64,            -- 💰 Общая выручка
    avg_order_value Float64,          -- 💰 Средняя стоимость заказа
    unique_customers UInt32,          -- 👥 Уникальные клиенты
    created_at DateTime DEFAULT now() -- ⏰ Время загрузки
) ENGINE = MergeTree()
ORDER BY (sale_date, category_id, branch_id)
```

**Зачем ClickHouse?**
- ✅ Колоночное хранилище (компрессия ~10x)
- ✅ Быстрые аналитические запросы (sub-second)
- ✅ Масштабируемость (триллионы строк)
- ✅ REPLACE/UPDATE эффективны
- ✅ Встроенная репликация

---

### 5️⃣ **PRESENTATION Layer** (Визуализация & Интеграция)
**Инструменты:** Metabase, Superset, Grafana, Re:Dash  

| Инструмент | Назначение | URL | Features |
|-----------|-----------|-----|----------|
| **Metabase** | Data Discovery | http://localhost:3000 | Native query builder, user-friendly |
| **Superset** | Self-Service BI | http://localhost:8088 | Advanced visualizations, semantic layer |
| **Grafana** | Monitoring | http://localhost:3001 | Real-time dashboards, alerting |
| **Re:Dash** | SQL Analytics | http://localhost:5000 | Queries, scheduled reports |

---

## 🔄 ETL ПРОЦЕСС (Extract → Transform → Load)

### Общая схема ETL:

```
PostgreSQL (Raw)
      ⬇️
┌─────────────────────────────────────────┐
│  1. EXTRACT (Извлечение)                │
│  ─────────────────────────────           │
│  • Выборка из PostgreSQL                 │
│  • Фильтрация (status = 'completed')    │
│  • SQL JOIN между таблицами              │
│  • Агрегирование по филиалам/категориям │
│  • Результат: до 5,000 строк за запуск (LIMIT DAG) │
└─────────────────────────────────────────┘
      ⬇️
┌─────────────────────────────────────────┐
│  2. TRANSFORM (Трансформация)            │
│  ─────────────────────────────           │
│  • dbt: staging models (очистка)        │
│  • Вычисления: avg, sum, count           │
│  • Округление денежных значений          │
│  • Подготовка структуры для ClickHouse   │
│  • Кодирование строк ([:100])            │
└─────────────────────────────────────────┘
      ⬇️
┌─────────────────────────────────────────┐
│  3. LOAD (Загрузка)                      │
│  ─────────────────────────────           │
│  • INSERT в ClickHouse (sales_daily)    │
│  • Масштабная загрузка (bulk insert)     │
│  • Обновление индексов                   │
│  • Логирование результатов               │
└─────────────────────────────────────────┘
      ⬇️
ClickHouse (Warehouse)
```

### 📝 Файлы ETL:

#### [airflow/dags/etl_to_clickhouse.py](../bi-analytics-stack/airflow/dags/etl_to_clickhouse.py)
**Статус:** исторически запускался; 3 успешных запуска зафиксированы 26.08.2026. ВМ демонтированы 28.09.2026.  
**Оркестратор:** Apache Airflow 2.10.0  
**Тип:** LocalExecutor (однопоточный для dev)

**DAG-структура:**
```
START
  ⬇️
CREATE_CLICKHOUSE_TABLES
  ⬇️
EXTRACT_AGGREGATED_DATA
  ⬇️
LOAD_TO_CLICKHOUSE
  ⬇️
CHECK_CLICKHOUSE_DATA
  ⬇️
END
```

**Основные функции:**

1. **create_clickhouse_tables()** — создает таблицу `sales_daily` если не существует
2. **extract_aggregated_data()** — сложный SQL-запрос с JOIN
   ```python
   SELECT 
       s.sale_date,
       p.category_id,
       c.category_name,
       b.branch_id,
       b.branch_name,
       b.city,
       COUNT(DISTINCT s.sale_id) as total_orders,
       ROUND(SUM(s.total_amount)::numeric, 2) as total_revenue,
       ROUND(AVG(s.total_amount)::numeric, 2) as avg_order_value,
       COUNT(DISTINCT s.customer_id) as unique_customers
   FROM sales s
   JOIN branches b ON s.branch_id = b.branch_id
   JOIN sale_details sd ON s.sale_id = sd.sale_id
   JOIN products p ON sd.product_id = p.product_id
   JOIN categories c ON p.category_id = c.category_id
   WHERE s.status = 'completed'
   GROUP BY s.sale_date, ...
   ```

3. **load_to_clickhouse()** — вставляет данные в `sales_daily`
   - Использует XCom для передачи данных между тасками
   - Берет результаты из `extract_aggregated_data`
   - Кодирует строки для безопасности
   - Использует batch insert

4. **check_clickhouse_data()** — валидация загрузки
   ```sql
   SELECT COUNT(*) as total_records,
          MIN(sale_date) as min_date,
          MAX(sale_date) as max_date,
          SUM(total_revenue) as total_revenue
   FROM sales_daily
   ```

**Retry Logic:**
- Retries: 2 попытки
- Delay: 5 минут между попытками
- Start Date: 2024-01-01
- Schedule: Manual (not automatic)

---

## 🛠️ DBT (Data Build Tool) — Трансформация

### Что такое dbt?
dbt — это фреймворк для трансформации данных в warehouse. Вместо написания SQL-скриптов вручную, dbt управляет:
- ✅ Зависимостями между моделями
- ✅ Версионированием
- ✅ Тестированием данных
- ✅ Документацией

### Структура dbt в проекте:

```
dbt/
├── dbt_project.yml          # ⚙️  Конфиг проекта
├── profiles/
│   └── profiles.yml         # 🔐 Credentials (в .gitignore!)
├── models/
│   ├── staging/             # STAGING layer
│   │   └── stg_sales.sql    # Очистка продаж
│   └── marts/               # MARTS layer (пусто)
├── tests/                   # 🧪 Data quality tests
├── macros/                  # 🔧 Переиспользуемые функции
├── seeds/                   # 📊 Static data files
└── target/                  # 📦 Compiled SQL (в .gitignore!)
```

### [dbt/dbt_project.yml](../bi-analytics-stack/dbt/dbt_project.yml):
```yaml
name: 'analytics'
version: '1.0.0'
config-version: 2
profile: 'analytics'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]

models:
  analytics:
    staging:
      materialized: view      # Временные представления
    marts:
      materialized: table     # Постоянные таблицы
```

### Команды dbt (внутри контейнера):
```bash
# Запуск в контейнере (docker-compose exec analytics-dbt ...)

dbt compile              # Компилирует YAML → SQL
dbt run                  # Выполняет все модели в порядке зависимостей
dbt test                 # Проверяет качество данных
dbt seed                 # Загружает CSV-файлы в таблицы
dbt docs generate        # Генерирует документацию
dbt freshness            # Проверяет свежесть данных

# Специфичные запуски:
dbt run -m staging       # Только staging модели
dbt run -m marts         # Только marts модели
dbt test --select stg_sales  # Тесты для stg_sales
```

### Путь к dbt в контейнере:
- **Рабочая директория:** `/usr/app` (=`./dbt` на хосте)
- **dbt profiles:** `/root/.dbt/profiles.yml`
- **Target folder:** `/usr/app/target/`

---

## 📂 ФАЙЛОВАЯ СТРУКТУРА & УПРАВЛЕНИЕ

### Корневая папка: c:\Users\MI\Downloads\analytics-stack\

```
analytics-stack/
│
├── 🐳 DOCKER & ОРХЕСТРАЦИЯ
│   ├── docker-compose.yml                    # ⭐ ГЛАВНЫЙ конфиг (16 сервисов)
│   ├── docker-compose.yml.backup
│   ├── docker-compose.yml.dbt-backup         # Версия только с dbt
│   ├── docker-compose.yml.metabase-backup
│   ├── .env                                  # 🔐 Environment variables (в .gitignore!)
│   └── .env.example                          # Пример .env
│
├── 🗄️  DATABASE (PostgreSQL)
│   ├── README.md                             # Статистика БД
│   ├── schemas/
│   │   ├── 01_create_tables.sql              # Создание полной схемы
│   │   ├── 02_load_categories.sql
│   │   ├── 03_load_suppliers.sql
│   │   ├── 04_load_products.sql
│   │   ├── 05_load_branches.sql
│   │   ├── 06_load_employees.sql
│   │   └── 07_load_customers.sql
│   ├── backups/
│   │   ├── analytics_db_backup_20260825.sql # 💾 Последняя backup
│   │   ├── README.md
│   │   └── RESTORE_GUIDE.md                 # Как восстановить
│   └── migrations/                          # (пусто, готово к расширению)
│
├── 🔄 ETL & ОРКЕСТРАЦИЯ (Apache Airflow)
│   └── airflow/
│       ├── dags/
│       │   └── etl_to_clickhouse.py          # ⭐ Главный ETL DAG
│       ├── logs/                            # 📝 Логи выполнений
│       │   └── dag_id=etl_to_clickhouse/
│       │       ├── run_id=manual__2026-08-26T09:53:33.789713+00:00/
│       │       ├── run_id=manual__2026-08-26T11:22:41.733713+00:00/
│       │       └── run_id=manual__2026-08-26T11:23:26+00:00/
│       └── plugins/                         # Кастомные операторы
│
├── 📊 dbt (Трансформация)
│   ├── dbt_project.yml                      # ⚙️  Конфиг проекта
│   ├── profiles/
│   │   └── profiles.yml                     # 🔐 Credentials (в .gitignore!)
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_sales.sql                # Staging моделей
│   │   └── marts/                           # (пусто, готово к расширению)
│   ├── tests/                               # Data quality tests
│   ├── macros/                              # Переиспользуемые функции
│   ├── seeds/                               # Static data
│   └── target/                              # Compiled SQL (в .gitignore!)
│
├── 📈 BI TOOLS
│   ├── metabase/
│   │   ├── data/                            # Metabase БД
│   │   ├── logs/
│   │   └── plugins/
│   ├── superset/                            # (в docker-compose)
│   └── grafana/                             # (в docker-compose)
│
├── 📝 SCRIPTS (SQL)
│   ├── create_sales_final.sql               # Финальная таблица продаж
│   ├── create_tables.sql
│   ├── fix_categories.sql
│   ├── insert_data.sql
│   ├── load_basic_data.sql
│   ├── load_customers_employees.sql
│   ├── load_orders.sql
│   ├── load_orders_fixed.sql
│   ├── load_orders_simple.sql
│   ├── load_supplies.sql
│   ├── retail_schema.sql
│   └── backup/                              # Старые версии скриптов
│
├── 💾 DATA (Статические файлы)
│   └── (для CSV, Parquet seed files)
│
├── 📚 ДОКУМЕНТАЦИЯ
│   ├── Обьяснение.md                        # ⭐ Этот файл
│   └── docs/
│
└── ⚙️  КОНФИГИ
    └── (переменные окружения, сеты)
```

---

## 🚀 КЛЮЧЕВЫЕ ФАЙЛЫ УПРАВЛЕНИЯ ПРОЕКТОМ

### 1. [docker-compose.yml](../bi-analytics-stack/configs/docker-compose.yml) — Оркестрация сервисов
**Зачем нужен:** Определяет все контейнеры, сети, тома, переменные окружения  
**Команды:**
```bash
# Запустить весь stack
docker-compose up -d

# Остановить
docker-compose down

# Перезагрузить
docker-compose restart

# Посмотреть логи
docker-compose logs -f <service_name>
docker-compose logs -f airflow     # Logs Airflow
docker-compose logs -f postgres    # Logs PostgreSQL
```

**16 сервисов объявлено в текущем Compose:**
1. PostgreSQL — исходная БД
2. ClickHouse — warehouse
3. Metabase — BI
4. Superset — BI
5. Redis — кеш
6. Kafka — streaming
7. Qdrant — vector DB
8. MinIO — S3-совместимое хранилище
9. Airflow — оркестратор
10. Airflow-scheduler — планировщик
11. NiFi — data flow
12. MongoDB — NoSQL
13. Grafana — мониторинг
14. Re:Dash — SQL analytics
15. Node-RED — workflows
16. dbt — трансформация
17. (другие...)

---

### 2. [airflow/dags/etl_to_clickhouse.py](../bi-analytics-stack/airflow/dags/etl_to_clickhouse.py) — Главный ETL DAG

**Управление:**
```bash
# Запуск DAG вручную
docker-compose exec airflow airflow dags trigger etl_to_clickhouse

# Посмотреть статус
docker-compose exec airflow airflow dags list

# Проверить логи задачи
docker-compose exec airflow airflow tasks list etl_to_clickhouse

# Запустить конкретную задачу
docker-compose exec airflow airflow tasks test etl_to_clickhouse extract_aggregated_data
```

**Поток выполнения:**
- start → create_clickhouse_tables → extract_aggregated_data → load_to_clickhouse → check_clickhouse_data → end

---

### 3. [database/schemas/01_create_tables.sql](../bi-analytics-stack/database/schemas/01_create_tables.sql) — Схема БД

**Запуск:**
```bash
# Подключиться к PostgreSQL
docker-compose exec postgres psql -U analytics -d analytics_db_new

# Выполнить все скрипты
docker-compose exec postgres psql -U analytics -d analytics_db_new -f /scripts/01_create_tables.sql
```

**Таблицы:**
- Categories, Suppliers, Products
- Branches, Employees, Customers
- Sales, Sale_Details

---

### 4. [dbt/dbt_project.yml](../bi-analytics-stack/dbt/dbt_project.yml) — Конфиг трансформации

**Запуск:**
```bash
# Внутри контейнера dbt
docker-compose exec analytics-dbt dbt run

# Тесты
docker-compose exec analytics-dbt dbt test

# Документация
docker-compose exec analytics-dbt dbt docs generate
docker-compose exec analytics-dbt dbt docs serve  # http://localhost:8000
```

---

### 5. [.env](/.env) — Переменные окружения
**🔐 КРИТИЧНО:** Содержит пароли, credentials!  
**В .gitignore:** ✅ ДА (защищено)

**Переменные:**
```env
# PostgreSQL
POSTGRES_USER=analytics
POSTGRES_PASSWORD=<POSTGRES_PASSWORD>
POSTGRES_DB=analytics_db_new

# ClickHouse
CLICKHOUSE_USER=clickhouse
CLICKHOUSE_PASSWORD=<CLICKHOUSE_PASSWORD>

# Metabase
METABASE_DB_NAME=metabase_db
METABASE_DB_USER=analytics
METABASE_DB_PASSWORD=<METABASE_PASSWORD>

# Superset
SUPERSET_ADMIN_USER=admin
SUPERSET_ADMIN_PASSWORD=<SUPERSET_PASSWORD>
SUPERSET_SECRET_KEY=...

# Другие сервисы...
```

---

## 📊 DATA FLOW ДИАГРАММА

```
┌──────────────────────────────────────────────────────────────────┐
│                       RETAIL DATA SOURCES                         │
│  (POS System, Online Store, Inventory System, CRM, etc.)         │
└────────────────────────┬─────────────────────────────────────────┘
                         │ Sync
                         ⬇️
┌──────────────────────────────────────────────────────────────────┐
│              OPERATIONAL DATABASE (PostgreSQL)                    │
│  Tables: Categories, Products, Suppliers, Branches, Employees,   │
│          Customers, Sales, Sale_Details, Stock, etc.             │
└────────────────────────┬─────────────────────────────────────────┘
                         │ 
                  ┌──────┴──────┐
                  ⬇️             ⬇️
        ┌─────────────────┐  ┌──────────────────┐
        │   dbt STAGING   │  │  SQL Views       │
        │  (stg_sales)    │  │  (Aggregates)    │
        └────────┬────────┘  └────────┬─────────┘
                 │                    │
                 └─────────┬──────────┘
                           ⬇️
        ┌──────────────────────────────────────┐
        │  Apache Airflow ETL DAG              │
        │  (etl_to_clickhouse.py)              │
        │                                      │
        │  1. Extract from PostgreSQL          │
        │  2. Transform (aggregation)          │
        │  3. Load to ClickHouse               │
        │  4. Validate data                    │
        └──────────────┬───────────────────────┘
                       ⬇️
        ┌──────────────────────────────────────┐
        │   ANALYTICS WAREHOUSE (ClickHouse)   │
        │   sales_daily Table (MergeTree)      │
        │   - High-speed analytics             │
        │   - Columnar compression             │
        │   - Partitioned by date              │
        └──────────────┬───────────────────────┘
                       ⬇️
        ┌──────────────────────────────────────┐
        │    BUSINESS INTELLIGENCE TOOLS       │
        ├──────────────────────────────────────┤
        │  • Metabase (Discovery)              │
        │  • Superset (Self-Service BI)        │
        │  • Grafana (Monitoring Dashboards)   │
        │  • Re:Dash (SQL Analytics)           │
        │  • Node-RED (Workflow Automation)    │
        │  • Kafka (Real-time Events)          │
        └──────────────┬───────────────────────┘
                       ⬇️
        ┌──────────────────────────────────────┐
        │    BUSINESS USERS & DASHBOARDS       │
        │  (Sales, Marketing, Finance, Ops)    │
        └──────────────────────────────────────┘
```

---

## 🔧 QUICK START

Инструкция описывает повторное локальное развёртывание. Исходные ВМ демонтированы; запуск требует локального Docker Compose, актуального `.env` и проверки конфигурации.

### Запуск проекта:
```bash
cd analytics-stack

# 1. Скопировать .env.example в .env
cp .env.example .env

# 2. Запустить все сервисы
docker-compose up -d

# 3. Инициализировать Airflow (первый запуск)
docker-compose exec airflow airflow db init
docker-compose exec airflow airflow users create --username admin --password '<SET_SECURE_AIRFLOW_PASSWORD>' --firstname Admin --lastname User --role Admin --email admin@example.com

# 4. Инициализировать dbt
docker-compose exec analytics-dbt dbt deps
docker-compose exec analytics-dbt dbt run

# 5. Запустить ETL DAG
docker-compose exec airflow airflow dags trigger etl_to_clickhouse

# 6. Проверить логи
docker-compose logs -f airflow

# 7. Открыть интерфейсы:
#    - Airflow: http://localhost:8080 (admin / пароль задан при инициализации)
#    - Metabase: http://localhost:3000
#    - Superset: http://localhost:8088
#    - Grafana: http://localhost:3001
#    - Re:Dash: http://localhost:5000
```

### Проверка статуса:
```bash
# Все ли сервисы запущены?
docker-compose ps

# Логи PostgreSQL
docker-compose logs -f postgres

# Логи ClickHouse
docker-compose logs -f clickhouse

# Логи Airflow
docker-compose logs -f airflow

# Логи Airflow Scheduler
docker-compose logs -f airflow-scheduler
```

---

## 📈 МЕТРИКИ & СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Всего товаров** | 2,500 |
| **Категорий** | 9 |
| **Поставщиков** | 20 |
| **Филиалов** | 30 |
| **Сотрудников** | 210 |
| **Клиентов** | 10,000 |
| **Заказов всего** | 10 000 |
| **Завершённых заказов (`completed`)** | 9 354 (93,54%) |
| **Выручка, все статусы** | 11 333 254,25 ₽ |
| **Выручка, `completed`** | 10 601 006,25 ₽ |
| **Средний чек, `completed`** | 1 133,31 ₽ |
| **Клиентов с завершёнными заказами** | 5 914 |
| **Размер БД PostgreSQL** | ~500 MB |
| **Размер ClickHouse** | ~200 MB (скомпрессирован) |

---

## 🎯 АРХИТЕКТУРНЫЕ РЕШЕНИЯ

### Почему именно эта архитектура?

1. **PostgreSQL → ClickHouse**
   - PostgreSQL хороша для OLTP (транзакции), но не для аналитики
   - ClickHouse оптимизирована для OLAP (аналитические запросы)
   - Результат: запросы выполняются в 10-100x быстрее

2. **Apache Airflow для оркестрации**
   - Управляет сложными DAG-зависимостями
   - Retry logic, backfill, SLA monitoring
   - Web UI для визуализации

3. **dbt для трансформации**
   - Версионирование + тестирование данных
   - DRY принцип (не повторяй SQL)
   - Документация автоматом

4. **Несколько BI-инструментов**
   - Metabase: интуитивный, для бизнеса
   - Superset: мощные визуализации
   - Grafana: мониторинг в real-time
   - Re:Dash: для аналитиков (SQL)

5. **Docker Compose**
  - Локальная конфигурация не эквивалентна production-развёртыванию; исходная инфраструктура была учебной и демонтирована.
   - Все сервисы изолированы в контейнерах
   - Легко масштабировать в Kubernetes позже

---

## 🚨 ТИПИЧНЫЕ ПРОБЛЕМЫ & РЕШЕНИЯ

### Проблема: Airflow не может подключиться к PostgreSQL
```bash
docker-compose logs airflow | grep -i error

# Решение:
# 1. Проверить что postgres запущен: docker-compose ps
# 2. Проверить .env переменные
# 3. Перезагрузить: docker-compose restart postgres airflow
```

### Проблема: ClickHouse "Permission denied"
```bash
# Решение: Проверить credentials в .env
CLICKHOUSE_USER=clickhouse
CLICKHOUSE_PASSWORD=change_me

# Перезагрузить контейнер:
docker-compose restart clickhouse
```

### Проблема: dbt компилирует, но не запускается
```bash
# Проверить profiles.yml
docker-compose exec analytics-dbt cat /root/.dbt/profiles.yml

# Проверить зависимости
docker-compose exec analytics-dbt dbt deps
```

---

## 📚 ДОПОЛНИТЕЛЬНЫЕ РЕСУРСЫ

- **Apache Airflow:** https://airflow.apache.org/
- **dbt Documentation:** https://docs.getdbt.com/
- **ClickHouse Documentation:** https://clickhouse.com/docs/en/intro
- **Metabase Guide:** https://www.metabase.com/learn/
- **Apache Superset:** https://superset.apache.org/

---

## ✅ СТАТУС ПРОЕКТА

Последний рабочий снимок относится к 21.09.2026; инфраструктура демонтирована 28.09.2026. В Compose объявлено 16 сервисов. В списке ниже Airflow объединяет webserver и scheduler; в последнем запуске работали 9 контейнеров. dbt завершился `Exited (0)` и запускается по требованию, поэтому не входит в эти 9.

| Компонент | Статус | Комментарий |
|-----------|--------|-----------|
| PostgreSQL | ✅ Работал | `postgres:15-alpine`, health checks |
| ClickHouse | ✅ Работал | MergeTree; 30 000 строк по историческому отчёту |
| Airflow | ✅ Работал | LocalExecutor; DAG `etl_to_clickhouse` |
| dbt | ⚠️ Частично | Staging-модель есть, marts пусты; не интегрирован в DAG; завершался `Exited (0)` |
| Metabase | ⚠️ Поднят | Подключение к PostgreSQL; сохранённый дашборд не подтверждён |
| Superset | ❌ Не использовался | Эксперимент; не был в последнем рабочем наборе |
| Grafana | ✅ Работала | Stat-панель: 10 000 заказов; выручка 11 333 254,25 ₽ по всем статусам |
| NiFi | ❌ Не использовался | Отмечена проблема SSL |
| Kafka | ❌ Не использовался | pub/sub не проверен |
| Qdrant | ❌ Не использовался | API key не настроен |
| MinIO | ⚠️ Поднят | Бакет есть; по историческому отчёту только `test_backup.sql` (60 байт) |
| MongoDB | ❌ Не работал стабильно | Зафиксирован `Restarting (139)` |
| Node-RED | ✅ Работал | Flow `Inject → Debug` |
| Redash | ❌ Не работал | `Internal Server Error` |
| Redis | ✅ Работал | Ключи проверялись; volume отсутствует, данные не переживают пересоздание |

---

**Проект документирован как учебный кейс Data/Analytics Engineering.**
Инфраструктура демонтирована 28.09.2026. Код и конфигурация сохранены в репозитории.
