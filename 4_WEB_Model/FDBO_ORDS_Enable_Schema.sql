--------------------------------------------------------------------------------
-- 31_FDBO_ORDS_REST_Enable_Schema.sql
--------------------------------------------------------------------------------
-- Project: Public Transport Federated Database - Web Model
-- Schema : FDBO
-- Service: XEPDB1
-- Purpose:
--   Enables the FDBO schema in ORDS and maps it to the base path /ords/fdbo
--   so that REST endpoints can be published for views, analytical views,
--   AutoREST resources, and custom REST modules.
--
-- Base URL:
--   http://localhost:8080/ords/fdbo
--
-- Notes:
--   - ORDS must already be installed and running in standalone mode.
--   - APEX and ORDS were configured on Oracle XE 21c / XEPDB1.
--   - This script should be executed while connected as FDBO on XEPDB1.
--------------------------------------------------------------------------------
BEGIN
  ORDS.ENABLE_SCHEMA(
    p_enabled => TRUE,
    p_schema => 'FDBO',
    p_url_mapping_type => 'BASE_PATH',
    p_url_mapping_pattern => 'fdbo',
    p_auto_rest_auth => FALSE
  );
  commit;
END;
/

select * from user_ords_schemas;