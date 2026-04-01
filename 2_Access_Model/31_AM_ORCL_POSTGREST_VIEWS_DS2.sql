-- 31_AM_ORCL_POSTGREST_VIEWS_DS2.sql
-- Run as FDBO @ XEPDB1

--------------------------------------------------------------------------------
-- DS2: Oracle consumă REST API (PostgREST) și expune datele ca VIEW-uri în FDBO
-- Necesită:
--   1. PostgREST pornit la http://localhost:3000
--   2. ACL acordat pentru FDBO pe localhost:3000
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EMPLOYEES
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW DS2_EMPLOYEES_V AS
WITH rest_doc AS (
  SELECT HTTPURITYPE.createuri('http://localhost:3000/employees').getclob() AS doc
  FROM dual
)
SELECT
  employee_id,
  first_name,
  last_name,
  role,
  hire_date,
  status,
  depot_id
FROM JSON_TABLE(
  (SELECT doc FROM rest_doc),
  '$[*]'
  COLUMNS (
    employee_id NUMBER       PATH '$.employee_id',
    first_name  VARCHAR2(50) PATH '$.first_name',
    last_name   VARCHAR2(50) PATH '$.last_name',
    role        VARCHAR2(30) PATH '$.role',
    hire_date   VARCHAR2(20) PATH '$.hire_date',
    status      VARCHAR2(20) PATH '$.status',
    depot_id    NUMBER       PATH '$.depot_id'
  )
);

--------------------------------------------------------------------------------
-- DEPOTS
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW DS2_DEPOTS_V AS
WITH rest_doc AS (
  SELECT HTTPURITYPE.createuri('http://localhost:3000/depots').getclob() AS doc
  FROM dual
)
SELECT
  depot_id,
  depot_name,
  city,
  location
FROM JSON_TABLE(
  (SELECT doc FROM rest_doc),
  '$[*]'
  COLUMNS (
    depot_id    NUMBER        PATH '$.depot_id',
    depot_name  VARCHAR2(100) PATH '$.depot_name',
    city        VARCHAR2(60)  PATH '$.city',
    location    VARCHAR2(200) PATH '$.location'
  )
);

--------------------------------------------------------------------------------
-- VEHICLES
-- adăugăm vehicle_code pentru integrarea canonică
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW DS2_VEHICLES_V AS
WITH rest_doc AS (
  SELECT HTTPURITYPE.createuri('http://localhost:3000/vehicles').getclob() AS doc
  FROM dual
)
SELECT
  vehicle_id,
  vehicle_code,
  fleet_number,
  vehicle_type,
  capacity,
  status,
  depot_id
FROM JSON_TABLE(
  (SELECT doc FROM rest_doc),
  '$[*]'
  COLUMNS (
    vehicle_id    NUMBER        PATH '$.vehicle_id',
    vehicle_code  VARCHAR2(20)  PATH '$.vehicle_code',
    fleet_number  VARCHAR2(30)  PATH '$.fleet_number',
    vehicle_type  VARCHAR2(50)  PATH '$.vehicle_type',
    capacity      NUMBER        PATH '$.capacity',
    status        VARCHAR2(20)  PATH '$.status',
    depot_id      NUMBER        PATH '$.depot_id'
  )
);

--------------------------------------------------------------------------------
-- SHIFTS
-- line_id și route_id trebuie citite ca text, nu ca NUMBER
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW DS2_SHIFTS_V AS
WITH rest_doc AS (
  SELECT HTTPURITYPE.createuri('http://localhost:3000/shifts').getclob() AS doc
  FROM dual
)
SELECT
  shift_id,
  employee_id,
  vehicle_id,
  line_id,
  route_id,
  shift_start_ts,
  shift_end_ts,
  shift_type
FROM JSON_TABLE(
  (SELECT doc FROM rest_doc),
  '$[*]'
  COLUMNS (
    shift_id        NUMBER        PATH '$.shift_id',
    employee_id     NUMBER        PATH '$.employee_id',
    vehicle_id      NUMBER        PATH '$.vehicle_id',
    line_id         VARCHAR2(20)  PATH '$.line_id',
    route_id        VARCHAR2(20)  PATH '$.route_id',
    shift_start_ts  VARCHAR2(40)  PATH '$.shift_start_ts',
    shift_end_ts    VARCHAR2(40)  PATH '$.shift_end_ts',
    shift_type      VARCHAR2(30)  PATH '$.shift_type'
  )
);

--------------------------------------------------------------------------------
-- ATTENDANCE
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW DS2_ATTENDANCE_V AS
WITH rest_doc AS (
  SELECT HTTPURITYPE.createuri('http://localhost:3000/attendance').getclob() AS doc
  FROM dual
)
SELECT
  attendance_id,
  employee_id,
  work_date,
  status,
  hours_worked
FROM JSON_TABLE(
  (SELECT doc FROM rest_doc),
  '$[*]'
  COLUMNS (
    attendance_id  NUMBER        PATH '$.attendance_id',
    employee_id    NUMBER        PATH '$.employee_id',
    work_date      VARCHAR2(20)  PATH '$.work_date',
    status         VARCHAR2(20)  PATH '$.status',
    hours_worked   NUMBER        PATH '$.hours_worked'
  )
);

--------------------------------------------------------------------------------
-- VERIFICĂRI
--------------------------------------------------------------------------------
SELECT COUNT(*) AS cnt_employees   FROM DS2_EMPLOYEES_V;
SELECT COUNT(*) AS cnt_depots      FROM DS2_DEPOTS_V;
SELECT COUNT(*) AS cnt_vehicles    FROM DS2_VEHICLES_V;
SELECT COUNT(*) AS cnt_shifts      FROM DS2_SHIFTS_V;
SELECT COUNT(*) AS cnt_attendance  FROM DS2_ATTENDANCE_V;

SELECT * FROM DS2_EMPLOYEES_V;
SELECT * FROM DS2_VEHICLES_V;
SELECT * FROM DS2_SHIFTS_V;
SELECT * FROM DS2_ATTENDANCE_V;