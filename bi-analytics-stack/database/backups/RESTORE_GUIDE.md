# 📥 Инструкция по переносу базы данных

## Скачать бэкап на локальный ПК

```bash
scp user1@213.171.26.123:~/analytics-stack/database/backups/analytics_db_new_*.sql .

### Восстановить в новом проекте

# 1. Запустить PostgreSQL
docker run -d --name postgres -e POSTGRES_USER=analytics -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} -e POSTGRES_DB=analytics_db_new -p 5432:5432 postgres:15-alpine

# 2. Скопировать бэкап
docker cp analytics_db_new_backup.sql postgres:/tmp/

# 3. Восстановить
docker exec -i postgres psql -U analytics -d analytics_db_new < /tmp/analytics_db_new_backup.sql
Проверить


docker exec -it postgres psql -U analytics -d analytics_db_new -c "
SELECT 
    (SELECT COUNT(*) FROM products) as products,
    (SELECT COUNT(*) FROM customers) as customers,
    (SELECT COUNT(*) FROM sales) as sales,
    (SELECT ROUND(SUM(total_amount)::numeric, 0) FROM sales WHERE status = 'completed') as revenue;
"
