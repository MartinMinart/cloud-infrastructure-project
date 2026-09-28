# База данных аналитической платформы

## Файл: analytics_db_backup_20260825.sql

**Дата создания:** 2026-08-25  
**Размер:** 3.8 MB  
**СУБД:** PostgreSQL 15  
**Кодировка:** UTF-8  

## Содержимое базы данных

| Таблица | Записей | Описание |
|---------|---------|----------|
| Categories | 35 | Категории товаров |
| Suppliers | 10 | Поставщики |
| Products | 65 | Товары |
| Branches | 20 | Филиалы/магазины |
| Employees | 140 | Сотрудники |
| Customers | 3000 | Клиенты |
| Sales | 10000 | Продажи/заказы |
| Sale_Details | 30082 | Детали продаж |
| Supplies | 200 | Поставки |
| Supply_Details | 1262 | Детали поставок |
| Inventory | 1300 | Остатки товаров |
| Sections | 0 | Отделы магазина |
| Promotions | 0 | Промо-акции |
| Work_Schedule | 0 | График работы |

## Как восстановить базу

### Вариант 1: Восстановить в текущем контейнере
```bash
# Создать новую пустую базу
docker exec analytics-postgres psql -U analytics -c "DROP DATABASE IF EXISTS analytics_db;"
docker exec analytics-postgres psql -U analytics -c "CREATE DATABASE analytics_db;"

# Восстановить из бэкапа
docker exec -i analytics-postgres psql -U analytics -d analytics_db < database/backups/analytics_db_backup_20260825.sql
Вариант 2: Восстановить в новом проекте
bash
# 1. Запустить PostgreSQL в новом проекте
docker run -d --name new_postgres -e POSTGRES_USER=analytics -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} -e POSTGRES_DB=analytics_db -p 5432:5432 postgres:15-alpine

# 2. Скопировать бэкап в контейнер
docker cp database/backups/analytics_db_backup_20260825.sql new_postgres:/tmp/

# 3. Восстановить
docker exec -i new_postgres psql -U analytics -d analytics_db < database/backups/analytics_db_backup_20260825.sql
Вариант 3: Скачать на локальный ПК
bash
# Из терминала VS Code (на devops-main):
scp user1@213.171.26.123:~/analytics-stack/database/backups/analytics_db_backup_20260825.sql .

# Или через WinSCP/FileZilla
# Хост: 213.171.26.123
# Логин: user1
# SSH-ключ: C:\Users\MI\.ssh\id_ed25519
# Путь: /home/user1/analytics-stack/database/backups/
ER-диаграмма
text
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Suppliers  │─────│   Products  │─────│  Categories │
│  supplier_id│     │  product_id │     │ category_id │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           │
                    ┌──────▼──────┐
                    │   Inventory │
                    │  branch_id  │
                    │  product_id │
                    └─────────────┘
                           │
                    ┌──────▼──────┐     ┌─────────────┐
                    │ Sale_Details│─────│    Sales    │
                    │ sale_detail │     │   sale_id   │
                    │   sale_id   │     │  branch_id  │
                    │  product_id │     │ customer_id │
                    └─────────────┘     └─────────────┘
                           │                  │
                    ┌──────▼──────┐           │
                    │   Branches  │◀──────────┘
                    │  branch_id  │
                    └─────────────┘
                           │
                           │
                    ┌──────▼──────┐     ┌─────────────┐
                    │  Employees  │     │  Customers  │
                    │ employee_id │     │ customer_id │
                    │  branch_id  │     └─────────────┘
                    └─────────────┘
Связи между таблицами
Таблица 1	Таблица 2	Связь
Categories → Products	category_id → category_id	1:N
Suppliers → Products	supplier_id → supplier_id	1:N
Branches → Sales	branch_id → branch_id	1:N
Customers → Sales	customer_id → customer_id	1:N
Employees → Sales	employee_id → employee_id	1:N
Sales → Sale_Details	sale_id → sale_id	1:N
Products → Sale_Details	product_id → product_id	1:N
Branches → Inventory	branch_id → branch_id	1:N
Products → Inventory	product_id → product_id	1:N
Suppliers → Supplies	supplier_id → supplier_id	1:N
Branches → Supplies	branch_id → branch_id	1:N
Supplies → Supply_Details	supply_id → supply_id	1:N
Products → Supply_Details	product_id → product_id	1:N
Примеры запросов
Выручка по месяцам
sql
SELECT 
    DATE_TRUNC('month', sale_date) as month,
    COUNT(*) as orders,
    ROUND(SUM(total_amount)::numeric, 2) as revenue
FROM Sales
WHERE status = 'completed'
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY month;
Топ-10 товаров по выручке
sql
SELECT 
    p.product_name,
    c.category_name,
    COUNT(sd.sale_detail_id) as sales_count,
    ROUND(SUM(sd.total_price)::numeric, 2) as revenue
FROM Sale_Details sd
JOIN Products p ON sd.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY p.product_name, c.category_name
ORDER BY revenue DESC
LIMIT 10;
