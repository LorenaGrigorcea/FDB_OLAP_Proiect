--------------------------------------------------------------------------------
-- FDBO_VIEWS_DS1.sql
-- Conectare: FDBO @ XEPDB1
-- Scop: strat de integrare peste schema SALES (DS1) prin DB LINK + views
--------------------------------------------------------------------------------

-- 0) Cleanup: view-uri (drop if exists)
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_ticket_types';       EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_ticket_sales';       EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_payments';           EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_ticket_validations'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/

-- 1) Cleanup: DB LINK (drop if exists)
BEGIN
  EXECUTE IMMEDIATE 'DROP DATABASE LINK salesdb';
EXCEPTION
  WHEN OTHERS THEN
    -- ORA-02024: database link not found
    -- ORA-02080: database link is in use
    IF SQLCODE NOT IN (-2024, -2080) THEN
      RAISE;
    END IF;
END;
/

-- 2) Creeaza DB LINK (salesdb)
CREATE DATABASE LINK salesdb
  CONNECT TO sales IDENTIFIED BY sales
  USING '//localhost:1522/XEPDB1';

-- 3) Verificare DB LINK 
SELECT db_link, username, host
FROM user_db_links
ORDER BY db_link;

-- 4) View-uri federate in FDBO (peste tabelele remote din SALES via DB LINK)
CREATE OR REPLACE VIEW v_ticket_types AS
SELECT * FROM ticket_types@salesdb;

CREATE OR REPLACE VIEW v_ticket_sales AS
SELECT * FROM ticket_sales@salesdb;

CREATE OR REPLACE VIEW v_payments AS
SELECT * FROM payments@salesdb;

CREATE OR REPLACE VIEW v_ticket_validations AS
SELECT * FROM ticket_validations@salesdb;

-- 5) Verificari (dovada ca “intorc date”)
SELECT COUNT(*) AS cnt_v_ticket_types       FROM v_ticket_types;
SELECT COUNT(*) AS cnt_v_ticket_sales       FROM v_ticket_sales;
SELECT COUNT(*) AS cnt_v_payments           FROM v_payments;
SELECT COUNT(*) AS cnt_v_ticket_validations FROM v_ticket_validations;