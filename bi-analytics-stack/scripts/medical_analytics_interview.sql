-- ============================================================
-- MEDICAL ANALYTICS DB — synthetic interview practice dataset
-- PostgreSQL 15+
-- All data is synthetic / fictional.
-- ============================================================

-- ============================================================
-- 0. CREATE DATABASE
-- Run this block separately while connected to an admin database:
--
-- CREATE DATABASE medical_analytics
--     WITH OWNER = analytics
--     ENCODING = 'UTF8';
--
-- Then connect DBeaver to:
--   Database: medical_analytics
-- ============================================================


-- ============================================================
-- 1. CLEAN START
-- ============================================================

DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS doctors CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS branches CASCADE;
DROP TABLE IF EXISTS patients CASCADE;


-- ============================================================
-- 2. DIMENSION TABLES
-- ============================================================

CREATE TABLE branches (
    branch_id       SERIAL PRIMARY KEY,
    branch_name     VARCHAR(100) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    district        VARCHAR(100),
    opened_at       DATE NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE doctors (
    doctor_id       SERIAL PRIMARY KEY,
    doctor_name     VARCHAR(150) NOT NULL,
    department_id   INT NOT NULL REFERENCES departments(department_id),
    branch_id       INT NOT NULL REFERENCES branches(branch_id),
    hire_date       DATE NOT NULL,
    experience_years INT NOT NULL CHECK (experience_years BETWEEN 0 AND 45),
    qualification   VARCHAR(100),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE patients (
    patient_id      SERIAL PRIMARY KEY,
    patient_name    VARCHAR(150) NOT NULL,
    birth_date      DATE NOT NULL,
    gender          CHAR(1) NOT NULL CHECK (gender IN ('M','F')),
    city            VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL,
    insurance_type  VARCHAR(30) NOT NULL
);

CREATE TABLE services (
    service_id      SERIAL PRIMARY KEY,
    service_name    VARCHAR(150) NOT NULL,
    department_id   INT NOT NULL REFERENCES departments(department_id),
    base_price      NUMERIC(10,2) NOT NULL CHECK (base_price >= 0)
);


-- ============================================================
-- 3. FACT TABLES
-- ============================================================

CREATE TABLE appointments (
    appointment_id  BIGSERIAL PRIMARY KEY,
    patient_id      INT NOT NULL REFERENCES patients(patient_id),
    doctor_id       INT NOT NULL REFERENCES doctors(doctor_id),
    branch_id       INT NOT NULL REFERENCES branches(branch_id),
    service_id      INT NOT NULL REFERENCES services(service_id),

    scheduled_at    TIMESTAMP NOT NULL,
    appointment_date DATE GENERATED ALWAYS AS (scheduled_at::date) STORED,

    status          VARCHAR(20) NOT NULL
        CHECK (status IN ('completed','scheduled','cancelled','no_show')),

    visit_duration_min INT,
    source          VARCHAR(30) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (status = 'completed' AND visit_duration_min IS NOT NULL)
        OR
        (status <> 'completed')
    )
);

CREATE TABLE payments (
    payment_id      BIGSERIAL PRIMARY KEY,
    appointment_id  BIGINT NOT NULL UNIQUE REFERENCES appointments(appointment_id),
    payment_date    TIMESTAMP NOT NULL,
    amount          NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_method  VARCHAR(30) NOT NULL,
    payment_status  VARCHAR(20) NOT NULL
        CHECK (payment_status IN ('paid','refunded','pending'))
);


-- ============================================================
-- 4. BRANCHES
-- ============================================================

INSERT INTO branches
    (branch_name, city, district, opened_at)
VALUES
    ('Клиника Центральная', 'Москва', 'Центральный', '2018-03-15'),
    ('Клиника Север',       'Москва', 'Северный',    '2020-09-01'),
    ('Клиника Юг',          'Москва', 'Южный',       '2019-06-10'),
    ('Клиника Запад',       'Москва', 'Западный',    '2021-02-20'),
    ('Клиника Восток',      'Москва', 'Восточный',   '2022-11-05');


-- ============================================================
-- 5. DEPARTMENTS
-- ============================================================

INSERT INTO departments (department_name)
VALUES
    ('Терапия'),
    ('Кардиология'),
    ('Неврология'),
    ('Гинекология'),
    ('Педиатрия'),
    ('Офтальмология'),
    ('Дерматология'),
    ('Эндокринология'),
    ('Ортопедия'),
    ('УЗИ и диагностика'),
    ('ЛОР'),
    ('Гастроэнтерология');


-- ============================================================
-- 6. DOCTORS
-- 30 doctors across branches/departments
-- ============================================================

INSERT INTO doctors
    (doctor_name, department_id, branch_id, hire_date, experience_years, qualification)
VALUES
    ('Иванова Анна Сергеевна',       1, 1, '2019-04-01', 12, 'Врач-терапевт'),
    ('Петров Максим Андреевич',      1, 2, '2021-02-15',  8, 'Врач-терапевт'),
    ('Соколова Елена Викторовна',    1, 3, '2020-07-20', 10, 'Врач-терапевт'),
    ('Кузнецов Дмитрий Олегович',    2, 1, '2018-06-10', 15, 'Врач-кардиолог'),
    ('Морозова Ольга Игоревна',      2, 4, '2022-01-12',  9, 'Врач-кардиолог'),
    ('Волков Андрей Павлович',       2, 5, '2023-03-01',  6, 'Врач-кардиолог'),

    ('Попова Мария Сергеевна',       3, 1, '2019-10-10', 13, 'Врач-невролог'),
    ('Лебедев Артем Николаевич',     3, 2, '2020-11-01', 11, 'Врач-невролог'),
    ('Крылова Наталья Олеговна',     3, 5, '2022-04-05',  7, 'Врач-невролог'),

    ('Орлова Ирина Викторовна',      4, 1, '2019-01-15', 14, 'Врач-гинеколог'),
    ('Федорова Светлана Андреевна',  4, 3, '2021-05-17',  9, 'Врач-гинеколог'),
    ('Николаева Анастасия Ильинична',4, 4, '2022-09-01',  6, 'Врач-гинеколог'),

    ('Васильев Павел Сергеевич',     5, 2, '2020-03-12', 10, 'Врач-педиатр'),
    ('Захарова Екатерина Романовна', 5, 3, '2021-08-23',  8, 'Врач-педиатр'),
    ('Семенов Алексей Владимирович', 5, 5, '2023-02-10',  5, 'Врач-педиатр'),

    ('Алексеева Марина Петровна',    6, 1, '2018-09-03', 17, 'Врач-офтальмолог'),
    ('Данилов Роман Игоревич',        6, 4, '2022-06-01',  7, 'Врач-офтальмолог'),

    ('Тихонова Юлия Михайловна',      7, 2, '2020-10-15', 12, 'Врач-дерматолог'),
    ('Громов Сергей Владимирович',    7, 5, '2023-05-01',  6, 'Врач-дерматолог'),

    ('Мельникова Елена Алексеевна',   8, 1, '2019-07-01', 13, 'Врач-эндокринолог'),
    ('Королев Виктор Сергеевич',      8, 3, '2021-03-15',  9, 'Врач-эндокринолог'),

    ('Беляев Николай Петрович',       9, 2, '2019-11-11', 16, 'Врач-ортопед'),
    ('Романова Алиса Дмитриевна',     9, 4, '2022-08-08',  8, 'Врач-ортопед'),

    ('Гаврилова Татьяна Олеговна',   10, 1, '2020-01-20', 11, 'Врач УЗД'),
    ('Ковалев Илья Аркадьевич',      10, 3, '2021-10-01',  9, 'Врач УЗД'),
    ('Широкова Виктория Денисовна',  10, 5, '2023-01-16',  5, 'Врач УЗД'),

    ('Максимова Оксана Андреевна',   11, 2, '2020-06-01', 12, 'Врач-оториноларинголог'),
    ('Егоров Михаил Сергеевич',      11, 4, '2022-02-14',  8, 'Врач-оториноларинголог'),

    ('Киселева Дарья Игоревна',      12, 1, '2019-08-19', 13, 'Врач-гастроэнтеролог'),
    ('Фомин Александр Евгеньевич',   12, 5, '2023-04-03',  6, 'Врач-гастроэнтеролог');


-- ============================================================
-- 7. SERVICES
-- ============================================================

INSERT INTO services (service_name, department_id, base_price)
VALUES
    ('Первичный прием терапевта',       1, 2200),
    ('Повторный прием терапевта',       1, 1700),
    ('Прием кардиолога',                2, 3200),
    ('ЭКГ',                             2, 1400),
    ('Прием невролога',                 3, 3000),
    ('Прием гинеколога',                4, 2800),
    ('УЗИ малого таза',                 4, 3500),
    ('Прием педиатра',                  5, 2300),
    ('Прием офтальмолога',              6, 2700),
    ('Диагностика зрения',              6, 1800),
    ('Прием дерматолога',               7, 2600),
    ('Дерматоскопия',                   7, 1900),
    ('Прием эндокринолога',             8, 3000),
    ('Прием ортопеда',                  9, 2900),
    ('УЗИ брюшной полости',            10, 3200),
    ('УЗИ щитовидной железы',          10, 2200),
    ('Прием ЛОР-врача',                11, 2500),
    ('Прием гастроэнтеролога',         12, 3000);


-- ============================================================
-- 8. PATIENTS
-- 1,500 synthetic patients
-- ============================================================

INSERT INTO patients
    (patient_name, birth_date, gender, city, registration_date, insurance_type)
SELECT
    CASE
        WHEN g % 2 = 0
        THEN 'Пациент ' || g || ' Андреев'
        ELSE 'Пациент ' || g || ' Петров'
    END,
    DATE '1955-01-01' + ((g * 17) % 18000),
    CASE WHEN g % 2 = 0 THEN 'F' ELSE 'M' END,
    CASE
        WHEN g % 10 < 7 THEN 'Москва'
        WHEN g % 10 = 7 THEN 'Химки'
        WHEN g % 10 = 8 THEN 'Мытищи'
        ELSE 'Красногорск'
    END,
    DATE '2023-01-01' + ((g * 13) % 1200),
    CASE
        WHEN g % 10 < 6 THEN 'ОМС'
        WHEN g % 10 < 9 THEN 'ДМС'
        ELSE 'Платный'
    END
FROM generate_series(1,1500) AS s(g);


-- ============================================================
-- 9. APPOINTMENTS
-- 5,000 appointments — intentionally more than the requested 1,000.
--
-- Distribution:
--   ~68% completed
--   ~12% scheduled
--   ~10% cancelled
--   ~10% no_show
--
-- generate_series is PostgreSQL's built-in series generator.
-- ============================================================

INSERT INTO appointments
    (
        patient_id,
        doctor_id,
        branch_id,
        service_id,
        scheduled_at,
        status,
        visit_duration_min,
        source
    )
SELECT
    1 + ((g * 37) % 1500) AS patient_id,

    d.doctor_id,

    d.branch_id,

    s.service_id,

    TIMESTAMP '2026-01-01 08:00:00'
        + ((g * 19) % 180) * INTERVAL '1 day'
        + ((g * 7) % 10) * INTERVAL '1 hour'
        + ((g * 13) % 4) * INTERVAL '15 minutes',

    CASE
        WHEN g % 100 < 68 THEN 'completed'
        WHEN g % 100 < 80 THEN 'scheduled'
        WHEN g % 100 < 90 THEN 'cancelled'
        ELSE 'no_show'
    END,

    CASE
        WHEN g % 100 < 68 THEN 20 + ((g * 11) % 60)
        ELSE NULL
    END,

    CASE
        WHEN g % 10 < 5 THEN 'website'
        WHEN g % 10 < 8 THEN 'phone'
        WHEN g % 10 = 8 THEN 'mobile_app'
        ELSE 'registry'
    END

FROM generate_series(1,5000) AS gs(g)
JOIN doctors d
    ON d.doctor_id = 1 + ((g * 7) % 30)
JOIN services s
    ON s.service_id = 1 + ((g * 11) % 18);


-- ============================================================
-- 10. PAYMENTS
-- Payment exists mostly for completed appointments.
-- Amount varies around the service base price.
-- ============================================================

INSERT INTO payments
    (appointment_id, payment_date, amount, payment_method, payment_status)
SELECT
    a.appointment_id,
    a.scheduled_at + INTERVAL '20 minutes',
    ROUND(
        s.base_price *
        CASE
            WHEN a.appointment_id % 10 < 6 THEN 1.00
            WHEN a.appointment_id % 10 < 8 THEN 0.90
            WHEN a.appointment_id % 10 = 8 THEN 1.10
            ELSE 1.20
        END
    , 2),
    CASE
        WHEN a.appointment_id % 10 < 5 THEN 'card'
        WHEN a.appointment_id % 10 < 8 THEN 'cash'
        WHEN a.appointment_id % 10 = 8 THEN 'online'
        ELSE 'insurance'
    END,
    CASE
        WHEN a.appointment_id % 100 < 95 THEN 'paid'
        WHEN a.appointment_id % 100 < 98 THEN 'refunded'
        ELSE 'pending'
    END
FROM appointments a
JOIN services s
    ON s.service_id = a.service_id
WHERE a.status = 'completed';


-- ============================================================
-- 11. INDEXES
-- Useful for interview discussion about query performance.
-- ============================================================

CREATE INDEX idx_appointments_date
    ON appointments (scheduled_at);

CREATE INDEX idx_appointments_doctor_date
    ON appointments (doctor_id, scheduled_at);

CREATE INDEX idx_appointments_patient
    ON appointments (patient_id);

CREATE INDEX idx_appointments_branch_date
    ON appointments (branch_id, scheduled_at);

CREATE INDEX idx_appointments_status
    ON appointments (status);

CREATE INDEX idx_payments_date
    ON payments (payment_date);

CREATE INDEX idx_doctors_department
    ON doctors (department_id);

CREATE INDEX idx_doctors_branch
    ON doctors (branch_id);


-- ============================================================
-- 12. ANALYZE
-- ============================================================

ANALYZE;


-- ============================================================
-- 13. SANITY CHECKS
-- ============================================================

SELECT 'branches' AS table_name, COUNT(*) AS rows_count FROM branches
UNION ALL
SELECT 'departments', COUNT(*) FROM departments
UNION ALL
SELECT 'doctors', COUNT(*) FROM doctors
UNION ALL
SELECT 'patients', COUNT(*) FROM patients
UNION ALL
SELECT 'services', COUNT(*) FROM services
UNION ALL
SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
ORDER BY table_name;


-- ============================================================
-- 14. STARTER INTERVIEW QUESTIONS
-- ============================================================

-- Q1. Сколько всего приемов и сколько завершенных?
SELECT
    COUNT(*) AS appointments_total,
    COUNT(*) FILTER (WHERE status = 'completed') AS completed,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled,
    COUNT(*) FILTER (WHERE status = 'no_show') AS no_show,
    COUNT(*) FILTER (WHERE status = 'scheduled') AS scheduled
FROM appointments;


-- Q2. Выручка по филиалам.
SELECT
    b.branch_name,
    COUNT(a.appointment_id) AS completed_visits,
    ROUND(SUM(p.amount), 2) AS revenue
FROM branches b
JOIN appointments a
    ON a.branch_id = b.branch_id
   AND a.status = 'completed'
JOIN payments p
    ON p.appointment_id = a.appointment_id
   AND p.payment_status = 'paid'
GROUP BY b.branch_id, b.branch_name
ORDER BY revenue DESC;


-- Q3. Топ-10 врачей по количеству завершенных приемов.
SELECT
    d.doctor_name,
    dep.department_name,
    b.branch_name,
    COUNT(*) AS completed_visits
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
JOIN departments dep ON dep.department_id = d.department_id
JOIN branches b ON b.branch_id = d.branch_id
WHERE a.status = 'completed'
GROUP BY d.doctor_id, d.doctor_name, dep.department_name, b.branch_name
ORDER BY completed_visits DESC
LIMIT 10;


-- Q4. Средняя выручка с одного завершенного приема по специальности.
SELECT
    dep.department_name,
    COUNT(*) AS visits,
    ROUND(AVG(p.amount), 2) AS avg_revenue_per_visit
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
JOIN departments dep ON dep.department_id = d.department_id
JOIN payments p ON p.appointment_id = a.appointment_id
WHERE a.status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY dep.department_id, dep.department_name
ORDER BY avg_revenue_per_visit DESC;


-- Q5. Доля no-show по филиалам.
SELECT
    b.branch_name,
    COUNT(*) AS total_appointments,
    COUNT(*) FILTER (WHERE a.status = 'no_show') AS no_show_count,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE a.status = 'no_show')
        / COUNT(*),
        2
    ) AS no_show_rate_pct
FROM appointments a
JOIN branches b ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY no_show_rate_pct DESC;


-- Q6. Ежедневная динамика приемов.
SELECT
    appointment_date,
    COUNT(*) AS total_appointments,
    COUNT(*) FILTER (WHERE status = 'completed') AS completed,
    COUNT(*) FILTER (WHERE status = 'no_show') AS no_show
FROM appointments
GROUP BY appointment_date
ORDER BY appointment_date;


-- Q7. Топ-3 врача внутри каждого филиала по числу завершенных приемов.
WITH doctor_stats AS (
    SELECT
        d.doctor_id,
        d.doctor_name,
        d.branch_id,
        b.branch_name,
        COUNT(*) AS completed_visits
    FROM appointments a
    JOIN doctors d ON d.doctor_id = a.doctor_id
    JOIN branches b ON b.branch_id = d.branch_id
    WHERE a.status = 'completed'
    GROUP BY d.doctor_id, d.doctor_name, d.branch_id, b.branch_name
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY branch_id
            ORDER BY completed_visits DESC
        ) AS rn
    FROM doctor_stats
)
SELECT *
FROM ranked
WHERE rn <= 3
ORDER BY branch_name, rn;


-- Q8. Среднее время приема по специальности.
SELECT
    dep.department_name,
    COUNT(*) AS completed_visits,
    ROUND(AVG(a.visit_duration_min), 1) AS avg_duration_min
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
JOIN departments dep ON dep.department_id = d.department_id
WHERE a.status = 'completed'
GROUP BY dep.department_id, dep.department_name
ORDER BY avg_duration_min DESC;


-- Q9. Пациенты с наибольшим количеством посещений.
SELECT
    p.patient_id,
    p.patient_name,
    COUNT(*) AS visits
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
WHERE a.status = 'completed'
GROUP BY p.patient_id, p.patient_name
ORDER BY visits DESC
LIMIT 20;


-- Q10. Повторные пациенты:
-- пациенты, у которых было >= 3 завершенных приемов.
SELECT
    p.patient_id,
    p.patient_name,
    COUNT(*) AS completed_visits,
    MIN(a.scheduled_at) AS first_visit,
    MAX(a.scheduled_at) AS last_visit
FROM patients p
JOIN appointments a ON a.patient_id = p.patient_id
WHERE a.status = 'completed'
GROUP BY p.patient_id, p.patient_name
HAVING COUNT(*) >= 3
ORDER BY completed_visits DESC;


-- Q11. Месячная выручка + предыдущий месяц.
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', p.payment_date)::date AS month,
        SUM(p.amount) AS revenue
    FROM payments p
    WHERE p.payment_status = 'paid'
    GROUP BY 1
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        LAG(revenue) OVER (ORDER BY month),
        2
    ) AS previous_month_revenue,
    ROUND(
        100.0 * (
            revenue - LAG(revenue) OVER (ORDER BY month)
        ) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        2
    ) AS growth_pct
FROM monthly
ORDER BY month;


-- Q12. Врачи, у которых no-show rate выше 12%.
SELECT
    d.doctor_name,
    b.branch_name,
    COUNT(*) AS total_appointments,
    COUNT(*) FILTER (WHERE a.status = 'no_show') AS no_show,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE a.status = 'no_show')
        / COUNT(*),
        2
    ) AS no_show_rate_pct
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
JOIN branches b ON b.branch_id = d.branch_id
GROUP BY d.doctor_id, d.doctor_name, b.branch_name
HAVING
    100.0 * COUNT(*) FILTER (WHERE a.status = 'no_show')
    / COUNT(*) > 12
ORDER BY no_show_rate_pct DESC;


-- Q13. Дни, когда филиал работал хуже среднего по числу
-- завершенных приемов.
WITH daily AS (
    SELECT
        branch_id,
        appointment_date,
        COUNT(*) FILTER (WHERE status = 'completed') AS completed
    FROM appointments
    GROUP BY branch_id, appointment_date
),
branch_avg AS (
    SELECT
        branch_id,
        AVG(completed) AS avg_completed
    FROM daily
    GROUP BY branch_id
)
SELECT
    b.branch_name,
    d.appointment_date,
    d.completed,
    ROUND(ba.avg_completed, 2) AS branch_avg
FROM daily d
JOIN branch_avg ba ON ba.branch_id = d.branch_id
JOIN branches b ON b.branch_id = d.branch_id
WHERE d.completed < ba.avg_completed
ORDER BY b.branch_name, d.appointment_date;


-- Q14. Проверка качества данных:
-- приемы, где филиал приема отличается от филиала врача.
SELECT
    COUNT(*) AS inconsistent_appointments
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
WHERE a.branch_id <> d.branch_id;


-- Q15. EXPLAIN ANALYZE — пример для обсуждения индексов.
EXPLAIN ANALYZE
SELECT
    doctor_id,
    COUNT(*)
FROM appointments
WHERE scheduled_at >= '2026-03-01'
  AND scheduled_at <  '2026-04-01'
GROUP BY doctor_id;


-- ============================================================
-- 15. EXTRA INTERVIEW TASKS — DO YOURSELF
-- Не смотри решение сразу.
-- ============================================================

-- TASK A
-- Найди 5 врачей с максимальной выручкой.


-- TASK B
-- Для каждого филиала найди врача с максимальной выручкой.
-- Если два врача имеют одинаковую выручку, оставь обоих.


-- TASK C
-- Найди пациентов, которые были у разных врачей минимум
-- в двух разных отделениях.


-- TASK D
-- Посчитай conversion:
-- scheduled -> completed по каждому источнику записи.


-- TASK E
-- Найди 10 дат с самым высоким no-show rate,
-- но исключи даты, где было меньше 10 приемов.


-- TASK F
-- Для каждого врача посчитай:
-- total appointments
-- completed
-- cancelled
-- no_show
-- completion_rate
-- no_show_rate


-- TASK G
-- Найди врачей, у которых количество приемов выше
-- среднего количества приемов среди всех врачей.


-- TASK H
-- Для каждого пациента найди первый и последний завершенный прием.


-- TASK I
-- Найди пациентов, у которых последний прием был более
-- чем за 60 дней до максимальной даты в данных.


-- TASK J
-- Сделай RANK / DENSE_RANK врачей внутри каждого
-- отделения по выручке.


-- ============================================================
-- 16. EXPECTED DATA VOLUME
-- ============================================================
-- branches      = 5
-- departments   = 12
-- doctors       = 30
-- patients      = 1500
-- services      = 18
-- appointments  = 5000
-- payments      ~= 3400
--
-- Dataset is deliberately synthetic, deterministic and small
-- enough to run comfortably on a laptop/VM.
-- ============================================================
