-- ============================================================
-- ЗАКАЗЫ (упрощенная версия)
-- ============================================================
DO $$
DECLARE
    i INTEGER;
    v_order_id INTEGER;
    v_branch_id INTEGER;
    v_customer_id INTEGER;
    v_employee_id INTEGER;
    v_order_date DATE;
    v_total DECIMAL(10,2);
    v_product_count INTEGER;
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_unit_price DECIMAL(10,2);
BEGIN
    -- Создаем заказы
    FOR i IN 1..10000 LOOP
        v_branch_id := 1 + floor(random() * 20)::int;
        v_customer_id := 1 + floor(random() * 3000)::int;
        v_employee_id := (SELECT employee_id FROM employees WHERE branch_id = v_branch_id ORDER BY random() LIMIT 1);
        v_order_date := DATE '2024-01-01' + (random() * 365)::int;
        
        INSERT INTO orders (
            branch_id, customer_id, employee_id, order_date, order_time,
            payment_method, status, total_amount, discount_amount
        ) VALUES (
            v_branch_id, v_customer_id, v_employee_id, v_order_date,
            (ARRAY['08:00','10:00','12:00','14:00','16:00','18:00','20:00'])[1 + floor(random() * 7)::int]::TIME,
            (ARRAY['card','cash','mobile'])[1 + floor(random() * 3)::int],
            (ARRAY['completed','completed','completed','processing'])[1 + floor(random() * 4)::int],
            0, 0
        ) RETURNING order_id INTO v_order_id;
        
        -- Товары в заказе
        v_product_count := 1 + floor(random() * 5)::int;
        v_total := 0;
        
        FOR j IN 1..v_product_count LOOP
            v_product_id := 1 + floor(random() * 65)::int;
            v_quantity := 1 + floor(random() * 3)::int;
            
            SELECT selling_price INTO v_unit_price FROM products WHERE product_id = v_product_id;
            
            INSERT INTO order_items (
                order_id, product_id, quantity, unit_price, discount_percent, total_price
            ) VALUES (
                v_order_id, v_product_id, v_quantity, v_unit_price, 0,
                v_unit_price * v_quantity
            );
            
            v_total := v_total + (v_unit_price * v_quantity);
        END LOOP;
        
        -- Обновляем сумму заказа
        UPDATE orders SET total_amount = v_total WHERE order_id = v_order_id;
        
        -- Обновляем клиента
        UPDATE customers 
        SET total_spent = total_spent + v_total,
            last_purchase_date = GREATEST(last_purchase_date, v_order_date)
        WHERE customer_id = v_customer_id;
    END LOOP;
END $$;

-- ============================================================
-- ПРОВЕРКА
-- ============================================================
SELECT 'orders' as name, COUNT(*) as count FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'customers_with_purchases', COUNT(DISTINCT customer_id) FROM orders WHERE customer_id IS NOT NULL;
