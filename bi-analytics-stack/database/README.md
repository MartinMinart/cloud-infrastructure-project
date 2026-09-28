# 📊 База данных аналитической платформы

**Актуализировано:** 2026-09-28

## Описание
База данных для аналитической платформы сети супермаркетов. Содержит данные о товарах, клиентах, заказах и филиалах.

## Версия

| Параметр | Значение |
|----------|----------|
| СУБД | PostgreSQL 15 |
| База данных | analytics_db_new |
| Дата | 2026-08-25 |
| Пользователь | analytics |
| Пароль | ${POSTGRES_PASSWORD} |

---

## 📋 Содержание
- [Структура базы данных](#структура-базы-данных)
- [Представления (Views)](#представления-views)
- [ER-диаграмма](#er-диаграмма)
- [Статистика](#статистика)
- [Примеры запросов](#примеры-запросов)
- [Подключение](#подключение)
- [Бэкап и восстановление](#бэкап-и-восстановление)
- [Перенос базы в другой проект](#перенос-базы-в-другой-проект)

---

## Структура базы данных

### Таблицы

| Таблица | Записей | Описание |
|---------|---------|----------|
| **Categories** | 9 | Категории товаров |
| **Suppliers** | 20 | Поставщики |
| **Products** | 2,500 | Товары (с категориями) |
| **Branches** | 30 | Филиалы магазинов |
| **Employees** | 210 | Сотрудники |
| **Customers** | 10,000 | Клиенты |
| **Sales** | 10,000 | Заказы |
| **Sale_Details** | ~10,000 | Позиции заказов |
| **Inventory** | 0 | Остатки товаров |
| **Supplies** | 0 | Поставки |
| **Supply_Details** | 0 | Детали поставок |
| **Promotions** | 0 | Промо-акции |
| **Sections** | 0 | Отделы магазина |
| **Work_Schedule** | 0 | График работы |

### Связи между таблицами

```text
Categories (1) ──┬─ Products (N) ──┬─ Sale_Details (N) ── Sales (N) ── Customers (N)
                 │                 │
Suppliers (1) ───┘                 ├─ Supply_Details (N) ── Supplies (N) ── Branches (N)
                                   │
                                   └─ Inventory (N) ───────┘

Branches (1) ──┬─ Employees (N)
               ├─ Sales (N)
               ├─ Supplies (N)
               └─ Inventory (N)
```

## Представления (Views)

| Название | Описание |
|----------|----------|
| `v_sales_analytics` | Полная аналитика по продажам |
| `v_inventory` | Статус остатков товаров |
| `v_kpi_daily` | Ежедневные KPI |
| `v_kpi_monthly` | Месячные KPI |
| `v_product_performance` | Эффективность товаров |
| `v_branch_performance` | Эффективность филиалов |
| `v_customer_insights` | Инсайты по клиентам |

## ER-диаграмма

```text
┌─────────────┐        ┌─────────────┐        ┌─────────────┐
│  Suppliers   │──────│   Products   │──────│  Categories  │
│ supplier_id │        │  product_id  │        │ category_id │
└─────────────┘        └─────────────┘        └─────────────┘
                        │
                        │
                 ┌──────▼──────┐
                 │  Inventory  │
                 │  branch_id  │
                 │  product_id │
                 └─────────────┘
                 │
                 ┌──────▼──────┐        ┌─────────────┐
                 │ Sale_Details│──────│    Sales     │
                 │ sale_detail │        │   sale_id   │
                 │   sale_id   │        │  branch_id  │
                 │  product_id │        │ customer_id │
                 └─────────────┘        └─────────────┘
                 │                    │
                 ┌──────▼──────┐        │
                 │  Branches   │◀────────┘
                 │  branch_id  │
                 └─────────────┘
                 │
                 │
                 ┌──────▼──────┐        ┌─────────────┐
                 │  Employees  │        │  Customers  │
                 │ employee_id │        │ customer_id │
                 │  branch_id  │        └─────────────┘
                 └─────────────┘
```

---

## Статистика

### Общая статистика

| Показатель | Значение |
|------------|----------|
| Всего заказов | 10,000 |
| Завершенных заказов | 9,354 |
| Выручка (завершенные) | 10,601,006 ₽ |
| Средний чек | 1,133 ₽ |
| Клиентов с покупками | 5,914 |
| Общие траты клиентов | 10,114,596 ₽ |

### Статистика по статусам заказов

| Статус | Заказов | Сумма |
|--------|---------|-------|
| completed | 9,354 | 10,601,006 ₽ |
| processing | 631 | 714,781 ₽ |
| cancelled | 15 | 17,467 ₽ |

### Распределение товаров по категориям

| Категория | Количество товаров |
|-----------|-------------------|
| Продукты питания | 278 |
| Молочные продукты | 278 |
| Мясные продукты | 278 |
| Хлеб-выпечка | 278 |
| Овощи-фрукты | 278 |
| Бакалея | 278 |
| Напитки | 278 |
| Сладости-снеки | 277 |
| Бытовая химия | 277 |

---

## Примеры запросов

### 1. Выручка по месяцам

```sql
SELECT 
    DATE_TRUNC('month', sale_date) as month,
    COUNT(*) as orders,
    ROUND(SUM(total_amount)::numeric, 2) as revenue,
    ROUND(AVG(total_amount)::numeric, 2) as avg_order
FROM sales
WHERE status = 'completed'
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY month DESC
LIMIT 12;
```

### 2. Топ-10 товаров по выручке

```sql
SELECT 
    p.product_name,
    c.category_name,
    COUNT(DISTINCT sd.sale_id) as sales_count,
    SUM(sd.quantity) as total_quantity,
    ROUND(SUM(sd.total_price)::numeric, 2) as revenue
FROM sale_details sd
JOIN products p ON sd.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_name, c.category_name
ORDER BY revenue DESC
LIMIT 10;
```

### 3. Анализ клиентов по статусу лояльности

```sql
SELECT 
    loyalty_status,
    COUNT(*) as customer_count,
    ROUND(AVG(total_spent)::numeric, 2) as avg_spent,
    ROUND(SUM(total_spent)::numeric, 2) as total_spent
FROM customers
GROUP BY loyalty_status
ORDER BY total_spent DESC;
```

### 4. Оконная функция - скользящая средняя

```sql
SELECT 
    sale_date,
    COUNT(*) as orders,
    ROUND(SUM(total_amount)::numeric, 2) as daily_revenue,
    ROUND(
        AVG(SUM(total_amount)) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::numeric, 2
    ) as moving_avg_7days
FROM sales
WHERE status = 'completed'
GROUP BY sale_date
ORDER BY sale_date DESC
LIMIT 30;
```

### 5. Ранжирование товаров по выручке

```sql
WITH product_stats AS (
    SELECT 
        p.product_name,
        SUM(sd.total_price) as revenue,
        RANK() OVER (ORDER BY SUM(sd.total_price) DESC) as rank
    FROM sale_details sd
    JOIN products p ON sd.product_id = p.product_id
    GROUP BY p.product_name
)
SELECT * FROM product_stats WHERE rank <= 10;
```

### 6. Анализ филиалов

```sql
SELECT 
    b.branch_name,
    b.city,
    COUNT(DISTINCT s.sale_id) as orders,
    ROUND(SUM(s.total_amount)::numeric, 2) as revenue,
    ROUND(AVG(s.total_amount)::numeric, 2) as avg_order,
    RANK() OVER (ORDER BY SUM(s.total_amount) DESC) as rank
FROM branches b
LEFT JOIN sales s ON b.branch_id = s.branch_id AND s.status = 'completed'
GROUP BY b.branch_name, b.city
ORDER BY revenue DESC;
```

### 7. Когортный анализ (Retention)

```sql
WITH cohorts AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(sale_date)) as cohort_month
    FROM sales
    WHERE status = 'completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        c.cohort_month,
        EXTRACT(MONTH FROM s.sale_date) - EXTRACT(MONTH FROM c.cohort_month) as month_number,
        COUNT(DISTINCT s.customer_id) as customers
    FROM sales s
    JOIN cohorts c ON s.customer_id = c.customer_id
    WHERE s.status = 'completed'
    GROUP BY c.cohort_month, month_number
)
SELECT 
    TO_CHAR(cohort_month, 'YYYY-MM') as cohort,
    month_number,
    customers,
    ROUND(customers::numeric / FIRST_VALUE(customers) OVER (PARTITION BY cohort_month ORDER BY month_number) * 100, 2) as retention
FROM cohort_data
ORDER BY cohort_month, month_number;
```

### 8. Проверка целостности данных

```sql
-- Проверка: все ли товары имеют категории
SELECT 
    COUNT(*) as total_products,
    COUNT(category_id) as with_category,
    COUNT(*) FILTER (WHERE category_id IS NULL) as without_category
FROM products;

-- Проверка: суммы заказов совпадают с деталями
SELECT 
    s.sale_id,
    s.total_amount as order_total,
    COALESCE(SUM(sd.total_price), 0) as details_total,
    s.total_amount - COALESCE(SUM(sd.total_price), 0) as difference
FROM sales s
LEFT JOIN sale_details sd ON s.sale_id = sd.sale_id
WHERE s.status = 'completed'
GROUP BY s.sale_id, s.total_amount
HAVING s.total_amount != COALESCE(SUM(sd.total_price), 0)
LIMIT 10;
```

---

## Подключение

### Через Docker

```bash
docker exec -it analytics-postgres psql -U analytics -d analytics_db_new
```

### Через внешнее подключение

| Параметр | Значение |
|----------|----------|
| Хост | 213.171.26.123 |
| Порт | 5432 |
| База данных | analytics_db_new |
| Пользователь | analytics |
| Пароль | ${POSTGRES_PASSWORD} |

## Бэкап и восстановление

### Создать бэкап

```bash
docker exec analytics-postgres pg_dump -U analytics analytics_db_new > database/backups/analytics_db_new_$(date +%Y%m%d).sql
```

### Восстановить бэкап

```bash
docker exec -i analytics-postgres psql -U analytics -d analytics_db_new < database/backups/analytics_db_new_*.sql
```

### Скачать бэкап на локальный ПК

```bash
# Из терминала (на локальном ПК)
scp user1@213.171.26.123:~/analytics-stack/database/backups/analytics_db_new_*.sql .

# Через WinSCP
# Хост: 213.171.26.123
# Логин: user1
# SSH-ключ: C:\Users\MI\.ssh\id_ed25519
# Путь: /home/user1/analytics-stack/database/backups/
```

## Перенос базы в другой проект

Инструкция по переносу:

1. Создать бэкап (см. выше).
2. Скачать бэкап на локальный ПК (см. выше).
3. В новом проекте:
   - запустить PostgreSQL;
   - создать базу данных;
   - восстановить из бэкапа.

Подробная инструкция в файле `database/backups/RESTORE_GUIDE.md`.

---

Автор: Артур (MartinMinart)