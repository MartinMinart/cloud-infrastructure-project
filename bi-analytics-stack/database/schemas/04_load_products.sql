-- ============================================================
-- ЗАГРУЗКА ТОВАРОВ (2500+)
-- ============================================================

DO $$
DECLARE
    v_category_id INTEGER;
    v_supplier_id INTEGER;
    v_product_name TEXT;
    v_brand TEXT;
    v_purchase_price DECIMAL(10,2);
    v_selling_price DECIMAL(10,2);
    v_weight INTEGER;
    v_shelf_life INTEGER;
    i INTEGER;
    
    -- Массивы для генерации названий
    v_product_names TEXT[] := ARRAY[
        'Молоко', 'Кефир', 'Сметана', 'Творог', 'Йогурт', 'Ряженка', 'Сливки', 'Масло', 'Сыр', 'Брынза',
        'Хлеб', 'Батон', 'Булочка', 'Круассан', 'Пирожок', 'Пирог', 'Кекс', 'Печенье', 'Пряник', 'Вафля',
        'Колбаса', 'Сосиски', 'Сардельки', 'Ветчина', 'Бекон', 'Шинка', 'Рулет', 'Паштет', 'Зельц', 'Сало',
        'Курица', 'Индейка', 'Утка', 'Гусь', 'Перепелка', 'Цыпленок', 'Окорок', 'Грудка', 'Бедро', 'Крыло',
        'Говядина', 'Телятина', 'Свинина', 'Баранина', 'Конина', 'Оленина', 'Фарш', 'Антрекот', 'Ромштекс', 'Эскалоп',
        'Яблоки', 'Груши', 'Апельсины', 'Мандарины', 'Лимоны', 'Бананы', 'Виноград', 'Персики', 'Абрикосы', 'Сливы',
        'Картофель', 'Морковь', 'Лук', 'Чеснок', 'Капуста', 'Свекла', 'Огурцы', 'Помидоры', 'Перец', 'Баклажаны',
        'Гречка', 'Рис', 'Пшено', 'Овсянка', 'Манка', 'Перловка', 'Ячка', 'Кускус', 'Булгур', 'Киноа',
        'Макароны', 'Спагетти', 'Вермишель', 'Лапша', 'Ракушки', 'Перья', 'Рожки', 'Фетучини', 'Пенне', 'Фузилли',
        'Масло', 'Майонез', 'Кетчуп', 'Горчица', 'Хрен', 'Аджика', 'Соус', 'Уксус', 'Лимонная кислота', 'Сода',
        'Чай', 'Кофе', 'Какао', 'Цикорий', 'Шиповник', 'Мята', 'Ромашка', 'Иван-чай', 'Каркаде', 'Матча'
    ];
    
    v_brands TEXT[] := ARRAY[
        'Danone', 'Valio', 'Parmalat', 'Efko', 'Morozko', 'Savushkin', 'Белый Город', 'Вкуснотеево', 'Простоквашино',
        'Макфа', 'Увелка', 'Мистраль', 'Агрокомплекс', 'Сады Кубани', 'Хлебозавод', 'Пекарня', 'Мираторг', 'Микоян',
        'Coca-Cola', 'Nestle', 'Jardin', 'Greenfield', 'Lipton', 'Красный Октябрь', 'Mondelez', 'Milka', 'Alpen Gold',
        'Procter & Gamble', 'Essity', 'Nivea', 'Tide', 'Fairy', 'Zewa', 'Союзпищепром', 'Рыбный мир', 'Фрукт-Трейд'
    ];
    
    v_categories_ids INTEGER[];
    v_suppliers_ids INTEGER[];
BEGIN
    -- Получаем ID категорий и поставщиков
    SELECT ARRAY(SELECT category_id FROM Categories WHERE parent_category_id IS NOT NULL ORDER BY category_id) INTO v_categories_ids;
    SELECT ARRAY(SELECT supplier_id FROM Suppliers ORDER BY supplier_id) INTO v_suppliers_ids;
    
    -- Генерируем 2500 товаров
    FOR i IN 1..2500 LOOP
        -- Выбираем случайную категорию
        v_category_id := v_categories_ids[1 + floor(random() * array_length(v_categories_ids, 1))::int];
        
        -- Выбираем случайного поставщика
        v_supplier_id := v_suppliers_ids[1 + floor(random() * array_length(v_suppliers_ids, 1))::int];
        
        -- Генерируем название товара
        v_product_name := v_product_names[1 + floor(random() * array_length(v_product_names, 1))::int];
        
        -- Добавляем уникальный номер к названию (чтобы товары различались)
        IF i > 100 THEN
            v_product_name := v_product_name || ' ' || (1 + floor(random() * 50))::text;
        END IF;
        
        -- Бренд (иногда без бренда)
        IF random() < 0.7 THEN
            v_brand := v_brands[1 + floor(random() * array_length(v_brands, 1))::int];
        ELSE
            v_brand := NULL;
        END IF;
        
        -- Цены (в зависимости от категории)
        IF v_category_id IN (SELECT category_id FROM Categories WHERE category_name IN ('Молоко', 'Кефир-йогурт', 'Сметана')) THEN
            v_purchase_price := 30 + random() * 150;
            v_selling_price := v_purchase_price * 1.3 + random() * 20;
            v_weight := 200 + floor(random() * 800);
            v_shelf_life := 5 + floor(random() * 20);
        ELSIF v_category_id IN (SELECT category_id FROM Categories WHERE category_name IN ('Сыр', 'Творог')) THEN
            v_purchase_price := 100 + random() * 400;
            v_selling_price := v_purchase_price * 1.25 + random() * 30;
            v_weight := 100 + floor(random() * 300);
            v_shelf_life := 10 + floor(random() * 50);
        ELSIF v_category_id IN (SELECT category_id FROM Categories WHERE category_name IN ('Колбасы', 'Мясо', 'Птица')) THEN
            v_purchase_price := 150 + random() * 500;
            v_selling_price := v_purchase_price * 1.3 + random() * 30;
            v_weight := 200 + floor(random() * 800);
            v_shelf_life := 3 + floor(random() * 15);
        ELSIF v_category_id IN (SELECT category_id FROM Categories WHERE category_name IN ('Овощи', 'Фрукты', 'Зелень')) THEN
            v_purchase_price := 20 + random() * 200;
            v_selling_price := v_purchase_price * 1.25 + random() * 15;
            v_weight := 500 + floor(random() * 1000);
            v_shelf_life := 3 + floor(random() * 30);
        ELSIF v_category_id IN (SELECT category_id FROM Categories WHERE category_name IN ('Крупы', 'Макароны', 'Сахар-мука')) THEN
            v_purchase_price := 20 + random() * 150;
            v_selling_price := v_purchase_price * 1.2 + random() * 15;
            v_weight := 400 + floor(random() * 1600);
            v_shelf_life := 180 + floor(random() * 200);
        ELSIF v_category_id IN (SELECT category_id FROM Categories WHERE category_name IN ('Напитки', 'Газировка', 'Соки')) THEN
            v_purchase_price := 25 + random() * 150;
            v_selling_price := v_purchase_price * 1.3 + random() * 15;
            v_weight := 250 + floor(random() * 1250);
            v_shelf_life := 90 + floor(random() * 180);
        ELSIF v_category_id IN (SELECT category_id FROM Categories WHERE category_name IN ('Шоколад', 'Печенье', 'Конфеты')) THEN
            v_purchase_price := 40 + random() * 200;
            v_selling_price := v_purchase_price * 1.3 + random() * 20;
            v_weight := 50 + floor(random() * 200);
            v_shelf_life := 90 + floor(random() * 180);
        ELSE
            v_purchase_price := 30 + random() * 250;
            v_selling_price := v_purchase_price * 1.25 + random() * 20;
            v_weight := 100 + floor(random() * 900);
            v_shelf_life := 30 + floor(random() * 180);
        END IF;
        
        -- Округляем цены
        v_purchase_price := ROUND(v_purchase_price / 0.5) * 0.5;
        v_selling_price := ROUND(v_selling_price / 0.5) * 0.5;
        
        -- Вставляем товар
        INSERT INTO Products (
            product_name,
            category_id,
            supplier_id,
            brand,
            unit,
            barcode,
            shelf_life_days,
            weight_grams,
            purchase_price,
            selling_price,
            min_stock,
            max_stock,
            is_active
        ) VALUES (
            v_product_name || ' ' || i::text,
            v_category_id,
            v_supplier_id,
            v_brand,
            CASE WHEN random() < 0.8 THEN 'шт' ELSE 'кг' END,
            '460' || LPAD(floor(random() * 1000000000000)::text, 12, '0'),
            v_shelf_life,
            v_weight,
            v_purchase_price,
            v_selling_price,
            5 + floor(random() * 20)::int,
            50 + floor(random() * 150)::int,
            random() > 0.05
        );
        
        -- Прогресс каждые 500 записей
        IF i % 500 = 0 THEN
            RAISE NOTICE 'Загружено % товаров', i;
        END IF;
    END LOOP;
END $$;

-- Проверка загрузки
SELECT 'products' as table_name, COUNT(*) as count FROM Products;
