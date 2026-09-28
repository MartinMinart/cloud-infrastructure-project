-- ============================================================
-- RETAIL ANALYTICS DATABASE - СХЕМА
-- Версия: 2.0
-- Дата: 2026-08-25
-- Описание: Полная схема для розничной сети
-- ============================================================

-- 1. CATEGORIES (Категории товаров)
CREATE TABLE IF NOT EXISTS Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INTEGER REFERENCES Categories(category_id),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. SUPPLIERS (Поставщики)
CREATE TABLE IF NOT EXISTS Suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(200),
    address TEXT,
    tax_id VARCHAR(50),
    rating INTEGER DEFAULT 3,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. PRODUCTS (Товары)
CREATE TABLE IF NOT EXISTS Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES Categories(category_id),
    supplier_id INTEGER REFERENCES Suppliers(supplier_id),
    brand VARCHAR(100),
    unit VARCHAR(20) DEFAULT 'шт',
    barcode VARCHAR(50) UNIQUE,
    shelf_life_days INTEGER,
    weight_grams INTEGER,
    purchase_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    min_stock INTEGER DEFAULT 10,
    max_stock INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. BRANCHES (Филиалы/Магазины)
CREATE TABLE IF NOT EXISTS Branches (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    phone VARCHAR(20),
    manager_name VARCHAR(100),
    opening_date DATE,
    store_area_sqm INTEGER,
    format VARCHAR(50) CHECK (format IN ('у дома', 'средний', 'суперстор', 'дискаунтер')),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. EMPLOYEES (Сотрудники)
CREATE TABLE IF NOT EXISTS Employees (
    employee_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES Branches(branch_id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    position VARCHAR(50),
    hire_date DATE,
    salary DECIMAL(10,2),
    phone VARCHAR(20),
    email VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 6. CUSTOMERS (Клиенты)
CREATE TABLE IF NOT EXISTS Customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(20),
    city VARCHAR(100),
    address TEXT,
    registration_date DATE,
    loyalty_status VARCHAR(20) DEFAULT 'regular',
    loyalty_card_number VARCHAR(50),
    total_spent DECIMAL(10,2) DEFAULT 0,
    last_purchase_date DATE,
    customer_segment VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 7. SECTIONS (Отделы магазина)
CREATE TABLE IF NOT EXISTS Sections (
    section_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES Branches(branch_id),
    section_name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES Categories(category_id),
    section_area_sqm INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 8. SALES (Продажи/Заказы)
CREATE TABLE IF NOT EXISTS Sales (
    sale_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES Branches(branch_id),
    customer_id INTEGER REFERENCES Customers(customer_id),
    employee_id INTEGER REFERENCES Employees(employee_id),
    sale_date DATE NOT NULL,
    sale_time TIME,
    total_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(50) CHECK (payment_method IN ('cash', 'card', 'mobile', 'sbp')),
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 9. SALE_DETAILS (Детали продаж)
CREATE TABLE IF NOT EXISTS Sale_Details (
    sale_detail_id SERIAL PRIMARY KEY,
    sale_id INTEGER REFERENCES Sales(sale_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES Products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2),
    discount_percent DECIMAL(5,2) DEFAULT 0,
    total_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 10. SUPPLIES (Поставки)
CREATE TABLE IF NOT EXISTS Supplies (
    supply_id SERIAL PRIMARY KEY,
    supplier_id INTEGER REFERENCES Suppliers(supplier_id),
    branch_id INTEGER REFERENCES Branches(branch_id),
    supply_date DATE NOT NULL,
    invoice_number VARCHAR(50),
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'received',
    created_at TIMESTAMP DEFAULT NOW()
);

-- 11. SUPPLY_DETAILS (Детали поставок)
CREATE TABLE IF NOT EXISTS Supply_Details (
    supply_detail_id SERIAL PRIMARY KEY,
    supply_id INTEGER REFERENCES Supplies(supply_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES Products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    purchase_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 12. INVENTORY (Остатки)
CREATE TABLE IF NOT EXISTS Inventory (
    inventory_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES Branches(branch_id),
    product_id INTEGER REFERENCES Products(product_id),
    stock_quantity INTEGER DEFAULT 0,
    reserved_quantity INTEGER DEFAULT 0,
    last_inventory_date DATE,
    min_stock INTEGER DEFAULT 10,
    max_stock INTEGER DEFAULT 100,
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(branch_id, product_id)
);

-- 13. PROMOTIONS (Промо-акции)
CREATE TABLE IF NOT EXISTS Promotions (
    promo_id SERIAL PRIMARY KEY,
    promo_name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES Categories(category_id),
    discount_percent DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 14. WORK_SCHEDULE (График работы)
CREATE TABLE IF NOT EXISTS Work_Schedule (
    schedule_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES Employees(employee_id),
    work_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    shift_type VARCHAR(20) CHECK (shift_type IN ('morning', 'evening', 'night')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- ИНДЕКСЫ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_sales_date ON Sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_branch ON Sales(branch_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer ON Sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_status ON Sales(status);
CREATE INDEX IF NOT EXISTS idx_sale_details_sale ON Sale_Details(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_details_product ON Sale_Details(product_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON Products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_supplier ON Products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_inventory_branch_product ON Inventory(branch_id, product_id);
CREATE INDEX IF NOT EXISTS idx_customers_city ON Customers(city);
CREATE INDEX IF NOT EXISTS idx_supplies_date ON Supplies(supply_date);
CREATE INDEX IF NOT EXISTS idx_customers_loyalty ON Customers(loyalty_status);
CREATE INDEX IF NOT EXISTS idx_sales_date_status ON Sales(sale_date, status);
CREATE INDEX IF NOT EXISTS idx_products_active ON Products(is_active);

-- ============================================================
-- ПРЕДСТАВЛЕНИЯ ДЛЯ АНАЛИТИКИ
-- ============================================================

-- 1. Sales Analytics View
CREATE OR REPLACE VIEW v_sales_analytics AS
SELECT 
    s.sale_id,
    s.sale_date,
    s.sale_time,
    EXTRACT(YEAR FROM s.sale_date) as year,
    EXTRACT(MONTH FROM s.sale_date) as month,
    EXTRACT(DOW FROM s.sale_date) as day_of_week,
    b.branch_name,
    b.city,
    b.format as branch_format,
    c.category_name,
    c.parent_category_id,
    p.product_name,
    p.brand,
    sd.quantity,
    sd.unit_price,
    sd.discount_percent,
    sd.total_price,
    cu.loyalty_status,
    cu.customer_segment,
    s.total_amount,
    s.discount_amount,
    s.payment_method,
    s.status,
    e.first_name || ' ' || e.last_name as employee_name
FROM Sales s
JOIN Branches b ON s.branch_id = b.branch_id
JOIN Sale_Details sd ON s.sale_id = sd.sale_id
JOIN Products p ON sd.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
LEFT JOIN Customers cu ON s.customer_id = cu.customer_id
LEFT JOIN Employees e ON s.employee_id = e.employee_id;

-- 2. Inventory Status View
CREATE OR REPLACE VIEW v_inventory AS
SELECT 
    b.branch_name,
    b.city,
    p.product_name,
    c.category_name,
    p.brand,
    i.stock_quantity,
    i.reserved_quantity,
    (i.stock_quantity - i.reserved_quantity) AS available_quantity,
    i.min_stock,
    i.max_stock,
    CASE 
        WHEN i.stock_quantity < i.min_stock THEN 'LOW'
        WHEN i.stock_quantity > i.max_stock THEN 'HIGH'
        ELSE 'OPTIMAL'
    END AS stock_status,
    CASE 
        WHEN i.stock_quantity < i.min_stock THEN 'Критический минимум'
        WHEN i.stock_quantity > i.max_stock THEN 'Переизбыток'
        ELSE 'Норма'
    END AS stock_status_ru
FROM Inventory i
JOIN Branches b ON i.branch_id = b.branch_id
JOIN Products p ON i.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id;

-- 3. Daily KPI View
CREATE OR REPLACE VIEW v_kpi_daily AS
SELECT 
    s.sale_date,
    COUNT(DISTINCT s.sale_id) as total_orders,
    COUNT(DISTINCT s.customer_id) as unique_customers,
    ROUND(SUM(s.total_amount)::numeric, 2) as total_revenue,
    ROUND(AVG(s.total_amount)::numeric, 2) as avg_order_value,
    ROUND(SUM(s.total_amount)::numeric / NULLIF(COUNT(DISTINCT s.customer_id), 0), 2) as revenue_per_customer,
    ROUND(AVG(sd.quantity)::numeric, 2) as avg_items_per_order,
    ROUND(SUM(s.discount_amount)::numeric, 2) as total_discounts
FROM Sales s
JOIN Sale_Details sd ON s.sale_id = sd.sale_id
WHERE s.status = 'completed'
GROUP BY s.sale_date
ORDER BY s.sale_date DESC;

-- 4. Monthly KPI View
CREATE OR REPLACE VIEW v_kpi_monthly AS
SELECT 
    DATE_TRUNC('month', s.sale_date) as month,
    EXTRACT(YEAR FROM s.sale_date) as year,
    EXTRACT(MONTH FROM s.sale_date) as month_num,
    COUNT(DISTINCT s.sale_id) as total_orders,
    COUNT(DISTINCT s.customer_id) as unique_customers,
    ROUND(SUM(s.total_amount)::numeric, 2) as total_revenue,
    ROUND(AVG(s.total_amount)::numeric, 2) as avg_order_value,
    ROUND(SUM(s.total_amount)::numeric / NULLIF(COUNT(DISTINCT s.customer_id), 0), 2) as revenue_per_customer
FROM Sales s
WHERE s.status = 'completed'
GROUP BY DATE_TRUNC('month', s.sale_date), EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
ORDER BY month DESC;

-- 5. Product Performance View
CREATE OR REPLACE VIEW v_product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.brand,
    COUNT(DISTINCT sd.sale_id) as sales_count,
    SUM(sd.quantity) as total_quantity_sold,
    ROUND(SUM(sd.total_price)::numeric, 2) as total_revenue,
    ROUND(AVG(sd.unit_price)::numeric, 2) as avg_selling_price,
    ROUND(SUM(sd.total_price)::numeric / NULLIF(SUM(sd.quantity), 0), 2) as avg_price_per_unit,
    COUNT(DISTINCT s.branch_id) as branches_sold
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
JOIN Sale_Details sd ON p.product_id = sd.product_id
JOIN Sales s ON sd.sale_id = s.sale_id
WHERE s.status = 'completed'
GROUP BY p.product_id, p.product_name, c.category_name, p.brand
ORDER BY total_revenue DESC;

-- 6. Branch Performance View
CREATE OR REPLACE VIEW v_branch_performance AS
SELECT 
    b.branch_id,
    b.branch_name,
    b.city,
    b.format,
    COUNT(DISTINCT s.sale_id) as total_orders,
    COUNT(DISTINCT s.customer_id) as unique_customers,
    ROUND(SUM(s.total_amount)::numeric, 2) as total_revenue,
    ROUND(AVG(s.total_amount)::numeric, 2) as avg_order_value,
    ROUND(SUM(s.total_amount)::numeric / NULLIF(COUNT(DISTINCT s.sale_id), 0), 2) as revenue_per_order,
    COUNT(DISTINCT e.employee_id) as total_employees
FROM Branches b
LEFT JOIN Sales s ON b.branch_id = s.branch_id AND s.status = 'completed'
LEFT JOIN Employees e ON b.branch_id = e.branch_id AND e.is_active = TRUE
GROUP BY b.branch_id, b.branch_name, b.city, b.format
ORDER BY total_revenue DESC;

-- 7. Customer Insights View
CREATE OR REPLACE VIEW v_customer_insights AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as full_name,
    c.city,
    c.loyalty_status,
    c.registration_date,
    COUNT(DISTINCT s.sale_id) as total_orders,
    ROUND(SUM(s.total_amount)::numeric, 2) as total_spent,
    ROUND(AVG(s.total_amount)::numeric, 2) as avg_order_value,
    MAX(s.sale_date) as last_purchase_date,
    EXTRACT(DAY FROM (NOW() - MAX(s.sale_date))) as days_since_last_purchase,
    CASE 
        WHEN COUNT(DISTINCT s.sale_id) >= 10 THEN 'VIP'
        WHEN COUNT(DISTINCT s.sale_id) >= 5 THEN 'Active'
        WHEN COUNT(DISTINCT s.sale_id) >= 2 THEN 'Occasional'
        ELSE 'New'
    END as customer_segment_auto
FROM Customers c
LEFT JOIN Sales s ON c.customer_id = s.customer_id AND s.status = 'completed'
GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.loyalty_status, c.registration_date
ORDER BY total_spent DESC;
