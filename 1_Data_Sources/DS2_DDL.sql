-- DS2_DDL.sql
-- Database: PTS_DS2
-- Schema: operationshr
-- Varianta corectată pentru identificatori standardizați

SET search_path TO operationshr;

-- 1. Se șterg întâi view-urile din schema api, deoarece depind de tabelele din operationshr
DROP VIEW IF EXISTS api.attendance;
DROP VIEW IF EXISTS api.shifts;
DROP VIEW IF EXISTS api.vehicles;
DROP VIEW IF EXISTS api.employees;
DROP VIEW IF EXISTS api.depots;

-- 2. Se șterg tabelele din operationshr
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS shifts;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS depots;

CREATE TABLE depots (
  depot_id NUMERIC(6)
    CONSTRAINT pk_depots PRIMARY KEY
    CONSTRAINT ck_depot_id CHECK (depot_id > 0),
  depot_name VARCHAR(60)
    CONSTRAINT nn_depot_name NOT NULL,
  city VARCHAR(50)
    CONSTRAINT nn_depot_city NOT NULL,
  location VARCHAR(80)
);

CREATE TABLE employees (
  employee_id NUMERIC(8)
    CONSTRAINT pk_employees PRIMARY KEY
    CONSTRAINT ck_employee_id CHECK (employee_id > 0),
  first_name VARCHAR(30)
    CONSTRAINT nn_emp_first_name NOT NULL,
  last_name VARCHAR(30)
    CONSTRAINT nn_emp_last_name NOT NULL,
  role VARCHAR(20)
    CONSTRAINT ck_emp_role CHECK (role IN ('driver','dispatcher','technician','controller')),
  hire_date DATE
    CONSTRAINT nn_emp_hire_date NOT NULL,
  status VARCHAR(20)
    CONSTRAINT ck_emp_status CHECK (status IN ('active','on_leave','suspended','resigned')),
  depot_id NUMERIC(6)
    CONSTRAINT fk_emp_depot REFERENCES depots(depot_id)
);

CREATE TABLE vehicles (
  vehicle_id NUMERIC(8)
    CONSTRAINT pk_vehicles PRIMARY KEY
    CONSTRAINT ck_vehicle_id CHECK (vehicle_id > 0),
  fleet_number VARCHAR(20)
    CONSTRAINT nn_fleet_number NOT NULL
    CONSTRAINT uq_fleet_number UNIQUE,
  vehicle_code VARCHAR(20)
    CONSTRAINT nn_vehicle_code NOT NULL
    CONSTRAINT uq_vehicle_code UNIQUE,
  vehicle_type VARCHAR(10)
    CONSTRAINT ck_vehicle_type CHECK (vehicle_type IN ('bus','tram')),
  capacity NUMERIC(4)
    CONSTRAINT ck_capacity CHECK (capacity IS NULL OR capacity > 0),
  status VARCHAR(20)
    CONSTRAINT ck_vehicle_status CHECK (status IN ('operational','maintenance','retired')),
  depot_id NUMERIC(6)
    CONSTRAINT fk_veh_depot REFERENCES depots(depot_id)
);

CREATE TABLE shifts (
  shift_id NUMERIC(10)
    CONSTRAINT pk_shifts PRIMARY KEY
    CONSTRAINT ck_shift_id CHECK (shift_id > 0),
  employee_id NUMERIC(8)
    CONSTRAINT fk_shift_emp REFERENCES employees(employee_id),
  vehicle_id NUMERIC(8)
    CONSTRAINT fk_shift_vehicle REFERENCES vehicles(vehicle_id),
  line_id VARCHAR(20),
  route_id VARCHAR(20),
  shift_start_ts TIMESTAMP
    CONSTRAINT nn_shift_start NOT NULL,
  shift_end_ts TIMESTAMP
    CONSTRAINT nn_shift_end NOT NULL,
  shift_type VARCHAR(20),
  CONSTRAINT ck_shift_time CHECK (shift_end_ts >= shift_start_ts)
);

CREATE TABLE attendance (
  attendance_id NUMERIC(10)
    CONSTRAINT pk_attendance PRIMARY KEY
    CONSTRAINT ck_att_id CHECK (attendance_id > 0),
  employee_id NUMERIC(8)
    CONSTRAINT fk_att_emp REFERENCES employees(employee_id),
  work_date DATE
    CONSTRAINT nn_work_date NOT NULL,
  status VARCHAR(20)
    CONSTRAINT ck_att_status CHECK (status IN ('present','absent','medical_leave','vacation')),
  hours_worked NUMERIC(4,2)
    CONSTRAINT ck_hours CHECK (hours_worked IS NULL OR (hours_worked >= 0 AND hours_worked <= 24))
);


SET search_path TO operationshr;

SELECT * FROM depots;
SELECT * FROM employees;
SELECT * FROM vehicles;
SELECT * FROM shifts;
SELECT * FROM attendance;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'operationshr'
ORDER BY table_name;