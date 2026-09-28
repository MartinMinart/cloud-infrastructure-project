--
-- PostgreSQL database dump
--

\restrict a2UvZPoj81gtJrtBeQzlCgHFgnOayaUkxWimlTC16sNjV2WNIahLxfCVxED60pv

-- Dumped from database version 15.19
-- Dumped by pg_dump version 15.19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: branches; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.branches (
    branch_id integer NOT NULL,
    branch_name character varying(100) NOT NULL,
    city character varying(100) NOT NULL,
    address character varying(200),
    phone character varying(20),
    manager_name character varying(100),
    opening_date date,
    store_area_sqm integer,
    format character varying(50),
    status character varying(20) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT branches_format_check CHECK (((format)::text = ANY ((ARRAY['у дома'::character varying, 'средний'::character varying, 'суперстор'::character varying, 'дискаунтер'::character varying])::text[])))
);


ALTER TABLE public.branches OWNER TO analytics;

--
-- Name: branches_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.branches_branch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.branches_branch_id_seq OWNER TO analytics;

--
-- Name: branches_branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.branches_branch_id_seq OWNED BY public.branches.branch_id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    category_name character varying(100) NOT NULL,
    parent_category_id integer,
    description text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.categories OWNER TO analytics;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_category_id_seq OWNER TO analytics;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    email character varying(200),
    phone character varying(20),
    city character varying(100),
    address text,
    registration_date date,
    loyalty_status character varying(20) DEFAULT 'regular'::character varying,
    loyalty_card_number character varying(50),
    total_spent numeric(10,2) DEFAULT 0,
    last_purchase_date date,
    customer_segment character varying(20),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.customers OWNER TO analytics;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customers_customer_id_seq OWNER TO analytics;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.employees (
    employee_id integer NOT NULL,
    branch_id integer,
    first_name character varying(100),
    last_name character varying(100),
    "position" character varying(50),
    hire_date date,
    salary numeric(10,2),
    phone character varying(20),
    email character varying(200),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.employees OWNER TO analytics;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employees_employee_id_seq OWNER TO analytics;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.employees_employee_id_seq OWNED BY public.employees.employee_id;


--
-- Name: inventory; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.inventory (
    inventory_id integer NOT NULL,
    branch_id integer,
    product_id integer,
    stock_quantity integer DEFAULT 0,
    reserved_quantity integer DEFAULT 0,
    last_inventory_date date,
    min_stock integer DEFAULT 10,
    max_stock integer DEFAULT 100,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.inventory OWNER TO analytics;

--
-- Name: inventory_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.inventory_inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_inventory_id_seq OWNER TO analytics;

--
-- Name: inventory_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.inventory_inventory_id_seq OWNED BY public.inventory.inventory_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    product_name character varying(200) NOT NULL,
    category_id integer,
    supplier_id integer,
    brand character varying(100),
    unit character varying(20) DEFAULT 'шт'::character varying,
    barcode character varying(50),
    shelf_life_days integer,
    weight_grams integer,
    purchase_price numeric(10,2),
    selling_price numeric(10,2),
    min_stock integer DEFAULT 10,
    max_stock integer DEFAULT 100,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.products OWNER TO analytics;

--
-- Name: products_new; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.products_new (
    product_id integer,
    product_name character varying(200),
    category_id integer,
    supplier_id integer,
    brand character varying(100),
    unit character varying(20),
    barcode character varying(50),
    shelf_life_days integer,
    weight_grams integer,
    purchase_price numeric(10,2),
    selling_price numeric(10,2),
    min_stock integer,
    max_stock integer,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.products_new OWNER TO analytics;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_product_id_seq OWNER TO analytics;

--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- Name: promotions; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.promotions (
    promo_id integer NOT NULL,
    promo_name character varying(100) NOT NULL,
    category_id integer,
    discount_percent numeric(5,2) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.promotions OWNER TO analytics;

--
-- Name: promotions_promo_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.promotions_promo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.promotions_promo_id_seq OWNER TO analytics;

--
-- Name: promotions_promo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.promotions_promo_id_seq OWNED BY public.promotions.promo_id;


--
-- Name: sale_details; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.sale_details (
    sale_detail_id integer NOT NULL,
    sale_id integer,
    product_id integer,
    quantity integer NOT NULL,
    unit_price numeric(10,2),
    discount_percent numeric(5,2) DEFAULT 0,
    total_price numeric(10,2),
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT sale_details_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.sale_details OWNER TO analytics;

--
-- Name: sale_details_sale_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.sale_details_sale_detail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sale_details_sale_detail_id_seq OWNER TO analytics;

--
-- Name: sale_details_sale_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.sale_details_sale_detail_id_seq OWNED BY public.sale_details.sale_detail_id;


--
-- Name: sales; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.sales (
    sale_id integer NOT NULL,
    branch_id integer,
    customer_id integer,
    employee_id integer,
    sale_date date NOT NULL,
    sale_time time without time zone,
    total_amount numeric(10,2),
    discount_amount numeric(10,2) DEFAULT 0,
    payment_method character varying(50),
    status character varying(20) DEFAULT 'completed'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT sales_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['cash'::character varying, 'card'::character varying, 'mobile'::character varying, 'sbp'::character varying])::text[])))
);


ALTER TABLE public.sales OWNER TO analytics;

--
-- Name: sales_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.sales_sale_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_sale_id_seq OWNER TO analytics;

--
-- Name: sales_sale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.sales_sale_id_seq OWNED BY public.sales.sale_id;


--
-- Name: sections; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.sections (
    section_id integer NOT NULL,
    branch_id integer,
    section_name character varying(100) NOT NULL,
    category_id integer,
    section_area_sqm integer,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sections OWNER TO analytics;

--
-- Name: sections_section_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.sections_section_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sections_section_id_seq OWNER TO analytics;

--
-- Name: sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.sections_section_id_seq OWNED BY public.sections.section_id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.suppliers (
    supplier_id integer NOT NULL,
    supplier_name character varying(200) NOT NULL,
    contact_person character varying(100),
    phone character varying(20),
    email character varying(200),
    address text,
    tax_id character varying(50),
    rating integer DEFAULT 3,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suppliers OWNER TO analytics;

--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.suppliers_supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.suppliers_supplier_id_seq OWNER TO analytics;

--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.suppliers_supplier_id_seq OWNED BY public.suppliers.supplier_id;


--
-- Name: supplies; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.supplies (
    supply_id integer NOT NULL,
    supplier_id integer,
    branch_id integer,
    supply_date date NOT NULL,
    invoice_number character varying(50),
    total_amount numeric(10,2),
    status character varying(20) DEFAULT 'received'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.supplies OWNER TO analytics;

--
-- Name: supplies_supply_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.supplies_supply_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.supplies_supply_id_seq OWNER TO analytics;

--
-- Name: supplies_supply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.supplies_supply_id_seq OWNED BY public.supplies.supply_id;


--
-- Name: supply_details; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.supply_details (
    supply_detail_id integer NOT NULL,
    supply_id integer,
    product_id integer,
    quantity integer NOT NULL,
    purchase_price numeric(10,2),
    total_price numeric(10,2),
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT supply_details_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.supply_details OWNER TO analytics;

--
-- Name: supply_details_supply_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.supply_details_supply_detail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.supply_details_supply_detail_id_seq OWNER TO analytics;

--
-- Name: supply_details_supply_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.supply_details_supply_detail_id_seq OWNED BY public.supply_details.supply_detail_id;


--
-- Name: v_branch_performance; Type: VIEW; Schema: public; Owner: analytics
--

CREATE VIEW public.v_branch_performance AS
 SELECT b.branch_id,
    b.branch_name,
    b.city,
    b.format,
    count(DISTINCT s.sale_id) AS total_orders,
    count(DISTINCT s.customer_id) AS unique_customers,
    round(sum(s.total_amount), 2) AS total_revenue,
    round(avg(s.total_amount), 2) AS avg_order_value,
    round((sum(s.total_amount) / (NULLIF(count(DISTINCT s.sale_id), 0))::numeric), 2) AS revenue_per_order,
    count(DISTINCT e.employee_id) AS total_employees
   FROM ((public.branches b
     LEFT JOIN public.sales s ON (((b.branch_id = s.branch_id) AND ((s.status)::text = 'completed'::text))))
     LEFT JOIN public.employees e ON (((b.branch_id = e.branch_id) AND (e.is_active = true))))
  GROUP BY b.branch_id, b.branch_name, b.city, b.format
  ORDER BY (round(sum(s.total_amount), 2)) DESC;


ALTER TABLE public.v_branch_performance OWNER TO analytics;

--
-- Name: v_customer_insights; Type: VIEW; Schema: public; Owner: analytics
--

CREATE VIEW public.v_customer_insights AS
 SELECT c.customer_id,
    (((c.first_name)::text || ' '::text) || (c.last_name)::text) AS full_name,
    c.city,
    c.loyalty_status,
    c.registration_date,
    count(DISTINCT s.sale_id) AS total_orders,
    round(sum(s.total_amount), 2) AS total_spent,
    round(avg(s.total_amount), 2) AS avg_order_value,
    max(s.sale_date) AS last_purchase_date,
    EXTRACT(day FROM (now() - (max(s.sale_date))::timestamp with time zone)) AS days_since_last_purchase,
        CASE
            WHEN (count(DISTINCT s.sale_id) >= 10) THEN 'VIP'::text
            WHEN (count(DISTINCT s.sale_id) >= 5) THEN 'Active'::text
            WHEN (count(DISTINCT s.sale_id) >= 2) THEN 'Occasional'::text
            ELSE 'New'::text
        END AS customer_segment_auto
   FROM (public.customers c
     LEFT JOIN public.sales s ON (((c.customer_id = s.customer_id) AND ((s.status)::text = 'completed'::text))))
  GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.loyalty_status, c.registration_date
  ORDER BY (round(sum(s.total_amount), 2)) DESC;


ALTER TABLE public.v_customer_insights OWNER TO analytics;

--
-- Name: v_inventory; Type: VIEW; Schema: public; Owner: analytics
--

CREATE VIEW public.v_inventory AS
 SELECT b.branch_name,
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
            WHEN (i.stock_quantity < i.min_stock) THEN 'LOW'::text
            WHEN (i.stock_quantity > i.max_stock) THEN 'HIGH'::text
            ELSE 'OPTIMAL'::text
        END AS stock_status,
        CASE
            WHEN (i.stock_quantity < i.min_stock) THEN 'Критический минимум'::text
            WHEN (i.stock_quantity > i.max_stock) THEN 'Переизбыток'::text
            ELSE 'Норма'::text
        END AS stock_status_ru
   FROM (((public.inventory i
     JOIN public.branches b ON ((i.branch_id = b.branch_id)))
     JOIN public.products p ON ((i.product_id = p.product_id)))
     JOIN public.categories c ON ((p.category_id = c.category_id)));


ALTER TABLE public.v_inventory OWNER TO analytics;

--
-- Name: v_kpi_daily; Type: VIEW; Schema: public; Owner: analytics
--

CREATE VIEW public.v_kpi_daily AS
 SELECT s.sale_date,
    count(DISTINCT s.sale_id) AS total_orders,
    count(DISTINCT s.customer_id) AS unique_customers,
    round(sum(s.total_amount), 2) AS total_revenue,
    round(avg(s.total_amount), 2) AS avg_order_value,
    round((sum(s.total_amount) / (NULLIF(count(DISTINCT s.customer_id), 0))::numeric), 2) AS revenue_per_customer,
    round(avg(sd.quantity), 2) AS avg_items_per_order,
    round(sum(s.discount_amount), 2) AS total_discounts
   FROM (public.sales s
     JOIN public.sale_details sd ON ((s.sale_id = sd.sale_id)))
  WHERE ((s.status)::text = 'completed'::text)
  GROUP BY s.sale_date
  ORDER BY s.sale_date DESC;


ALTER TABLE public.v_kpi_daily OWNER TO analytics;

--
-- Name: v_kpi_monthly; Type: VIEW; Schema: public; Owner: analytics
--

CREATE VIEW public.v_kpi_monthly AS
 SELECT date_trunc('month'::text, (s.sale_date)::timestamp with time zone) AS month,
    EXTRACT(year FROM s.sale_date) AS year,
    EXTRACT(month FROM s.sale_date) AS month_num,
    count(DISTINCT s.sale_id) AS total_orders,
    count(DISTINCT s.customer_id) AS unique_customers,
    round(sum(s.total_amount), 2) AS total_revenue,
    round(avg(s.total_amount), 2) AS avg_order_value,
    round((sum(s.total_amount) / (NULLIF(count(DISTINCT s.customer_id), 0))::numeric), 2) AS revenue_per_customer
   FROM public.sales s
  WHERE ((s.status)::text = 'completed'::text)
  GROUP BY (date_trunc('month'::text, (s.sale_date)::timestamp with time zone)), (EXTRACT(year FROM s.sale_date)), (EXTRACT(month FROM s.sale_date))
  ORDER BY (date_trunc('month'::text, (s.sale_date)::timestamp with time zone)) DESC;


ALTER TABLE public.v_kpi_monthly OWNER TO analytics;

--
-- Name: v_product_performance; Type: VIEW; Schema: public; Owner: analytics
--

CREATE VIEW public.v_product_performance AS
 SELECT p.product_id,
    p.product_name,
    c.category_name,
    p.brand,
    count(DISTINCT sd.sale_id) AS sales_count,
    sum(sd.quantity) AS total_quantity_sold,
    round(sum(sd.total_price), 2) AS total_revenue,
    round(avg(sd.unit_price), 2) AS avg_selling_price,
    round((sum(sd.total_price) / (NULLIF(sum(sd.quantity), 0))::numeric), 2) AS avg_price_per_unit,
    count(DISTINCT s.branch_id) AS branches_sold
   FROM (((public.products p
     JOIN public.categories c ON ((p.category_id = c.category_id)))
     JOIN public.sale_details sd ON ((p.product_id = sd.product_id)))
     JOIN public.sales s ON ((sd.sale_id = s.sale_id)))
  WHERE ((s.status)::text = 'completed'::text)
  GROUP BY p.product_id, p.product_name, c.category_name, p.brand
  ORDER BY (round(sum(sd.total_price), 2)) DESC;


ALTER TABLE public.v_product_performance OWNER TO analytics;

--
-- Name: v_sales_analytics; Type: VIEW; Schema: public; Owner: analytics
--

CREATE VIEW public.v_sales_analytics AS
 SELECT s.sale_id,
    s.sale_date,
    s.sale_time,
    EXTRACT(year FROM s.sale_date) AS year,
    EXTRACT(month FROM s.sale_date) AS month,
    EXTRACT(dow FROM s.sale_date) AS day_of_week,
    b.branch_name,
    b.city,
    b.format AS branch_format,
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
    (((e.first_name)::text || ' '::text) || (e.last_name)::text) AS employee_name
   FROM ((((((public.sales s
     JOIN public.branches b ON ((s.branch_id = b.branch_id)))
     JOIN public.sale_details sd ON ((s.sale_id = sd.sale_id)))
     JOIN public.products p ON ((sd.product_id = p.product_id)))
     JOIN public.categories c ON ((p.category_id = c.category_id)))
     LEFT JOIN public.customers cu ON ((s.customer_id = cu.customer_id)))
     LEFT JOIN public.employees e ON ((s.employee_id = e.employee_id)));


ALTER TABLE public.v_sales_analytics OWNER TO analytics;

--
-- Name: work_schedule; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.work_schedule (
    schedule_id integer NOT NULL,
    employee_id integer,
    work_date date NOT NULL,
    start_time time without time zone,
    end_time time without time zone,
    shift_type character varying(20),
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT work_schedule_shift_type_check CHECK (((shift_type)::text = ANY ((ARRAY['morning'::character varying, 'evening'::character varying, 'night'::character varying])::text[])))
);


ALTER TABLE public.work_schedule OWNER TO analytics;

--
-- Name: work_schedule_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.work_schedule_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.work_schedule_schedule_id_seq OWNER TO analytics;

--
-- Name: work_schedule_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.work_schedule_schedule_id_seq OWNED BY public.work_schedule.schedule_id;


--
-- Name: branches branch_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.branches ALTER COLUMN branch_id SET DEFAULT nextval('public.branches_branch_id_seq'::regclass);


--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.employees ALTER COLUMN employee_id SET DEFAULT nextval('public.employees_employee_id_seq'::regclass);


--
-- Name: inventory inventory_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.inventory ALTER COLUMN inventory_id SET DEFAULT nextval('public.inventory_inventory_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- Name: promotions promo_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.promotions ALTER COLUMN promo_id SET DEFAULT nextval('public.promotions_promo_id_seq'::regclass);


--
-- Name: sale_details sale_detail_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sale_details ALTER COLUMN sale_detail_id SET DEFAULT nextval('public.sale_details_sale_detail_id_seq'::regclass);


--
-- Name: sales sale_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sales ALTER COLUMN sale_id SET DEFAULT nextval('public.sales_sale_id_seq'::regclass);


--
-- Name: sections section_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sections ALTER COLUMN section_id SET DEFAULT nextval('public.sections_section_id_seq'::regclass);


--
-- Name: suppliers supplier_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('public.suppliers_supplier_id_seq'::regclass);


--
-- Name: supplies supply_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.supplies ALTER COLUMN supply_id SET DEFAULT nextval('public.supplies_supply_id_seq'::regclass);


--
-- Name: supply_details supply_detail_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.supply_details ALTER COLUMN supply_detail_id SET DEFAULT nextval('public.supply_details_supply_detail_id_seq'::regclass);


--
-- Name: work_schedule schedule_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.work_schedule ALTER COLUMN schedule_id SET DEFAULT nextval('public.work_schedule_schedule_id_seq'::regclass);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (branch_id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: inventory inventory_branch_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_branch_id_product_id_key UNIQUE (branch_id, product_id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (inventory_id);


--
-- Name: products products_barcode_key; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_barcode_key UNIQUE (barcode);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: promotions promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (promo_id);


--
-- Name: sale_details sale_details_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sale_details
    ADD CONSTRAINT sale_details_pkey PRIMARY KEY (sale_detail_id);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (sale_id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (section_id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- Name: supplies supplies_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.supplies
    ADD CONSTRAINT supplies_pkey PRIMARY KEY (supply_id);


--
-- Name: supply_details supply_details_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.supply_details
    ADD CONSTRAINT supply_details_pkey PRIMARY KEY (supply_detail_id);


--
-- Name: work_schedule work_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.work_schedule
    ADD CONSTRAINT work_schedule_pkey PRIMARY KEY (schedule_id);


--
-- Name: idx_customers_city; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_customers_city ON public.customers USING btree (city);


--
-- Name: idx_customers_loyalty; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_customers_loyalty ON public.customers USING btree (loyalty_status);


--
-- Name: idx_inventory_branch_product; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_inventory_branch_product ON public.inventory USING btree (branch_id, product_id);


--
-- Name: idx_products_active; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_products_active ON public.products USING btree (is_active);


--
-- Name: idx_products_category; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_products_category ON public.products USING btree (category_id);


--
-- Name: idx_products_supplier; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_products_supplier ON public.products USING btree (supplier_id);


--
-- Name: idx_sale_details_product; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_sale_details_product ON public.sale_details USING btree (product_id);


--
-- Name: idx_sale_details_sale; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_sale_details_sale ON public.sale_details USING btree (sale_id);


--
-- Name: idx_sales_branch; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_sales_branch ON public.sales USING btree (branch_id);


--
-- Name: idx_sales_customer; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_sales_customer ON public.sales USING btree (customer_id);


--
-- Name: idx_sales_date; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_sales_date ON public.sales USING btree (sale_date);


--
-- Name: idx_sales_date_status; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_sales_date_status ON public.sales USING btree (sale_date, status);


--
-- Name: idx_sales_status; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_sales_status ON public.sales USING btree (status);


--
-- Name: idx_supplies_date; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_supplies_date ON public.supplies USING btree (supply_date);


--
-- Name: categories categories_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES public.categories(category_id);


--
-- Name: employees employees_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


--
-- Name: inventory inventory_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


--
-- Name: inventory inventory_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- Name: products products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id);


--
-- Name: promotions promotions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- Name: sale_details sale_details_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sale_details
    ADD CONSTRAINT sale_details_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: sale_details sale_details_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sale_details
    ADD CONSTRAINT sale_details_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(sale_id) ON DELETE CASCADE;


--
-- Name: sales sales_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


--
-- Name: sales sales_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: sales sales_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- Name: sections sections_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


--
-- Name: sections sections_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- Name: supplies supplies_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.supplies
    ADD CONSTRAINT supplies_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


--
-- Name: supplies supplies_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.supplies
    ADD CONSTRAINT supplies_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id);


--
-- Name: supply_details supply_details_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.supply_details
    ADD CONSTRAINT supply_details_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: supply_details supply_details_supply_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.supply_details
    ADD CONSTRAINT supply_details_supply_id_fkey FOREIGN KEY (supply_id) REFERENCES public.supplies(supply_id) ON DELETE CASCADE;


--
-- Name: work_schedule work_schedule_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.work_schedule
    ADD CONSTRAINT work_schedule_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- PostgreSQL database dump complete
--

\unrestrict a2UvZPoj81gtJrtBeQzlCgHFgnOayaUkxWimlTC16sNjV2WNIahLxfCVxED60pv

