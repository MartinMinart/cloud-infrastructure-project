--
-- PostgreSQL database dump
--

\restrict xBaKLtBljxPEfPljazc03dsYKmbZUe0MD1aDudgiZ4GzXKBf1pNfKpzZUASCf2t

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
-- Name: appointments; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.appointments (
    appointment_id bigint NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    branch_id integer NOT NULL,
    service_id integer NOT NULL,
    scheduled_at timestamp without time zone NOT NULL,
    appointment_date date GENERATED ALWAYS AS ((scheduled_at)::date) STORED,
    status character varying(20) NOT NULL,
    visit_duration_min integer,
    source character varying(30) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT appointments_check CHECK (((((status)::text = 'completed'::text) AND (visit_duration_min IS NOT NULL)) OR ((status)::text <> 'completed'::text))),
    CONSTRAINT appointments_status_check CHECK (((status)::text = ANY ((ARRAY['completed'::character varying, 'scheduled'::character varying, 'cancelled'::character varying, 'no_show'::character varying])::text[])))
);


ALTER TABLE public.appointments OWNER TO analytics;

--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.appointments_appointment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.appointments_appointment_id_seq OWNER TO analytics;

--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.appointments_appointment_id_seq OWNED BY public.appointments.appointment_id;


--
-- Name: branches; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.branches (
    branch_id integer NOT NULL,
    branch_name character varying(100) NOT NULL,
    city character varying(100) NOT NULL,
    district character varying(100),
    opened_at date NOT NULL,
    is_active boolean DEFAULT true NOT NULL
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
-- Name: departments; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.departments (
    department_id integer NOT NULL,
    department_name character varying(100) NOT NULL
);


ALTER TABLE public.departments OWNER TO analytics;

--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.departments_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departments_department_id_seq OWNER TO analytics;

--
-- Name: departments_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.departments_department_id_seq OWNED BY public.departments.department_id;


--
-- Name: doctors; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.doctors (
    doctor_id integer NOT NULL,
    doctor_name character varying(150) NOT NULL,
    department_id integer NOT NULL,
    branch_id integer NOT NULL,
    hire_date date NOT NULL,
    experience_years integer NOT NULL,
    qualification character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT doctors_experience_years_check CHECK (((experience_years >= 0) AND (experience_years <= 45)))
);


ALTER TABLE public.doctors OWNER TO analytics;

--
-- Name: doctors_doctor_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.doctors_doctor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.doctors_doctor_id_seq OWNER TO analytics;

--
-- Name: doctors_doctor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.doctors_doctor_id_seq OWNED BY public.doctors.doctor_id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.patients (
    patient_id integer NOT NULL,
    patient_name character varying(150) NOT NULL,
    birth_date date NOT NULL,
    gender character(1) NOT NULL,
    city character varying(100) NOT NULL,
    registration_date date NOT NULL,
    insurance_type character varying(30) NOT NULL,
    CONSTRAINT patients_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar])))
);


ALTER TABLE public.patients OWNER TO analytics;

--
-- Name: patients_patient_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.patients_patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patients_patient_id_seq OWNER TO analytics;

--
-- Name: patients_patient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.patients_patient_id_seq OWNED BY public.patients.patient_id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    appointment_id bigint NOT NULL,
    payment_date timestamp without time zone NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_method character varying(30) NOT NULL,
    payment_status character varying(20) NOT NULL,
    CONSTRAINT payments_amount_check CHECK ((amount >= (0)::numeric)),
    CONSTRAINT payments_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['paid'::character varying, 'refunded'::character varying, 'pending'::character varying])::text[])))
);


ALTER TABLE public.payments OWNER TO analytics;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payments_payment_id_seq OWNER TO analytics;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.payments_payment_id_seq OWNED BY public.payments.payment_id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: analytics
--

CREATE TABLE public.services (
    service_id integer NOT NULL,
    service_name character varying(150) NOT NULL,
    department_id integer NOT NULL,
    base_price numeric(10,2) NOT NULL,
    CONSTRAINT services_base_price_check CHECK ((base_price >= (0)::numeric))
);


ALTER TABLE public.services OWNER TO analytics;

--
-- Name: services_service_id_seq; Type: SEQUENCE; Schema: public; Owner: analytics
--

CREATE SEQUENCE public.services_service_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.services_service_id_seq OWNER TO analytics;

--
-- Name: services_service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: analytics
--

ALTER SEQUENCE public.services_service_id_seq OWNED BY public.services.service_id;


--
-- Name: appointments appointment_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.appointments ALTER COLUMN appointment_id SET DEFAULT nextval('public.appointments_appointment_id_seq'::regclass);


--
-- Name: branches branch_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.branches ALTER COLUMN branch_id SET DEFAULT nextval('public.branches_branch_id_seq'::regclass);


--
-- Name: departments department_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.departments ALTER COLUMN department_id SET DEFAULT nextval('public.departments_department_id_seq'::regclass);


--
-- Name: doctors doctor_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.doctors ALTER COLUMN doctor_id SET DEFAULT nextval('public.doctors_doctor_id_seq'::regclass);


--
-- Name: patients patient_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.patients ALTER COLUMN patient_id SET DEFAULT nextval('public.patients_patient_id_seq'::regclass);


--
-- Name: payments payment_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.payments ALTER COLUMN payment_id SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);


--
-- Name: services service_id; Type: DEFAULT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.services ALTER COLUMN service_id SET DEFAULT nextval('public.services_service_id_seq'::regclass);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (appointment_id);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (branch_id);


--
-- Name: departments departments_department_name_key; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_department_name_key UNIQUE (department_name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (doctor_id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (patient_id);


--
-- Name: payments payments_appointment_id_key; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_appointment_id_key UNIQUE (appointment_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (service_id);


--
-- Name: idx_appointments_branch_date; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_appointments_branch_date ON public.appointments USING btree (branch_id, scheduled_at);


--
-- Name: idx_appointments_date; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_appointments_date ON public.appointments USING btree (scheduled_at);


--
-- Name: idx_appointments_doctor_date; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_appointments_doctor_date ON public.appointments USING btree (doctor_id, scheduled_at);


--
-- Name: idx_appointments_patient; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_appointments_patient ON public.appointments USING btree (patient_id);


--
-- Name: idx_appointments_status; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_appointments_status ON public.appointments USING btree (status);


--
-- Name: idx_doctors_branch; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_doctors_branch ON public.doctors USING btree (branch_id);


--
-- Name: idx_doctors_department; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_doctors_department ON public.doctors USING btree (department_id);


--
-- Name: idx_payments_date; Type: INDEX; Schema: public; Owner: analytics
--

CREATE INDEX idx_payments_date ON public.payments USING btree (payment_date);


--
-- Name: appointments appointments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


--
-- Name: appointments appointments_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(doctor_id);


--
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(patient_id);


--
-- Name: appointments appointments_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id);


--
-- Name: doctors doctors_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


--
-- Name: doctors doctors_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: payments payments_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id);


--
-- Name: services services_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: analytics
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- PostgreSQL database dump complete
--

\unrestrict xBaKLtBljxPEfPljazc03dsYKmbZUe0MD1aDudgiZ4GzXKBf1pNfKpzZUASCf2t

