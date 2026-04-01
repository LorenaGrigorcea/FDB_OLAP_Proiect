-- 25_PG_POSTGREST_API_Views_DS2.sql
-- Database: PTS_DS2

CREATE SCHEMA IF NOT EXISTS api;

--------------------------------------------------------------------------------
-- DEPOTS
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW api.depots AS
SELECT 
    depot_id,
    depot_name,
    city,
    location
FROM operationshr.depots;

--------------------------------------------------------------------------------
-- EMPLOYEES
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW api.employees AS
SELECT
    employee_id,
    first_name,
    last_name,
    role,
    hire_date,
    status,
    depot_id
FROM operationshr.employees;

--------------------------------------------------------------------------------
-- VEHICLES
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW api.vehicles AS
SELECT
    vehicle_id,
    vehicle_code,      -- important pentru integrarea cu Oracle / Neo4j
    fleet_number,
    vehicle_type,
    capacity,
    status,
    depot_id
FROM operationshr.vehicles;

--------------------------------------------------------------------------------
-- SHIFTS
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW api.shifts AS
SELECT
    shift_id,
    employee_id,
    vehicle_id,
    line_id,
    route_id,
    shift_start_ts,
    shift_end_ts,
    shift_type
FROM operationshr.shifts;

--------------------------------------------------------------------------------
-- ATTENDANCE
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW api.attendance AS
SELECT
    attendance_id,
    employee_id,
    work_date,
    status,
    hours_worked
FROM operationshr.attendance;

--------------------------------------------------------------------------------
-- PERMISSIONS pentru PostgREST
--------------------------------------------------------------------------------
GRANT USAGE ON SCHEMA api TO pgr_anon;

GRANT SELECT ON ALL TABLES IN SCHEMA api TO pgr_anon;

ALTER DEFAULT PRIVILEGES
IN SCHEMA api
GRANT SELECT ON TABLES TO pgr_anon;

--------------------------------------------------------------------------------
-- Test
--------------------------------------------------------------------------------
SELECT * FROM api.employees;
SELECT * FROM api.vehicles;
SELECT * FROM api.shifts;