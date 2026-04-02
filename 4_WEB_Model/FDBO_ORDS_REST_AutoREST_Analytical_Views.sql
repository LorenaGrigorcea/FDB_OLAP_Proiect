--------------------------------------------------------------------------------
-- 32_FDBO_ORDS_REST_AutoREST_Analytical_Views.sql
--------------------------------------------------------------------------------
-- Project: Public Transport Federated Database - Web Model
-- Schema : FDBO
-- Service: XEPDB1
-- Purpose:
--   Publishes analytical views from the commercial ROLAP model as AutoREST
--   resources in ORDS, under the /ords/fdbo base path.
--
-- Analytical views exposed:
--   1. OLAP_VIEW_SALES_CALENDAR
--   2. OLAP_VIEW_SALES_TICKET
--   3. OLAP_VIEW_SALES_CUSTOMER_CATEGORY
--   4. OLAP_VIEW_SALES_TICKET_AREA_CUBE
--
-- Base URL:
--   http://localhost:8080/ords/fdbo
--
-- Notes:
--   - The FDBO schema must already be enabled in ORDS.
--   - This script must be executed while connected as FDBO on XEPDB1.
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Optional checks: the analytical views must already exist
--------------------------------------------------------------------------------
SELECT * FROM OLAP_VIEW_SALES_CALENDAR;
SELECT * FROM OLAP_VIEW_SALES_TICKET;
SELECT * FROM OLAP_VIEW_SALES_CUSTOMER_CATEGORY;
SELECT * FROM OLAP_VIEW_SALES_TICKET_AREA_CUBE;

--------------------------------------------------------------------------------
-- Enable analytical views as AutoREST resources
--------------------------------------------------------------------------------
BEGIN
    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'FDBO',
        p_object         => 'OLAP_VIEW_SALES_CALENDAR',
        p_object_type    => 'VIEW',
        p_object_alias   => 'OLAP_VIEW_SALES_CALENDAR',
        p_auto_rest_auth => FALSE
    );

    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'FDBO',
        p_object         => 'OLAP_VIEW_SALES_TICKET',
        p_object_type    => 'VIEW',
        p_object_alias   => 'OLAP_VIEW_SALES_TICKET',
        p_auto_rest_auth => FALSE
    );

    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'FDBO',
        p_object         => 'OLAP_VIEW_SALES_CUSTOMER_CATEGORY',
        p_object_type    => 'VIEW',
        p_object_alias   => 'OLAP_VIEW_SALES_CUSTOMER_CATEGORY',
        p_auto_rest_auth => FALSE
    );

    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'FDBO',
        p_object         => 'OLAP_VIEW_SALES_TICKET_AREA_CUBE',
        p_object_type    => 'VIEW',
        p_object_alias   => 'OLAP_VIEW_SALES_TICKET_AREA_CUBE',
        p_auto_rest_auth => FALSE
    );

    COMMIT;
END;
/

--------------------------------------------------------------------------------
-- Verification
--------------------------------------------------------------------------------
SELECT *
FROM user_ords_enabled_objects;