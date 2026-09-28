-- ============================================================
-- 10. ЗАКАЗЫ (20000 заказов) - ИСПРАВЛЕННАЯ ВЕРСИЯ
-- ============================================================
DO $$
DECLARE
    i INTEGER;
    v_order_id INTEGER;
    v_branch_id INTEGER;
    v_customer_id INTEGER;
    v_employee_id INTEGER;
    v_order_date DATE;
    v_order_time TIME;
    v_payment_method VARCHAR(50);
    v_status VARCHAR(20);
    v_total DECIMAL(10,2);
    v_discount DECIMAL(10,2);
    v_product_count INTEGER;
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_unit_price DECIMAL(10,2);
    v_discount_percent DECIMAL(5,2);
    v_hour INTEGER;
    v_minute INTEGER;
BEGIN
    FOR i IN 1..20000 LOOP
        -- Выбор филиала
        v_branch_id := 1 + floor(random() * 20)::int;
        
        -- Выбор клиента
        IF random() < 0.05 THEN
            v_customer_id := NULL;
        ELSE
            v_customer_id := 1 + floor(random() * 3000)::int;
        END IF;
        
        -- Выбор сотрудника
        v_employee_id := (SELECT employee_id FROM employees WHERE branch_id = v_branch_id ORDER BY random() LIMIT 1);
        
        -- Дата заказа (2024-2025)
        v_order_date := DATE '2024-01-01' + (random() * 550)::int;
        
        -- Время заказа (фиксированные часы)
        v_hour := (ARRAY[8,9,10,11,12,13,14,15,16,17,18,19,20,21])[1 + floor(random() * 14)::int];
        v_minute := floor(random() * 60)::int;
        v_order_time := (v_hour || ':' || v_minute || ':00')::TIME;
        
        -- Способ оплаты
        v_payment_method := (ARRAY['card','card','card','cash','mobile','sbp'])[1 + floor(random() * 6)::int];
        
        -- Статус
        v_status := CASE
            WHEN random() < 0.92 THEN 'completed'
            WHEN random() < 0.97 THEN 'processing'
            WHEN random() < 0.99 THEN 'cancelled'
            ELSE 'returned'
        END;
        
        -- Вставка заказа
        INSERT INTO orders (
            branch_id, customer_id, employee_id, order_date, order_time,
            payment_method, status, total_amount, discount_amount
        ) VALUES (
            v_branch_id, v_customer_id, v_employee_id, v_order_date, v_order_time,
            v_payment_method, v_status, 0, 0
        ) RETURNING order_id INTO v_order_id;
        
        -- Товары в заказе
        v_product_count := 1 + floor(random() * 8)::int;
        v_total := 0;
        v_discount := 0;
        
        FOR j IN 1..v_product_count LOOP
            v_product_id := 1 + floor(random() * 65)::int;
            v_quantity := 1 + floor(random() * 5)::int;
            
            SELECT selling_price INTO v_unit_price FROM products WHERE product_id = v_product_id;
            
            v_discount_percent := CASE
                WHEN random() < 0.2 THEN floor(random() * 15 + 1)::int
                ELSE 0
            END;
            
            INSERT INTO order_items (
                order_id, product_id, quantity, unit_price, discount_percent, total_price
            ) VALUES (
                v_order_id, 
                v_product_id,
                v_quantity,
                v_unit_price,
                v_discount_percent,
                v_unit_price * v_quantity * (1 - v_discount_percent / 100)
            );
            
            v_total := v_total + (v_unit_price * v_quantity * (1 - v_discount_percent / 100));
            v_discount := v_discount + (v_unit_price * v_quantity * (v_discount_percent / 100));
        END LOOP;
        
        -- Обновляем сумму заказа
        UPDATE orders 
        SET total_amount = v_total,
            discount_amount = v_discount
        WHERE order_id = v_order_id;
        
        -- Обновляем клиента
        IF v_customer_id IS NOT NULL THEN
            UPDATE customers 
            SET last_purchase_date = GREATEST(last_purchase_date, v_order_date),
                total_spent = total_spent + v_total
            WHERE customer_id = v_customer_id;
        END IF;
    END LOOP;
    
    -- Аномалии
    UPDATE orders 
    SET total_amount = total_amount * 8
    WHERE branch_id = 2 AND order_date BETWEEN '2024-12-20' AND '2025-01-10' 
    AND random() < 0.1;
    
    UPDATE orders 
    SET total_amount = total_amount * 0.15
    WHERE branch_id = 17 AND order_date BETWEEN '2024-06-01' AND '2024-06-30' 
    AND random() < 0.3;
    
    -- Проблемный клиент
    FOR i IN 1..30 LOOP
        INSERT INTO orders (
            branch_id, customer_id, employee_id, order_date, order_time,
            payment_method, status, total_amount, discount_amount
        ) VALUES (
            5, 1234, (SELECT employee_id FROM employees WHERE branch_id = 5 LIMIT 1),
            DATE '2024-01-01' + (i * 5)::int, '14:00:00'::TIME,
            'card', 'cancelled', 5000 + random() * 10000, 0
        );
    END LOOP;
END $$;

-- ============================================================
-- 11. ОБНОВЛЕНИЕ СТАТИСТИКИ КЛИЕНТОВ
-- ============================================================
UPDATE customers c
SET total_spent = COALESCE((
    SELECT SUM(total_amount)
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.status = 'completed'
), 0),
last_purchase_date = (
    SELECT MAX(order_date)
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.status = 'completed'
)
WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE customer_id IS NOT NULL);

-- ============================================================
-- 12. ИТОГОВАЯ ПРОВЕРКА
-- ============================================================
SELECT 'orders' as table_name, COUNT(*) as count FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'customers with purchases', COUNT(DISTINCT customer_id) FROM orders WHERE customer_id IS NOT NULL;
