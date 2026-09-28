-- ============================================================
-- БЫСТРАЯ ЗАГРУЗКА ПРОДАЖ (10,000 заказов) ДЛЯ analytics_db_new
-- ============================================================

-- 1. Генерируем заголовки заказов
INSERT INTO Sales (
    branch_id, 
    customer_id, 
    employee_id, 
    sale_date, 
    sale_time,
    payment_method, 
    status, 
    total_amount, 
    discount_amount
)
SELECT 
    -- Случайный филиал (1-30)
    1 + floor(random() * 30)::int,
    
    -- Случайный клиент (иногда NULL - 5% случаев)
    CASE WHEN random() < 0.05 THEN NULL 
         ELSE 1 + floor(random() * 10000)::int 
    END,
    
    -- Случайный сотрудник
    1 + floor(random() * 210)::int,
    
    -- Дата: 2024-01-01 + случайные дни (до сегодня)
    DATE '2024-01-01' + floor(random() * (CURRENT_DATE - DATE '2024-01-01'))::int,
    
    -- Время: пики в 8-10, 12-14, 18-20
    (ARRAY[
        '08:00','09:00','10:00',
        '12:00','13:00','14:00',
        '18:00','19:00','20:00',
        '11:00','15:00','16:00','17:00','21:00'
    ])[1 + floor(random() * 14)::int]::TIME,
    
    -- Способ оплаты
    (ARRAY['card','card','card','card','cash','mobile','sbp'])[1 + floor(random() * 7)::int],
    
    -- Статус: 93% completed, 4% processing, 2% cancelled, 1% returned
    CASE 
        WHEN random() < 0.93 THEN 'completed'
        WHEN random() < 0.97 THEN 'processing'
        WHEN random() < 0.99 THEN 'cancelled'
        ELSE 'returned'
    END,
    
    -- Временно 0 (обновим после добавления позиций)
    0, 0
    
FROM generate_series(1, 10000);

-- 2. Добавляем позиции заказов (1-5 товаров на заказ)
INSERT INTO Sale_Details (
    sale_id, 
    product_id, 
    quantity, 
    unit_price, 
    discount_percent, 
    total_price
)
SELECT 
    s.sale_id,
    1 + floor(random() * 2500)::int,
    1 + floor(random() * 5)::int,
    p.selling_price,
    CASE WHEN random() < 0.15 THEN 5 + floor(random() * 16)::int ELSE 0 END,
    p.selling_price * (1 + floor(random() * 5)::int) * 
    (1 - CASE WHEN random() < 0.15 THEN (5 + floor(random() * 16)::int) / 100.0 ELSE 0 END)
FROM Sales s
CROSS JOIN LATERAL (
    SELECT selling_price FROM Products 
    WHERE product_id = 1 + floor(random() * 2500)::int
    LIMIT 1
) p;

-- 3. Обновляем суммы заказов
UPDATE Sales s
SET 
    total_amount = (
        SELECT COALESCE(SUM(total_price), 0)
        FROM Sale_Details sd
        WHERE sd.sale_id = s.sale_id
    ),
    discount_amount = (
        SELECT COALESCE(SUM(unit_price * quantity * discount_percent / 100), 0)
        FROM Sale_Details sd
        WHERE sd.sale_id = s.sale_id
    );

-- 4. Обновляем клиентов
UPDATE Customers c
SET 
    total_spent = (
        SELECT COALESCE(SUM(total_amount), 0)
        FROM Sales s
        WHERE s.customer_id = c.customer_id
        AND s.status = 'completed'
    ),
    last_purchase_date = (
        SELECT MAX(sale_date)
        FROM Sales s
        WHERE s.customer_id = c.customer_id
        AND s.status = 'completed'
    );

-- 5. Добавляем аномалии
-- Всплеск продаж в филиале №2 (декабрь 2024)
UPDATE Sales
SET total_amount = total_amount * 8
WHERE branch_id = 2
AND sale_date BETWEEN '2024-12-20' AND '2025-01-10'
AND random() < 0.15;

-- Падение продаж в филиале №17 (июнь 2025)
UPDATE Sales
SET total_amount = total_amount * 0.15
WHERE branch_id = 17
AND sale_date BETWEEN '2025-06-01' AND '2025-06-30'
AND random() < 0.3;

-- 6. Добавляем пол клиента
ALTER TABLE Customers ADD COLUMN IF NOT EXISTS gender VARCHAR(10);
UPDATE Customers 
SET gender = CASE 
    WHEN random() < 0.48 THEN 'Мужской'
    ELSE 'Женский'
END
WHERE gender IS NULL;

-- 7. ПРОВЕРКА
SELECT 
    'Sales' as table_name,
    COUNT(*) as count
FROM Sales
UNION ALL
SELECT 
    'Sale_Details',
    COUNT(*)
FROM Sale_Details
UNION ALL
SELECT 
    'Customers with purchases',
    COUNT(DISTINCT customer_id)
FROM Sales
WHERE customer_id IS NOT NULL 
AND status = 'completed';

-- Статистика по годам
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    COUNT(*) as orders,
    ROUND(SUM(total_amount)::numeric, 0) as revenue,
    ROUND(AVG(total_amount)::numeric, 2) as avg_order
FROM Sales
WHERE status = 'completed'
GROUP BY EXTRACT(YEAR FROM sale_date)
ORDER BY year;

-- Статистика по месяцам (последние 6)
SELECT 
    TO_CHAR(sale_date, 'YYYY-MM') as month,
    COUNT(*) as orders,
    ROUND(SUM(total_amount)::numeric, 0) as revenue
FROM Sales
WHERE status = 'completed'
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY month DESC
LIMIT 6;

SELECT '✅ Загрузка завершена!' as status;
