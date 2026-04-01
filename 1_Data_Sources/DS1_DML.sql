--------------------------------------------------------------------------------
-- DS1_DML.sql
-- Conectare: SALES (XEPDB1)
-- Scop: populează date demo. Re-runnable: șterge întâi datele (în ordinea FK).
-- Versiune extinsă, cu identificatori standardizați pentru integrare federată.
--------------------------------------------------------------------------------

DELETE FROM ticket_validations;
DELETE FROM payments;
DELETE FROM ticket_sales;
DELETE FROM ticket_types;
COMMIT;

--------------------------------------------------------------------------------
-- Ticket types
--------------------------------------------------------------------------------
INSERT INTO ticket_types (ticket_name, base_price, validity_minutes, validity_days)
VALUES ('Bilet 1 Calatorie', 3, 90, NULL);

INSERT INTO ticket_types (ticket_name, base_price, validity_minutes, validity_days)
VALUES ('Bilet 1 zi', 13, NULL, 1);

INSERT INTO ticket_types (ticket_name, base_price, validity_minutes, validity_days)
VALUES ('Abonament 30 zile', 110, NULL, 30);

--------------------------------------------------------------------------------
-- Ticket sales
-- 12 vânzări demo, suficiente pentru interogări mai bogate
--------------------------------------------------------------------------------
INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Copou', 'standard', 3, DATE '2026-03-01');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Nicolina', 'student', 0.30, DATE '2026-03-01');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Tatarasi', 'pensionar', 0, DATE '2026-03-02');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Podu Ros', 'standard', 3, DATE '2026-03-02');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Copou', 'elev', 0.50, DATE '2026-03-03');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Nicolina', 'standard', 13, DATE '2026-03-03');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Tatarasi', 'student', 1.30, DATE '2026-03-04');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Podu Ros', 'standard', 110, DATE '2026-03-04');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Copou', 'standard', 3, DATE '2026-03-05');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Nicolina', 'pensionar', 0, DATE '2026-03-05');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Tatarasi', 'standard', 13, DATE '2026-03-06');

INSERT INTO ticket_sales (zone, customer_category, amount_paid, purchase_date)
VALUES ('Podu Ros', 'student', 1.30, DATE '2026-03-06');

--------------------------------------------------------------------------------
-- Payments
-- plățile se leagă de primele 12 vânzări prin ROW_NUMBER, deci scriptul rămâne robust
--------------------------------------------------------------------------------
INSERT INTO payments (order_id, method, status, pay_ts)
SELECT order_id,
       CASE
           WHEN rn IN (1,2,4,6,9,11) THEN 'card'
           ELSE 'cash'
       END AS method,
       'paid' AS status,
       SYSTIMESTAMP
FROM (
    SELECT order_id, ROW_NUMBER() OVER (ORDER BY order_id) rn
    FROM ticket_sales
)
WHERE rn BETWEEN 1 AND 12;

--------------------------------------------------------------------------------
-- Validations
-- Identificatori standardizați:
-- line_id    : L001, L002, L003
-- route_id   : R001, R003, R005
-- stop_id    : S003, S004, S010, S018
-- vehicle_id : V001, V002, V010
--
-- Maparea este gândită să producă rezultate bune la:
-- - GROUP BY pe linii/rute/stații
-- - join cu JSON incidents/telemetry
-- - import în Neo4j
--------------------------------------------------------------------------------
INSERT INTO ticket_validations
(order_id, validation_ts, ticket_type_id, line_id, route_id, stop_id, vehicle_id)
WITH sales_rn AS (
    SELECT order_id, ROW_NUMBER() OVER (ORDER BY order_id) rn
    FROM ticket_sales
),
validation_map AS (
    SELECT 1 AS rn,  'Bilet 1 Calatorie' AS ticket_name, 'L001' AS line_id, 'R001' AS route_id, 'S003' AS stop_id, 'V001' AS vehicle_id FROM dual
    UNION ALL
    SELECT 2,  'Bilet 1 Calatorie', 'L001', 'R001', 'S004', 'V002' FROM dual
    UNION ALL
    SELECT 3,  'Bilet 1 zi',        'L002', 'R003', 'S010', 'V010' FROM dual
    UNION ALL
    SELECT 4,  'Bilet 1 Calatorie', 'L001', 'R001', 'S003', 'V001' FROM dual
    UNION ALL
    SELECT 5,  'Bilet 1 Calatorie', 'L002', 'R003', 'S010', 'V010' FROM dual
    UNION ALL
    SELECT 6,  'Bilet 1 zi',        'L003', 'R005', 'S018', 'V002' FROM dual
    UNION ALL
    SELECT 7,  'Bilet 1 Calatorie', 'L001', 'R001', 'S004', 'V001' FROM dual
    UNION ALL
    SELECT 8,  'Abonament 30 zile', 'L003', 'R005', 'S018', 'V002' FROM dual
    UNION ALL
    SELECT 9,  'Bilet 1 Calatorie', 'L002', 'R003', 'S010', 'V010' FROM dual
    UNION ALL
    SELECT 10, 'Bilet 1 Calatorie', 'L001', 'R001', 'S003', 'V001' FROM dual
    UNION ALL
    SELECT 11, 'Bilet 1 zi',        'L003', 'R005', 'S018', 'V002' FROM dual
    UNION ALL
    SELECT 12, 'Bilet 1 Calatorie', 'L002', 'R003', 'S010', 'V010' FROM dual
)
SELECT
    s.order_id,
    SYSTIMESTAMP,
    t.ticket_type_id,
    m.line_id,
    m.route_id,
    m.stop_id,
    m.vehicle_id
FROM sales_rn s
JOIN validation_map m
    ON s.rn = m.rn
JOIN ticket_types t
    ON t.ticket_name = m.ticket_name;

COMMIT;

--------------------------------------------------------------------------------
-- Verificare
--------------------------------------------------------------------------------
SELECT COUNT(*) AS ticket_types_cnt FROM ticket_types;
SELECT COUNT(*) AS ticket_sales_cnt FROM ticket_sales;
SELECT COUNT(*) AS payments_cnt FROM payments;
SELECT COUNT(*) AS validations_cnt FROM ticket_validations;

--------------------------------------------------------------------------------
-- Verificări utile pentru integrare
--------------------------------------------------------------------------------
SELECT line_id, COUNT(*) AS validations_per_line
FROM ticket_validations
GROUP BY line_id
ORDER BY line_id;

SELECT route_id, COUNT(*) AS validations_per_route
FROM ticket_validations
GROUP BY route_id
ORDER BY route_id;

SELECT stop_id, COUNT(*) AS validations_per_stop
FROM ticket_validations
GROUP BY stop_id
ORDER BY stop_id;

SELECT vehicle_id, COUNT(*) AS validations_per_vehicle
FROM ticket_validations
GROUP BY vehicle_id
ORDER BY vehicle_id;