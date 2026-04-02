--------------------------------------------------------------------------------
-- OLAP_PUBLIC_TRANSPORT_ANALYTICAL.sql
-- Creeaza stratul analitic ROLAP pentru proiectul Public Transport System.
-- source views -> dimensions -> facts -> analytical views
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Verificare source views existente
--------------------------------------------------------------------------------
SELECT COUNT(*) AS cnt_ticket_sales FROM v_ticket_sales;
SELECT COUNT(*) AS cnt_ticket_validations FROM v_ticket_validations;
SELECT COUNT(*) AS cnt_ticket_types FROM v_ticket_types;

SELECT COUNT(*) AS cnt_ds3_lines FROM ds3_lines_v;
SELECT COUNT(*) AS cnt_ds3_routes FROM ds3_routes_v;
SELECT COUNT(*) AS cnt_ds3_stops FROM ds3_stops_v;

SELECT COUNT(*) AS cnt_ds2_vehicles FROM ds2_vehicles_v;
SELECT COUNT(*) AS cnt_ds2_depots FROM ds2_depots_v;

SELECT COUNT(*) AS cnt_incidents FROM incidents_view;
SELECT COUNT(*) AS cnt_telemetry FROM telemetry_logs_view;

--------------------------------------------------------------------------------
-- 1. Dimensions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 1.1 OLAP_DIM_TIME
-- Dimensiune calendar obtinuta din toate sursele relevante care contin date/timp
--------------------------------------------------------------------------------
DROP VIEW olap_dim_time;

CREATE OR REPLACE VIEW olap_dim_time AS
SELECT DISTINCT
       full_date,
       EXTRACT(YEAR  FROM full_date) AS year_no,
       EXTRACT(MONTH FROM full_date) AS month_no,
       EXTRACT(DAY   FROM full_date) AS day_no
FROM (
    SELECT TRUNC(purchase_date) AS full_date
    FROM v_ticket_sales

    UNION

    SELECT TRUNC(validation_ts) AS full_date
    FROM v_ticket_validations

    UNION

    SELECT TRUNC(TO_TIMESTAMP(created_ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date
    FROM incidents_view

    UNION

    SELECT TRUNC(TO_TIMESTAMP(ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date
    FROM telemetry_logs_view
)
WHERE full_date IS NOT NULL
;

SELECT *
FROM olap_dim_time
ORDER BY full_date;

--------------------------------------------------------------------------------
-- 1.2 OLAP_DIM_TICKET
-- Dimensiune pentru tipurile de bilete
--------------------------------------------------------------------------------
DROP VIEW olap_dim_ticket;

CREATE OR REPLACE VIEW olap_dim_ticket AS
SELECT
    t.ticket_type_id,
    t.ticket_name,
    t.base_price,
    t.validity_minutes,
    t.validity_days,
    CASE
        WHEN t.validity_minutes IS NOT NULL THEN 'MINUTES'
        WHEN t.validity_days IS NOT NULL THEN 'DAYS'
        ELSE 'UNKNOWN'
    END AS validity_unit,
    CASE
        WHEN t.validity_minutes IS NOT NULL THEN t.validity_minutes
        WHEN t.validity_days IS NOT NULL THEN t.validity_days
        ELSE NULL
    END AS validity_value
FROM v_ticket_types t
;

SELECT *
FROM olap_dim_ticket
ORDER BY ticket_type_id;

--------------------------------------------------------------------------------
-- 1.3 OLAP_DIM_SALES_AREA
-- Dimensiune pentru aria de vanzare
--------------------------------------------------------------------------------
DROP VIEW olap_dim_sales_area;

CREATE OR REPLACE VIEW olap_dim_sales_area AS
SELECT DISTINCT
    s.city,
    s.zone
FROM v_ticket_sales s
;

SELECT *
FROM olap_dim_sales_area
ORDER BY city, zone;

--------------------------------------------------------------------------------
-- 1.4 OLAP_DIM_CUSTOMER_CATEGORY
-- Dimensiune pentru politica tarifara si categoria clientului
--------------------------------------------------------------------------------
DROP VIEW olap_dim_customer_category;

CREATE OR REPLACE VIEW olap_dim_customer_category AS
SELECT DISTINCT
    CASE
        WHEN s.customer_category = 'standard' THEN 'STANDARD_FARE'
        WHEN s.customer_category = 'student' THEN 'REDUCED_FARE'
        WHEN s.customer_category IN ('elev', 'pensionar') THEN 'SOCIAL_FARE'
        ELSE 'OTHER_FARE'
    END AS fare_policy,
    s.customer_category
FROM v_ticket_sales s
;

SELECT *
FROM olap_dim_customer_category
ORDER BY fare_policy, customer_category;

--------------------------------------------------------------------------------
-- 1.5 OLAP_DIM_NETWORK_VEHICLE
-- Dimensiune integrata pentru retea si vehicul, construita pe baza
-- cheilor de integrare folosite deja in validari
--------------------------------------------------------------------------------
DROP VIEW olap_dim_network_vehicle;

CREATE OR REPLACE VIEW olap_dim_network_vehicle AS
SELECT DISTINCT
    fv.line_id,
    l.display_name AS line_name,
    l.line_mode,
    fv.route_id,
    r.direction,
    fv.stop_id,
    s.stop_name,
    s.area AS stop_area,
    s.shared_core,
    fv.vehicle_id,
    v.vehicle_code,
    v.fleet_number,
    v.vehicle_type,
    v.capacity,
    v.status AS vehicle_status,
    d.depot_id,
    d.depot_name,
    d.city AS depot_city,
    d.location AS depot_location
FROM (
    SELECT DISTINCT
        line_id,
        route_id,
        stop_id,
        vehicle_id
    FROM v_ticket_validations
) fv
LEFT JOIN ds3_lines_v    l ON fv.line_id    = l.line_id
LEFT JOIN ds3_routes_v   r ON fv.route_id   = r.route_id
LEFT JOIN ds3_stops_v    s ON fv.stop_id    = s.stop_id
LEFT JOIN ds2_vehicles_v v ON fv.vehicle_id = v.vehicle_code
LEFT JOIN ds2_depots_v   d ON v.depot_id    = d.depot_id
;

SELECT *
FROM olap_dim_network_vehicle
ORDER BY line_id, route_id, stop_id, vehicle_id;

--------------------------------------------------------------------------------
-- 2. Facts
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 2.1 OLAP_FACTS_TICKET_SALES
-- Fact view central pentru vanzarile de bilete si abonamente
-- Se foloseste o mapare DISTINCT order_id -> ticket_type_id pentru a evita
-- dublarea vanzarilor daca exista mai multe validari pentru aceeasi comanda.
--------------------------------------------------------------------------------
DROP VIEW olap_facts_ticket_sales;

CREATE OR REPLACE VIEW olap_facts_ticket_sales AS
SELECT
    TRUNC(s.purchase_date) AS full_date,
    v.ticket_type_id,
    s.city,
    s.zone,
    s.customer_category,
    COUNT(*) AS sales_count,
    SUM(NVL(s.amount_paid, 0)) AS total_amount_paid
FROM v_ticket_sales s
INNER JOIN (
    SELECT DISTINCT
        order_id,
        ticket_type_id
    FROM v_ticket_validations
) v
    ON s.order_id = v.order_id
GROUP BY
    TRUNC(s.purchase_date),
    v.ticket_type_id,
    s.city,
    s.zone,
    s.customer_category
;

SELECT *
FROM olap_facts_ticket_sales
ORDER BY full_date, ticket_type_id, city, zone, customer_category;

--------------------------------------------------------------------------------
-- 3. Analytical Views
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 3.1 OLAP_VIEW_SALES_CALENDAR
-- Analiza vanzarilor pe calendar, cu subtotaluri pe zi / luna / an
-- Clauze folosite: ROLLUP, GROUPING, SUM, AVG derivat
--------------------------------------------------------------------------------
DROP VIEW olap_view_sales_calendar;

CREATE OR REPLACE VIEW olap_view_sales_calendar AS
SELECT
    CASE
        WHEN GROUPING(d.year_no) = 1 THEN '{Total General}'
        ELSE TO_CHAR(d.year_no)
    END AS year_no,
    CASE
        WHEN GROUPING(d.year_no) = 1 THEN ' '
        WHEN GROUPING(d.month_no) = 1 THEN 'subtotal an ' || TO_CHAR(d.year_no)
        ELSE TO_CHAR(d.month_no)
    END AS month_no,
    CASE
        WHEN GROUPING(d.year_no) = 1 THEN ' '
        WHEN GROUPING(d.month_no) = 1 THEN ' '
        WHEN GROUPING(d.day_no) = 1 THEN 'subtotal luna ' || TO_CHAR(d.month_no)
        ELSE TO_CHAR(d.day_no)
    END AS day_no,
    SUM(NVL(f.sales_count, 0)) AS sales_count,
    SUM(NVL(f.total_amount_paid, 0)) AS total_amount_paid,
    ROUND(
        SUM(NVL(f.total_amount_paid, 0)) /
        NULLIF(SUM(NVL(f.sales_count, 0)), 0),
        2
    ) AS avg_amount_per_sale
FROM olap_dim_time d
INNER JOIN olap_facts_ticket_sales f
    ON d.full_date = f.full_date
GROUP BY ROLLUP(d.year_no, d.month_no, d.day_no)
ORDER BY d.year_no, d.month_no, d.day_no
;

SELECT *
FROM olap_view_sales_calendar;

--------------------------------------------------------------------------------
-- 3.2 OLAP_VIEW_SALES_TICKET
-- Analiza vanzarilor pe tip de bilet
-- Clauze folosite: GROUP BY, SUM, AVG derivat
--------------------------------------------------------------------------------
DROP VIEW olap_view_sales_ticket;

CREATE OR REPLACE VIEW olap_view_sales_ticket AS
SELECT
    d.ticket_name,
    SUM(NVL(f.sales_count, 0)) AS sales_count,
    SUM(NVL(f.total_amount_paid, 0)) AS total_amount_paid,
    ROUND(
        SUM(NVL(f.total_amount_paid, 0)) /
        NULLIF(SUM(NVL(f.sales_count, 0)), 0),
        2
    ) AS avg_amount_per_sale
FROM olap_dim_ticket d
INNER JOIN olap_facts_ticket_sales f
    ON d.ticket_type_id = f.ticket_type_id
GROUP BY d.ticket_name
ORDER BY d.ticket_name
;

SELECT *
FROM olap_view_sales_ticket;

--------------------------------------------------------------------------------
-- 3.3 OLAP_VIEW_SALES_CUSTOMER_CATEGORY
-- Analiza vanzarilor pe politica tarifara si categoria clientului
-- Clauze folosite: ROLLUP, GROUPING, SUM, AVG derivat
--------------------------------------------------------------------------------
DROP VIEW olap_view_sales_customer_category;

CREATE OR REPLACE VIEW olap_view_sales_customer_category AS
SELECT
    CASE
        WHEN GROUPING(d.fare_policy) = 1 THEN '{Total General}'
        ELSE d.fare_policy
    END AS fare_policy,
    CASE
        WHEN GROUPING(d.fare_policy) = 1 THEN ' '
        WHEN GROUPING(d.customer_category) = 1 THEN 'subtotal politica ' || d.fare_policy
        ELSE d.customer_category
    END AS customer_category,
    SUM(NVL(f.sales_count, 0)) AS sales_count,
    SUM(NVL(f.total_amount_paid, 0)) AS total_amount_paid,
    ROUND(
        SUM(NVL(f.total_amount_paid, 0)) /
        NULLIF(SUM(NVL(f.sales_count, 0)), 0),
        2
    ) AS avg_amount_per_sale
FROM olap_dim_customer_category d
INNER JOIN olap_facts_ticket_sales f
    ON d.customer_category = f.customer_category
GROUP BY ROLLUP(d.fare_policy, d.customer_category)
ORDER BY d.fare_policy, d.customer_category
;

SELECT *
FROM olap_view_sales_customer_category;

--------------------------------------------------------------------------------
-- 3.4 OLAP_VIEW_SALES_TICKET_AREA_CUBE
-- Analiza vanzarilor pe tip de bilet si zona, folosind CUBE
-- Clauze folosite: CUBE, GROUPING, SUM, AVG derivat
--------------------------------------------------------------------------------
DROP VIEW olap_view_sales_ticket_area_cube;

CREATE OR REPLACE VIEW olap_view_sales_ticket_area_cube AS
SELECT
    CASE
        WHEN GROUPING(t.ticket_name) = 1 THEN '{Total General}'
        ELSE t.ticket_name
    END AS ticket_name,
    CASE
        WHEN GROUPING(t.ticket_name) = 1 AND GROUPING(a.zone) = 1 THEN ' '
        WHEN GROUPING(t.ticket_name) = 1 THEN 'subtotal zona ' || a.zone
        WHEN GROUPING(a.zone) = 1 THEN 'subtotal bilet ' || t.ticket_name
        ELSE a.zone
    END AS zone,
    SUM(NVL(f.sales_count, 0)) AS sales_count,
    SUM(NVL(f.total_amount_paid, 0)) AS total_amount_paid,
    ROUND(
        SUM(NVL(f.total_amount_paid, 0)) /
        NULLIF(SUM(NVL(f.sales_count, 0)), 0),
        2
    ) AS avg_amount_per_sale
FROM olap_facts_ticket_sales f
INNER JOIN olap_dim_ticket t
    ON f.ticket_type_id = t.ticket_type_id
INNER JOIN olap_dim_sales_area a
    ON f.city = a.city
   AND f.zone = a.zone
GROUP BY CUBE(t.ticket_name, a.zone)
ORDER BY 1, 2
;

SELECT *
FROM olap_view_sales_ticket_area_cube;

--------------------------------------------------------------------------------
-- 1. Se creeaza 4 view-uri analitice peste factul central OLAP_FACTS_TICKET_SALES.
-- 2. Modelul comercial foloseste dimensiunile:
--    timp, tip bilet, aria de vanzare si categoria clientului.
-- 3. Dimensiunea OLAP_DIM_NETWORK_VEHICLE este pastrata in model, dar nu este
--    folosita direct in analytical views comerciale, deoarece descrie utilizarea
--    in retea, nu evenimentul de vanzare.
-- 4. Agregarea se face cu GROUP BY, ROLLUP, CUBE, GROUPING, SUM si AVG derivat.
--------------------------------------------------------------------------------