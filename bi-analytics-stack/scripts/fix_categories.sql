-- Создай категории если таблица пустая
INSERT INTO Categories (category_name, description)
SELECT DISTINCT 'Продукты питания', 'Основная категория'
WHERE NOT EXISTS (SELECT 1 FROM Categories);

INSERT INTO Categories (category_name, parent_category_id, description)
SELECT 'Молочные продукты', 1, 'Молочная продукция'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Молочные продукты');

INSERT INTO Categories (category_name, parent_category_id, description)
SELECT 'Мясные продукты', 1, 'Мясо и мясные изделия'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Мясные продукты');

INSERT INTO Categories (category_name, parent_category_id, description)
SELECT 'Хлеб-выпечка', 1, 'Хлеб и выпечка'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Хлеб-выпечка');

INSERT INTO Categories (category_name, parent_category_id, description)
SELECT 'Овощи-фрукты', 1, 'Свежие овощи и фрукты'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Овощи-фрукты');

INSERT INTO Categories (category_name, parent_category_id, description)
SELECT 'Бакалея', 1, 'Крупы, макароны, консервы'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Бакалея');

INSERT INTO Categories (category_name, parent_category_id, description)
SELECT 'Напитки', NULL, 'Все напитки'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Напитки');

INSERT INTO Categories (category_name, parent_category_id, description)
SELECT 'Сладости-снеки', 1, 'Сладости и снеки'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Сладости-снеки');

INSERT INTO Categories (category_name, parent_category_id, description)
SELECT 'Бытовая химия', NULL, 'Средства для дома'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Бытовая химия');
