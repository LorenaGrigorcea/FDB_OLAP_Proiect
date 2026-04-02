--------------------------------------------------------------------------------
-- OLAP_PUBLIC_TRANSPORT_OPERATIONS.sql
-- Creeaza extensia operationala ROLAP pentru proiectul Public Transport System.
-- Modelul foloseste DS3 (Neo4j) si DS4 (JSON files):
-- source views -> dimensions -> facts -> analytical views
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Verificare source views existente
--------------------------------------------------------------------------------
SELECT COUNT(*) AS cnt_ds3_lines
FROM ds3_lines_v;

SELECT COUNT(*) AS cnt_ds3_routes
FROM ds3_routes_v;

SELECT COUNT(*) AS cnt_ds3_stops
FROM ds3_stops_v;

SELECT COUNT(*) AS cnt_incidents
FROM incidents_view;

SELECT COUNT(*) AS cnt_maintenance
FROM maintenance_windows_view;

SELECT COUNT(*) AS cnt_special_events
FROM special_events_view;

SELECT COUNT(*) AS cnt_telemetry
FROM telemetry_logs_view;

--------------------------------------------------------------------------------
-- 1. Dimensions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 1.1 OLAP_OP_DIM_TIME
-- Dimensiune calendar pentru evenimentele operationale din DS4
--------------------------------------------------------------------------------
DROP VIEW olap_op_dim_time;

CREATE OR REPLACE VIEW olap_op_dim_time AS
SELECT DISTINCT
       full_date,
       EXTRACT(YEAR  FROM full_date) AS year_no,
       EXTRACT(MONTH FROM full_date) AS month_no,
       EXTRACT(DAY   FROM full_date) AS day_no
FROM (
    SELECT TRUNC(TO_TIMESTAMP(created_ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date
    FROM incidents_view

    UNION

    SELECT TRUNC(TO_TIMESTAMP(start_ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date
    FROM maintenance_windows_view

    UNION

    SELECT TRUNC(TO_TIMESTAMP(end_ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date
    FROM maintenance_windows_view

    UNION

    SELECT TRUNC(TO_DATE(event_date, 'YYYY-MM-DD')) AS full_date
    FROM special_events_view

    UNION

    SELECT TRUNC(TO_TIMESTAMP(ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date
    FROM telemetry_logs_view
)
WHERE full_date IS NOT NULL
;

SELECT *
FROM olap_op_dim_time
ORDER BY full_date;

--------------------------------------------------------------------------------
-- 1.2 OLAP_OP_DIM_NETWORK
-- Dimensiune pentru reteaua de transport, pe baza cheilor line/route/stop
-- observate in evenimentele operationale DS4 si descrise in DS3
--------------------------------------------------------------------------------
DROP VIEW olap_op_dim_network;

CREATE OR REPLACE VIEW olap_op_dim_network AS
SELECT DISTINCT
    n.line_id,
    l.display_name AS line_name,
    l.line_mode,
    n.route_id,
    r.direction,
    n.stop_id,
    s.stop_name,
    s.area AS stop_area,
    s.shared_core
FROM (
    SELECT DISTINCT
        line_id,
        route_id,
        stop_id
    FROM incidents_view
    WHERE line_id IS NOT NULL
      AND route_id IS NOT NULL
      AND stop_id IS NOT NULL

    UNION

    SELECT DISTINCT
        line_id,
        route_id,
        stop_id
    FROM telemetry_logs_view
    WHERE line_id IS NOT NULL
      AND route_id IS NOT NULL
      AND stop_id IS NOT NULL
) n
LEFT JOIN ds3_lines_v  l ON n.line_id  = l.line_id
LEFT JOIN ds3_routes_v r ON n.route_id = r.route_id
LEFT JOIN ds3_stops_v  s ON n.stop_id  = s.stop_id
;

SELECT *
FROM olap_op_dim_network
ORDER BY line_id, route_id, stop_id;

--------------------------------------------------------------------------------
-- 1.3 OLAP_OP_DIM_EVENT
-- Dimensiune descriptiva pentru tipurile de evenimente operationale din DS4
--------------------------------------------------------------------------------
DROP VIEW olap_op_dim_event;

CREATE OR REPLACE VIEW olap_op_dim_event AS
SELECT DISTINCT
    'INCIDENT' AS source_type,
    category   AS event_subtype,
    severity   AS impact_label,
    status     AS status_label
FROM incidents_view

UNION

SELECT DISTINCT
    'MAINTENANCE' AS source_type,
    work_type     AS event_subtype,
    impact_level  AS impact_label,
    'scheduled'   AS status_label
FROM maintenance_windows_view

UNION

SELECT DISTINCT
    'SPECIAL_EVENT' AS source_type,
    event_type      AS event_subtype,
    'traffic x' || TO_CHAR(expected_traffic_multiplier) AS impact_label,
    'planned'       AS status_label
FROM special_events_view

UNION

SELECT DISTINCT
    'TELEMETRY' AS source_type,
    'telemetry_log' AS event_subtype,
    CASE
        WHEN occupancy_estimate >= 70 THEN 'HIGH_OCCUPANCY'
        WHEN occupancy_estimate >= 40 THEN 'MEDIUM_OCCUPANCY'
        ELSE 'LOW_OCCUPANCY'
    END AS impact_label,
    'observed' AS status_label
FROM telemetry_logs_view
;

SELECT *
FROM olap_op_dim_event
ORDER BY source_type, event_subtype, impact_label, status_label;

--------------------------------------------------------------------------------
-- 2. Facts
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 2.1 OLAP_OP_FACTS_EVENTS
-- Fact operational unificat pentru evenimentele si observatiile din DS4
--------------------------------------------------------------------------------
DROP VIEW olap_op_facts_events;

CREATE OR REPLACE VIEW olap_op_facts_events AS
SELECT
    TRUNC(TO_TIMESTAMP(i.created_ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date,
    'INCIDENT' AS source_type,
    i.category AS event_subtype,
    i.severity AS impact_label,
    i.status   AS status_label,
    i.line_id,
    i.route_id,
    i.stop_id,
    CAST(NULL AS VARCHAR2(20)) AS vehicle_id,
    1 AS event_count,
    CAST(NULL AS NUMBER) AS speed,
    CAST(NULL AS NUMBER) AS occupancy_estimate,
    CAST(NULL AS NUMBER) AS traffic_multiplier
FROM incidents_view i

UNION ALL

SELECT
    TRUNC(TO_TIMESTAMP(m.start_ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date,
    'MAINTENANCE' AS source_type,
    m.work_type   AS event_subtype,
    m.impact_level AS impact_label,
    'scheduled'   AS status_label,
    m.line_id,
    m.route_id,
    CAST(NULL AS VARCHAR2(20)) AS stop_id,
    CAST(NULL AS VARCHAR2(20)) AS vehicle_id,
    1 AS event_count,
    CAST(NULL AS NUMBER) AS speed,
    CAST(NULL AS NUMBER) AS occupancy_estimate,
    CAST(NULL AS NUMBER) AS traffic_multiplier
FROM maintenance_windows_view m

UNION ALL

SELECT
    TRUNC(TO_DATE(se.event_date, 'YYYY-MM-DD')) AS full_date,
    'SPECIAL_EVENT' AS source_type,
    se.event_type   AS event_subtype,
    'traffic x' || TO_CHAR(se.expected_traffic_multiplier) AS impact_label,
    'planned' AS status_label,
    CAST(NULL AS VARCHAR2(20)) AS line_id,
    CAST(NULL AS VARCHAR2(20)) AS route_id,
    CAST(NULL AS VARCHAR2(20)) AS stop_id,
    CAST(NULL AS VARCHAR2(20)) AS vehicle_id,
    1 AS event_count,
    CAST(NULL AS NUMBER) AS speed,
    CAST(NULL AS NUMBER) AS occupancy_estimate,
    se.expected_traffic_multiplier AS traffic_multiplier
FROM special_events_view se

UNION ALL

SELECT
    TRUNC(TO_TIMESTAMP(t.ts, 'YYYY-MM-DD"T"HH24:MI:SS')) AS full_date,
    'TELEMETRY' AS source_type,
    'telemetry_log' AS event_subtype,
    CASE
        WHEN t.occupancy_estimate >= 70 THEN 'HIGH_OCCUPANCY'
        WHEN t.occupancy_estimate >= 40 THEN 'MEDIUM_OCCUPANCY'
        ELSE 'LOW_OCCUPANCY'
    END AS impact_label,
    'observed' AS status_label,
    t.line_id,
    t.route_id,
    t.stop_id,
    t.vehicle_id,
    1 AS event_count,
    t.speed,
    t.occupancy_estimate,
    CAST(NULL AS NUMBER) AS traffic_multiplier
FROM telemetry_logs_view t
;

SELECT *
FROM olap_op_facts_events
ORDER BY full_date, source_type, line_id, route_id, stop_id;

--------------------------------------------------------------------------------
-- 3. Analytical Views
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 3.1 OLAP_OP_VIEW_EVENTS_CALENDAR
-- Analiza evenimentelor operationale pe calendar
--------------------------------------------------------------------------------
DROP VIEW olap_op_view_events_calendar;

CREATE OR REPLACE VIEW olap_op_view_events_calendar AS
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
    SUM(NVL(f.event_count, 0)) AS total_events,
    SUM(CASE WHEN f.source_type = 'INCIDENT' THEN f.event_count ELSE 0 END) AS incident_count,
    SUM(CASE WHEN f.source_type = 'MAINTENANCE' THEN f.event_count ELSE 0 END) AS maintenance_count,
    SUM(CASE WHEN f.source_type = 'SPECIAL_EVENT' THEN f.event_count ELSE 0 END) AS special_event_count,
    SUM(CASE WHEN f.source_type = 'TELEMETRY' THEN f.event_count ELSE 0 END) AS telemetry_count
FROM olap_op_dim_time d
INNER JOIN olap_op_facts_events f
    ON d.full_date = f.full_date
GROUP BY ROLLUP(d.year_no, d.month_no, d.day_no)
ORDER BY d.year_no, d.month_no, d.day_no
;

SELECT *
FROM olap_op_view_events_calendar;

--------------------------------------------------------------------------------
-- 3.2 OLAP_OP_VIEW_EVENTS_NETWORK
-- Analiza evenimentelor operationale pe retea
--------------------------------------------------------------------------------
DROP VIEW olap_op_view_events_network;

CREATE OR REPLACE VIEW olap_op_view_events_network AS
SELECT
    CASE
        WHEN GROUPING(n.line_name) = 1 THEN '{Total General}'
        ELSE n.line_name
    END AS line_name,
    CASE
        WHEN GROUPING(n.line_name) = 1 THEN ' '
        WHEN GROUPING(n.route_id) = 1 THEN 'subtotal linie ' || n.line_name
        ELSE n.route_id
    END AS route_id,
    CASE
        WHEN GROUPING(n.line_name) = 1 THEN ' '
        WHEN GROUPING(n.route_id) = 1 THEN ' '
        WHEN GROUPING(n.stop_name) = 1 THEN 'subtotal ruta ' || n.route_id
        ELSE n.stop_name
    END AS stop_name,
    SUM(NVL(f.event_count, 0)) AS total_events,
    SUM(CASE WHEN f.source_type = 'INCIDENT' THEN f.event_count ELSE 0 END) AS incident_count,
    SUM(CASE WHEN f.source_type = 'TELEMETRY' THEN f.event_count ELSE 0 END) AS telemetry_count
FROM olap_op_dim_network n
INNER JOIN olap_op_facts_events f
    ON n.line_id = f.line_id
   AND n.route_id = f.route_id
   AND n.stop_id = f.stop_id
GROUP BY ROLLUP(n.line_name, n.route_id, n.stop_name)
ORDER BY n.line_name, n.route_id, n.stop_name
;

SELECT *
FROM olap_op_view_events_network;

--------------------------------------------------------------------------------
-- 3.3 OLAP_OP_VIEW_EVENTS_TYPE
-- Analiza evenimentelor operationale dupa sursa, subtip si impact
--------------------------------------------------------------------------------
DROP VIEW olap_op_view_events_type;

CREATE OR REPLACE VIEW olap_op_view_events_type AS
SELECT
    CASE
        WHEN GROUPING(e.source_type) = 1 THEN '{Total General}'
        ELSE e.source_type
    END AS source_type,
    CASE
        WHEN GROUPING(e.source_type) = 1 THEN ' '
        WHEN GROUPING(e.event_subtype) = 1 THEN 'subtotal sursa ' || e.source_type
        ELSE e.event_subtype
    END AS event_subtype,
    CASE
        WHEN GROUPING(e.source_type) = 1 THEN ' '
        WHEN GROUPING(e.event_subtype) = 1 THEN ' '
        WHEN GROUPING(e.impact_label) = 1 THEN 'subtotal tip ' || e.event_subtype
        ELSE e.impact_label
    END AS impact_label,
    SUM(NVL(f.event_count, 0)) AS total_events,
    AVG(f.speed) AS avg_speed,
    AVG(f.occupancy_estimate) AS avg_occupancy_estimate,
    AVG(f.traffic_multiplier) AS avg_traffic_multiplier
FROM olap_op_dim_event e
INNER JOIN olap_op_facts_events f
    ON e.source_type   = f.source_type
   AND e.event_subtype = f.event_subtype
   AND e.impact_label  = f.impact_label
   AND e.status_label  = f.status_label
GROUP BY ROLLUP(e.source_type, e.event_subtype, e.impact_label)
ORDER BY e.source_type, e.event_subtype, e.impact_label
;

SELECT *
FROM olap_op_view_events_type;

--------------------------------------------------------------------------------
-- Numele fisierului: OLAP_PUBLIC_TRANSPORT_OPERATIONS.sql
-- Ce se intampla aici:
-- 1. Se construieste un model operational separat de modelul comercial.
-- 2. DS3 furnizeaza dimensiunea de retea, iar DS4 furnizeaza dimensiunea
--    de timp, dimensiunea de eveniment si factul operational unificat.
-- 3. Se definesc trei analytical views pentru calendar, retea si tipul
--    evenimentului operational.
--------------------------------------------------------------------------------