-- Филиалы
CREATE TABLE IF NOT EXISTS branches (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    phone VARCHAR(20),
    manager_name VARCHAR(100),
    opening_date DATE,
    status VARCHAR(20) DEFAULT 'active'
);

-- Продукты
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    subcategory VARCHAR(100),
    supplier VARCHAR(100),
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    unit VARCHAR(20) DEFAULT 'шт',
    stock_quantity INTEGER DEFAULT 0,
    min_stock INTEGER DEFAULT 10
);

-- Клиенты
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(20),
    city VARCHAR(100),
    registration_date DATE,
    loyalty_status VARCHAR(20) DEFAULT 'regular',
    total_spent DECIMAL(10,2) DEFAULT 0
);

-- Заказы
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES branches(branch_id),
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(50),
    status VARCHAR(20) DEFAULT 'completed'
);

-- Элементы заказов
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2) DEFAULT 0,
    total_price DECIMAL(10,2)
);
