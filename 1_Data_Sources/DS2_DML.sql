-- DS2_DML.sql
-- Database: PTS_DS2
-- Schema: operationshr
-- Varianta extinsă, compatibilă cu identificatorii standardizați

SET search_path TO operationshr;

--------------------------------------------------------------------------------
-- Curățare date existente, în ordinea corectă a FK-urilor
--------------------------------------------------------------------------------
DELETE FROM attendance;
DELETE FROM shifts;
DELETE FROM vehicles;
DELETE FROM employees;
DELETE FROM depots;

--------------------------------------------------------------------------------
-- Depots
--------------------------------------------------------------------------------
INSERT INTO depots (depot_id, depot_name, city, location)
VALUES (10, 'Depou Copou', 'Iasi', 'Copou');

INSERT INTO depots (depot_id, depot_name, city, location)
VALUES (20, 'Depou Tatarasi', 'Iasi', 'Tatarasi');

INSERT INTO depots (depot_id, depot_name, city, location)
VALUES (30, 'Depou Nicolina', 'Iasi', 'Nicolina');

--------------------------------------------------------------------------------
-- Employees
--------------------------------------------------------------------------------
INSERT INTO employees (employee_id, first_name, last_name, role, hire_date, status, depot_id)
VALUES (101, 'Ion', 'Popescu', 'driver', DATE '2022-03-01', 'active', 10);

INSERT INTO employees (employee_id, first_name, last_name, role, hire_date, status, depot_id)
VALUES (102, 'Maria', 'Ionescu', 'dispatcher', DATE '2021-10-15', 'active', 20);

INSERT INTO employees (employee_id, first_name, last_name, role, hire_date, status, depot_id)
VALUES (103, 'Andrei', 'Vasilescu', 'technician', DATE '2020-06-20', 'on_leave', 30);

INSERT INTO employees (employee_id, first_name, last_name, role, hire_date, status, depot_id)
VALUES (104, 'Elena', 'Matei', 'controller', DATE '2023-01-05', 'active', 10);

INSERT INTO employees (employee_id, first_name, last_name, role, hire_date, status, depot_id)
VALUES (105, 'Radu', 'Georgescu', 'driver', DATE '2022-09-12', 'active', 20);

INSERT INTO employees (employee_id, first_name, last_name, role, hire_date, status, depot_id)
VALUES (106, 'Bianca', 'Dumitru', 'driver', DATE '2024-02-18', 'active', 30);

INSERT INTO employees (employee_id, first_name, last_name, role, hire_date, status, depot_id)
VALUES (107, 'Sorin', 'Enache', 'dispatcher', DATE '2021-04-11', 'active', 10);

INSERT INTO employees (employee_id, first_name, last_name, role, hire_date, status, depot_id)
VALUES (108, 'Cristina', 'Ilie', 'technician', DATE '2023-07-01', 'active', 20);

--------------------------------------------------------------------------------
-- Vehicles
-- vehicle_id = cheia internă PostgreSQL
-- vehicle_code = codul comun de integrare cu Oracle / JSON / Neo4j
--------------------------------------------------------------------------------
INSERT INTO vehicles (vehicle_id, fleet_number, vehicle_code, vehicle_type, capacity, status, depot_id)
VALUES (1001, 'BUS-0123', 'V001', 'bus', 80, 'operational', 10);

INSERT INTO vehicles (vehicle_id, fleet_number, vehicle_code, vehicle_type, capacity, status, depot_id)
VALUES (1002, 'TRAM-004', 'V002', 'tram', 140, 'maintenance', 20);

INSERT INTO vehicles (vehicle_id, fleet_number, vehicle_code, vehicle_type, capacity, status, depot_id)
VALUES (1003, 'BUS-0456', 'V010', 'bus', 75, 'operational', 30);

INSERT INTO vehicles (vehicle_id, fleet_number, vehicle_code, vehicle_type, capacity, status, depot_id)
VALUES (1004, 'BUS-0788', 'V011', 'bus', 85, 'operational', 10);

INSERT INTO vehicles (vehicle_id, fleet_number, vehicle_code, vehicle_type, capacity, status, depot_id)
VALUES (1005, 'TRAM-009', 'V012', 'tram', 150, 'operational', 20);

--------------------------------------------------------------------------------
-- Shifts
-- line_id și route_id sunt acum text și folosesc formatul canonic:
-- L001, L002, L003 / R001, R003, R005
--------------------------------------------------------------------------------
INSERT INTO shifts
(shift_id, employee_id, vehicle_id, line_id, route_id, shift_start_ts, shift_end_ts, shift_type)
VALUES
(50001, 101, 1001, 'L001', 'R001',
 TIMESTAMP '2026-03-03 06:00:00', TIMESTAMP '2026-03-03 14:00:00', 'morning');

INSERT INTO shifts
(shift_id, employee_id, vehicle_id, line_id, route_id, shift_start_ts, shift_end_ts, shift_type)
VALUES
(50002, 104, NULL, 'L001', 'R001',
 TIMESTAMP '2026-03-03 08:00:00', TIMESTAMP '2026-03-03 16:00:00', 'control');

INSERT INTO shifts
(shift_id, employee_id, vehicle_id, line_id, route_id, shift_start_ts, shift_end_ts, shift_type)
VALUES
(50003, 105, 1003, 'L002', 'R003',
 TIMESTAMP '2026-03-03 14:00:00', TIMESTAMP '2026-03-03 22:00:00', 'evening');

INSERT INTO shifts
(shift_id, employee_id, vehicle_id, line_id, route_id, shift_start_ts, shift_end_ts, shift_type)
VALUES
(50004, 106, 1002, 'L003', 'R005',
 TIMESTAMP '2026-03-04 05:30:00', TIMESTAMP '2026-03-04 13:30:00', 'morning');

INSERT INTO shifts
(shift_id, employee_id, vehicle_id, line_id, route_id, shift_start_ts, shift_end_ts, shift_type)
VALUES
(50005, 101, 1001, 'L001', 'R001',
 TIMESTAMP '2026-03-04 14:00:00', TIMESTAMP '2026-03-04 22:00:00', 'evening');

INSERT INTO shifts
(shift_id, employee_id, vehicle_id, line_id, route_id, shift_start_ts, shift_end_ts, shift_type)
VALUES
(50006, 107, NULL, 'L002', 'R003',
 TIMESTAMP '2026-03-04 07:00:00', TIMESTAMP '2026-03-04 15:00:00', 'dispatch');

INSERT INTO shifts
(shift_id, employee_id, vehicle_id, line_id, route_id, shift_start_ts, shift_end_ts, shift_type)
VALUES
(50007, 105, 1004, 'L002', 'R003',
 TIMESTAMP '2026-03-05 06:00:00', TIMESTAMP '2026-03-05 14:00:00', 'morning');

INSERT INTO shifts
(shift_id, employee_id, vehicle_id, line_id, route_id, shift_start_ts, shift_end_ts, shift_type)
VALUES
(50008, 106, 1005, 'L003', 'R005',
 TIMESTAMP '2026-03-05 13:00:00', TIMESTAMP '2026-03-05 21:00:00', 'evening');

--------------------------------------------------------------------------------
-- Attendance
--------------------------------------------------------------------------------
INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90001, 101, DATE '2026-03-03', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90002, 102, DATE '2026-03-03', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90003, 103, DATE '2026-03-03', 'medical_leave', NULL);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90004, 104, DATE '2026-03-03', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90005, 105, DATE '2026-03-03', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90006, 106, DATE '2026-03-04', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90007, 107, DATE '2026-03-04', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90008, 108, DATE '2026-03-04', 'vacation', NULL);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90009, 101, DATE '2026-03-05', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90010, 105, DATE '2026-03-05', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90011, 106, DATE '2026-03-05', 'present', 8.00);

INSERT INTO attendance (attendance_id, employee_id, work_date, status, hours_worked)
VALUES (90012, 108, DATE '2026-03-05', 'present', 8.00);

--------------------------------------------------------------------------------
-- Verificări
--------------------------------------------------------------------------------
SELECT * FROM depots;
SELECT * FROM employees;
SELECT * FROM vehicles;
SELECT * FROM shifts;
SELECT * FROM attendance;

--------------------------------------------------------------------------------
-- Verificări utile pentru integrare
--------------------------------------------------------------------------------
SELECT line_id, COUNT(*) AS shifts_per_line
FROM shifts
GROUP BY line_id
ORDER BY line_id;

SELECT route_id, COUNT(*) AS shifts_per_route
FROM shifts
GROUP BY route_id
ORDER BY route_id;

SELECT vehicle_id, COUNT(*) AS shifts_per_vehicle
FROM shifts
GROUP BY vehicle_id
ORDER BY vehicle_id;