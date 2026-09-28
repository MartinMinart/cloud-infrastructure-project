-- ============================================================
-- СХЕМА БАЗЫ ДАННЫХ ДЛЯ СЕТИ СУПЕРМАРКЕТОВ
-- ============================================================

-- 1. КАТЕГОРИИ ТОВАРОВ
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INTEGER REFERENCES categories(category_id),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. ПОСТАВЩИКИ
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(200),
    address TEXT,
    tax_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. ПРОДУКТЫ (ТОВАРЫ)
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES categories(category_id),
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    brand VARCHAR(100),
    unit VARCHAR(20) DEFAULT 'шт',
    barcode VARCHAR(50),
    shelf_life_days INTEGER, -- срок годности в днях
    weight_grams INTEGER, -- вес в граммах
    purchase_price DECIMAL(10,2), -- закупочная цена
    selling_price DECIMAL(10,2), -- розничная цена
    min_stock INTEGER DEFAULT 10, -- минимальный остаток
    max_stock INTEGER DEFAULT 100, -- максимальный остаток
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. ФИЛИАЛЫ (МАГАЗИНЫ)
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    phone VARCHAR(20),
    manager_name VARCHAR(100),
    opening_date DATE,
    store_area_sqm INTEGER, -- площадь в кв.м.
    format VARCHAR(50), -- формат: у дома, средний, суперстор
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. СОТРУДНИКИ
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES branches(branch_id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    position VARCHAR(50), -- кассир, мерчендайзер, менеджер, директор
    hire_date DATE,
    salary DECIMAL(10,2),
    phone VARCHAR(20),
    email VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 6. КЛИЕНТЫ
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(20),
    city VARCHAR(100),
    address TEXT,
    registration_date DATE,
    loyalty_status VARCHAR(20) DEFAULT 'regular', -- gold, silver, regular
    loyalty_card_number VARCHAR(50),
    total_spent DECIMAL(10,2) DEFAULT 0,
    last_purchase_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 7. ОТДЕЛЫ МАГАЗИНА
CREATE TABLE sections (
    section_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES branches(branch_id),
    section_name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES categories(category_id),
    section_area_sqm INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 8. ЗАКАЗЫ (ПРОДАЖИ)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES branches(branch_id),
    customer_id INTEGER REFERENCES customers(customer_id),
    employee_id INTEGER REFERENCES employees(employee_id),
    order_date DATE NOT NULL,
    order_time TIME,
    total_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(50), -- cash, card, mobile, sbp
    status VARCHAR(20) DEFAULT 'completed', -- completed, processing, cancelled, returned
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 9. ПОЗИЦИИ ЗАКАЗА
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2),
    discount_percent DECIMAL(5,2) DEFAULT 0,
    total_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 10. ПОСТАВКИ ТОВАРОВ
CREATE TABLE supplies (
    supply_id SERIAL PRIMARY KEY,
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    branch_id INTEGER REFERENCES branches(branch_id),
    supply_date DATE NOT NULL,
    invoice_number VARCHAR(50),
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'received', -- received, pending, cancelled
    created_at TIMESTAMP DEFAULT NOW()
);

-- 11. ДЕТАЛИ ПОСТАВКИ
CREATE TABLE supply_details (
    supply_detail_id SERIAL PRIMARY KEY,
    supply_id INTEGER REFERENCES supplies(supply_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    purchase_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 12. ОСТАТКИ (ИНВЕНТАРИЗАЦИЯ)
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES branches(branch_id),
    product_id INTEGER REFERENCES products(product_id),
    stock_quantity INTEGER DEFAULT 0,
    reserved_quantity INTEGER DEFAULT 0,
    last_inventory_date DATE,
    min_stock INTEGER DEFAULT 10,
    max_stock INTEGER DEFAULT 100,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 13. ПРОМО-АКЦИИ
CREATE TABLE promotions (
    promo_id SERIAL PRIMARY KEY,
    promo_name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES categories(category_id), -- NULL = все категории
    discount_percent DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 14. ГРАФИК РАБОТЫ СОТРУДНИКОВ
CREATE TABLE work_schedule (
    schedule_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    work_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    shift_type VARCHAR(20), -- morning, evening, night
    created_at TIMESTAMP DEFAULT NOW()
);

-- Индексы для производительности
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_branch ON orders(branch_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_inventory_branch_product ON inventory(branch_id, product_id);
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_supplies_date ON supplies(supply_date);

-- Представление для аналитики продаж
CREATE VIEW sales_analytics AS
SELECT 
    o.order_id,
    o.order_date,
    o.order_time,
    b.branch_name,
    b.city,
    c.category_name,
    p.product_name,
    p.brand,
    oi.quantity,
    oi.unit_price,
    oi.discount_percent,
    oi.total_price,
    cu.loyalty_status,
    o.total_amount,
    o.payment_method,
    o.status
FROM orders o
JOIN branches b ON o.branch_id = b.branch_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN customers cu ON o.customer_id = cu.customer_id;

-- Представление для остатков
CREATE VIEW inventory_view AS
SELECT 
    b.branch_name,
    p.product_name,
    c.category_name,
    i.stock_quantity,
    i.reserved_quantity,
    (i.stock_quantity - i.reserved_quantity) AS available_quantity,
    i.min_stock,
    i.max_stock,
    (i.stock_quantity - i.min_stock) AS stock_above_min,
    CASE 
        WHEN i.stock_quantity < i.min_stock THEN 'LOW'
        WHEN i.stock_quantity > i.max_stock THEN 'HIGH'
        ELSE 'OPTIMAL'
    END AS stock_status
FROM inventory i
JOIN branches b ON i.branch_id = b.branch_id
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id;
