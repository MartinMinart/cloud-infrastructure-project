-- ============================================================
-- ПОСТАВКИ (200)
-- ============================================================
INSERT INTO supplies (supplier_id, branch_id, supply_date, invoice_number, total_amount, status)
SELECT 
    1 + floor(random() * 10)::int,
    1 + floor(random() * 20)::int,
    DATE '2024-01-01' + (random() * 400)::int,
    'INV-' || floor(random() * 1000000)::text,
    0,
    'received'
FROM generate_series(1, 200);

-- ============================================================
-- ДЕТАЛИ ПОСТАВОК
-- ============================================================
DO $$
DECLARE
    v_supply_id INTEGER;
    v_total DECIMAL(10,2);
BEGIN
    FOR v_supply_id IN 1..200 LOOP
        v_total := 0;
        FOR j IN 1..(5 + floor(random() * 11))::int LOOP
            INSERT INTO supply_details (supply_id, product_id, quantity, purchase_price, total_price)
            SELECT 
                v_supply_id,
                p.product_id,
                floor(random() * 100 + 10)::int,
                p.purchase_price,
                p.purchase_price * (floor(random() * 100 + 10))::int
            FROM products p
            WHERE p.product_id = 1 + floor(random() * 65)::int
            LIMIT 1;
            
            SELECT SUM(total_price) INTO v_total FROM supply_details WHERE supply_id = v_supply_id;
            UPDATE supplies SET total_amount = v_total WHERE supply_id = v_supply_id;
        END LOOP;
    END LOOP;
END $$;

SELECT 'supplies' as name, COUNT(*) as count FROM supplies
UNION ALL
SELECT 'supply_details', COUNT(*) FROM supply_details;
