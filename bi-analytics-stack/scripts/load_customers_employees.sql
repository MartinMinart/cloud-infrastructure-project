-- ============================================================
-- СОТРУДНИКИ (140 человек)
-- ============================================================
DO $$
DECLARE
    v_branch_id INTEGER;
    v_first_names TEXT[] := ARRAY['Анна','Мария','Сергей','Иван','Ольга','Дмитрий','Елена','Павел','Александра','Михаил'];
    v_last_names TEXT[] := ARRAY['Петрова','Иванов','Сидоров','Смирнова','Козлова','Волков','Морозова','Лебедев','Соколова','Крылов'];
    v_positions TEXT[] := ARRAY['кассир','кассир','кассир','кассир','кассир','кассир','мерчендайзер','мерчендайзер','менеджер','директор'];
BEGIN
    FOR v_branch_id IN 1..20 LOOP
        FOR i IN 1..7 LOOP
            INSERT INTO employees (
                branch_id,
                first_name,
                last_name,
                position,
                hire_date,
                salary,
                phone,
                email
            ) VALUES (
                v_branch_id,
                v_first_names[1 + floor(random() * 10)::int],
                v_last_names[1 + floor(random() * 10)::int],
                v_positions[1 + floor(random() * 10)::int],
                DATE '2020-01-01' + (random() * 800)::int,
                (ARRAY[45000,48000,52000,55000,58000,62000,70000,85000,90000,120000])[1 + floor(random() * 10)::int],
                '+7(9' || floor(random() * 100 + 10)::text || ')' || floor(random() * 10000000 + 1000000)::text,
                'emp' || i || '@branch' || v_branch_id || '.local'
            );
        END LOOP;
    END LOOP;
END $$;

-- ============================================================
-- КЛИЕНТЫ (3000)
-- ============================================================
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..3000 LOOP
        INSERT INTO customers (
            first_name,
            last_name,
            email,
            phone,
            city,
            address,
            registration_date,
            loyalty_status,
            loyalty_card_number
        ) VALUES (
            (ARRAY['Александр','Михаил','Иван','Дмитрий','Сергей','Андрей','Алексей','Владимир','Николай','Евгений','Анна','Елена','Ольга','Наталья','Татьяна','Мария'])[1 + floor(random() * 16)::int],
            (ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Васильев','Соколов','Михайлов','Новиков','Федоров','Морозов','Волков'])[1 + floor(random() * 13)::int],
            'user' || i || '@example.com',
            '+7(9' || floor(random() * 100 + 10)::text || ')' || floor(random() * 10000000 + 1000000)::text,
            (ARRAY['Москва','Санкт-Петербург','Казань','Екатеринбург','Новосибирск'])[1 + floor(random() * 5)::int],
            'ул. ' || (ARRAY['Ленина','Пушкина','Гагарина','Садовая'])[1 + floor(random() * 4)::int] || ', д. ' || floor(random() * 100 + 1)::text,
            DATE '2022-01-01' + (random() * 900)::int,
            (ARRAY['regular','regular','regular','regular','silver','gold'])[1 + floor(random() * 6)::int],
            'LC' || floor(random() * 100000000)::text
        );
    END LOOP;
END $$;

-- ============================================================
-- ОСТАТКИ (inventory)
-- ============================================================
INSERT INTO inventory (branch_id, product_id, stock_quantity, reserved_quantity, last_inventory_date, min_stock, max_stock)
SELECT 
    b.branch_id,
    p.product_id,
    floor(random() * (p.max_stock - p.min_stock) + p.min_stock)::int,
    0,
    CURRENT_DATE - floor(random() * 30)::int,
    p.min_stock,
    p.max_stock
FROM branches b
CROSS JOIN products p;

-- ============================================================
-- ПРОВЕРКА
-- ============================================================
SELECT 'employees' as name, COUNT(*) as count FROM employees
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory;
