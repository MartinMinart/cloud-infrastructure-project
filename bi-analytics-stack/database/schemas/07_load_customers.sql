-- ============================================================
-- ЗАГРУЗКА КЛИЕНТОВ (10000)
-- ============================================================

DO $$
DECLARE
    i INTEGER;
    v_first_name TEXT;
    v_last_name TEXT;
    v_city TEXT;
BEGIN
    FOR i IN 1..10000 LOOP
        v_first_name := (ARRAY['Александр','Михаил','Иван','Дмитрий','Сергей','Андрей','Алексей','Владимир','Николай','Евгений',
                               'Анна','Елена','Ольга','Наталья','Татьяна','Мария','Екатерина','Ирина','Светлана','Юлия',
                               'Анастасия','Виктория','Дарья','Алина','Полина'])[1 + floor(random() * 25)::int];
        
        v_last_name := (ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Васильев','Соколов','Михайлов','Новиков',
                              'Федоров','Морозов','Волков','Алексеев','Лебедев','Семенов','Егоров','Павлов','Козлов','Степанов',
                              'Орлов','Макаров','Андреев','Захаров','Борисов'])[1 + floor(random() * 25)::int];
        
        v_city := CASE 
            WHEN random() < 0.35 THEN 'Москва'
            WHEN random() < 0.60 THEN 'Санкт-Петербург'
            WHEN random() < 0.75 THEN 'Казань'
            WHEN random() < 0.87 THEN 'Екатеринбург'
            WHEN random() < 0.95 THEN 'Новосибирск'
            ELSE 'Нижний Новгород'
        END;
        
        INSERT INTO Customers (
            first_name,
            last_name,
            email,
            phone,
            city,
            address,
            registration_date,
            loyalty_status,
            loyalty_card_number,
            total_spent,
            last_purchase_date,
            customer_segment
        ) VALUES (
            v_first_name,
            v_last_name,
            lower(v_first_name) || '.' || lower(v_last_name) || i::text || '@example.com',
            '+7(9' || floor(random() * 100 + 10)::text || ')' || LPAD(floor(random() * 10000000)::text, 7, '0'),
            v_city,
            'ул. ' || (ARRAY['Ленина','Пушкина','Гагарина','Садовая','Мира','Кирова','Советская','Молодежная'])[1 + floor(random() * 8)::int] || 
            ', д. ' || floor(random() * 150 + 1)::text,
            DATE '2022-01-01' + (random() * 1000)::int,
            CASE 
                WHEN random() < 0.10 THEN 'gold'
                WHEN random() < 0.35 THEN 'silver'
                ELSE 'regular'
            END,
            'LC' || LPAD(floor(random() * 1000000000)::text, 10, '0'),
            0,
            NULL,
            CASE 
                WHEN random() < 0.05 THEN 'VIP'
                WHEN random() < 0.20 THEN 'Premium'
                ELSE 'Regular'
            END
        );
    END LOOP;
END $$;

SELECT 'customers' as table_name, COUNT(*) as count FROM Customers;
