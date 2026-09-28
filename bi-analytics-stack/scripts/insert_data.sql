-- Добавление филиалов
INSERT INTO branches (branch_name, city, address, manager_name, opening_date, status) VALUES
('Центральный', 'Москва', 'Тверская ул., 1', 'Иванов И.И.', '2020-01-15', 'active'),
('Северный', 'Москва', 'Ленинградское ш., 10', 'Петров П.П.', '2020-03-20', 'active'),
('Южный', 'Москва', 'Варшавское ш., 45', 'Сидоров С.С.', '2020-06-10', 'active'),
('Западный', 'Москва', 'Кутузовский пр., 78', 'Козлов К.К.', '2020-09-01', 'active'),
('Восточный', 'Москва', 'Щелковское ш., 23', 'Михайлов М.М.', '2021-01-15', 'active');

-- Добавление продуктов
INSERT INTO products (product_name, category, subcategory, unit_price, cost_price, stock_quantity) VALUES
('Молоко 1л', 'Молочные', 'Молоко', 89.90, 55.00, 100),
('Хлеб белый', 'Хлеб', 'Хлеб', 45.00, 25.00, 150),
('Яйца 10шт', 'Молочные', 'Яйца', 120.00, 75.00, 80),
('Масло сливочное 200г', 'Молочные', 'Масло', 230.00, 140.00, 50),
('Сметана 400г', 'Молочные', 'Сметана', 150.00, 90.00, 60),
('Колбаса вареная', 'Мясные', 'Колбасы', 350.00, 220.00, 40),
('Сыр голландский 200г', 'Молочные', 'Сыры', 280.00, 170.00, 45),
('Гречка 1кг', 'Бакалея', 'Крупы', 120.00, 70.00, 120),
('Рис 1кг', 'Бакалея', 'Крупы', 110.00, 65.00, 110),
('Макароны 500г', 'Бакалея', 'Макароны', 85.00, 45.00, 130),
('Курица 1кг', 'Мясные', 'Птица', 280.00, 170.00, 50),
('Говядина 1кг', 'Мясные', 'Мясо', 450.00, 280.00, 30),
('Яблоки 1кг', 'Овощи-фрукты', 'Фрукты', 130.00, 75.00, 90),
('Бананы 1кг', 'Овощи-фрукты', 'Фрукты', 90.00, 50.00, 85),
('Картофель 1кг', 'Овощи-фрукты', 'Овощи', 65.00, 35.00, 150),
('Морковь 1кг', 'Овощи-фрукты', 'Овощи', 55.00, 30.00, 130),
('Сахар 1кг', 'Бакалея', 'Сахар', 70.00, 40.00, 140),
('Мука 1кг', 'Бакалея', 'Мука', 75.00, 42.00, 120),
('Чай 100г', 'Чай-кофе', 'Чай', 180.00, 100.00, 45),
('Кофе 250г', 'Чай-кофе', 'Кофе', 350.00, 200.00, 35);

-- Добавление клиентов
INSERT INTO customers (first_name, last_name, email, phone, city, registration_date, loyalty_status) VALUES
('Алексей', 'Смирнов', 'alex@example.com', '+7(999)111-11-11', 'Москва', '2023-01-10', 'gold'),
('Елена', 'Иванова', 'elena@example.com', '+7(999)222-22-22', 'Москва', '2023-02-15', 'silver'),
('Михаил', 'Кузнецов', 'mihail@example.com', '+7(999)333-33-33', 'Москва', '2023-03-20', 'regular'),
('Ольга', 'Попова', 'olga@example.com', '+7(999)444-44-44', 'Москва', '2023-04-25', 'gold'),
('Дмитрий', 'Васильев', 'dmitry@example.com', '+7(999)555-55-55', 'Москва', '2023-05-30', 'silver'),
('Анна', 'Петрова', 'anna@example.com', '+7(999)666-66-66', 'Москва', '2023-06-10', 'regular'),
('Игорь', 'Соколов', 'igor@example.com', '+7(999)777-77-77', 'Москва', '2023-07-15', 'gold'),
('Татьяна', 'Михайлова', 'tatiana@example.com', '+7(999)888-88-88', 'Москва', '2023-08-20', 'silver'),
('Владимир', 'Новиков', 'vladimir@example.com', '+7(999)999-99-99', 'Москва', '2023-09-25', 'regular'),
('Светлана', 'Федорова', 'svetlana@example.com', '+7(999)000-00-00', 'Москва', '2023-10-30', 'gold');

-- Добавление заказов (генерируем с помощью запроса)
DO $$
DECLARE
    i INTEGER;
    branch_id INTEGER;
    customer_id INTEGER;
    order_id INTEGER;
    product_id INTEGER;
    quantity INTEGER;
    price DECIMAL(10,2);
    total DECIMAL(10,2);
BEGIN
    FOR i IN 1..200 LOOP
        -- Случайный филиал (1-5)
        branch_id := (SELECT floor(random() * 5 + 1)::int);
        -- Случайный клиент (1-10)
        customer_id := (SELECT floor(random() * 10 + 1)::int);
        
        -- Вставка заказа
        INSERT INTO orders (branch_id, customer_id, order_date, payment_method, status)
        VALUES (
            branch_id,
            customer_id,
            DATE '2024-01-01' + (random() * 365)::int,
            (ARRAY['cash', 'card', 'mobile'])[floor(random() * 3 + 1)],
            (ARRAY['completed', 'completed', 'completed', 'processing'])[floor(random() * 4 + 1)]
        )
        RETURNING order_id INTO order_id;
        
        -- Количество товаров в заказе (1-5)
        FOR j IN 1..(SELECT floor(random() * 5 + 1)::int) LOOP
            product_id := (SELECT floor(random() * 20 + 1)::int);
            quantity := (SELECT floor(random() * 10 + 1)::int);
            price := (SELECT unit_price FROM products WHERE product_id = product_id);
            
            INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
            VALUES (
                order_id,
                product_id,
                quantity,
                price,
                price * quantity
            );
            
            -- Обновляем общую сумму заказа
            UPDATE orders SET total_amount = (
                SELECT SUM(total_price) FROM order_items WHERE order_id = order_id
            ) WHERE order_id = order_id;
        END LOOP;
    END LOOP;
END $$;

-- Добавление еще клиентов (чтобы было больше данных)
INSERT INTO customers (first_name, last_name, email, phone, city, registration_date, loyalty_status)
SELECT 
    (ARRAY['Андрей', 'Мария', 'Сергей', 'Наталья', 'Павел', 'Ирина', 'Александр', 'Ксения'])[floor(random() * 8 + 1)],
    (ARRAY['Петров', 'Сидоров', 'Козлов', 'Морозов', 'Волков', 'Лебедев', 'Соколов', 'Крылов'])[floor(random() * 8 + 1)],
    md5(random()::text) || '@example.com',
    '+7(999)' || floor(random() * 100000000 + 10000000)::text,
    'Москва',
    DATE '2023-01-01' + (random() * 365)::int,
    (ARRAY['gold', 'silver', 'regular'])[floor(random() * 3 + 1)]
FROM generate_series(1, 40);
