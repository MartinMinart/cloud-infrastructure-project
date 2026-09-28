-- ============================================================
-- ЗАГРУЗКА СОТРУДНИКОВ (210 человек)
-- ============================================================

DO $$
DECLARE
    v_branch_id INTEGER;
    v_first_names TEXT[] := ARRAY['Анна','Мария','Сергей','Иван','Ольга','Дмитрий','Елена','Павел','Александра','Михаил','Екатерина','Андрей','Наталья','Владимир','Татьяна'];
    v_last_names TEXT[] := ARRAY['Петрова','Иванов','Сидоров','Смирнова','Козлова','Волков','Морозова','Лебедев','Соколова','Крылов','Новикова','Федоров','Орлова','Михайлов','Егорова'];
    v_positions TEXT[] := ARRAY['кассир','кассир','кассир','кассир','кассир','мерчендайзер','мерчендайзер','менеджер','директор'];
    v_salary INTEGER[];
BEGIN
    FOR v_branch_id IN 1..30 LOOP
        FOR i IN 1..7 LOOP
            INSERT INTO Employees (
                branch_id,
                first_name,
                last_name,
                position,
                hire_date,
                salary,
                phone,
                email,
                is_active
            ) VALUES (
                v_branch_id,
                v_first_names[1 + floor(random() * 15)::int],
                v_last_names[1 + floor(random() * 15)::int],
                v_positions[1 + floor(random() * 9)::int],
                DATE '2020-01-01' + (random() * 900)::int,
                CASE 
                    WHEN v_positions[1 + floor(random() * 9)::int] = 'директор' THEN 100000 + floor(random() * 30000)
                    WHEN v_positions[1 + floor(random() * 9)::int] = 'менеджер' THEN 70000 + floor(random() * 20000)
                    WHEN v_positions[1 + floor(random() * 9)::int] = 'мерчендайзер' THEN 50000 + floor(random() * 15000)
                    ELSE 40000 + floor(random() * 15000)
                END,
                '+7(9' || floor(random() * 100 + 10)::text || ')' || floor(random() * 10000000 + 1000000)::text,
                'emp' || i || '@branch' || v_branch_id || '.local',
                random() > 0.05
            );
        END LOOP;
    END LOOP;
END $$;

SELECT 'employees' as table_name, COUNT(*) as count FROM Employees;
