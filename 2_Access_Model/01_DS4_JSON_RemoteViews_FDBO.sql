--------------------------------------------------------------------------------
-- 01_DS4_JSON_RemoteViews_FDBO.sql
-- Se ruleaza in schema federata FDBO.
-- Creeaza functia de citire a fisierelor JSON si view-urile relationale.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Curatare obiecte existente
--------------------------------------------------------------------------------
DROP VIEW incidents_view;
DROP VIEW maintenance_windows_view;
DROP VIEW special_events_view;
DROP VIEW telemetry_logs_view;
DROP FUNCTION get_external_data;

--------------------------------------------------------------------------------
-- Functie pentru citirea unui fisier JSON extern in CLOB
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_external_data(
    default_directory VARCHAR2,
    file_path VARCHAR2
)
RETURN CLOB IS
    json_file bfile := bfilename(UPPER(default_directory), file_path);
    json_clob clob;
    l_dest_offset   integer := 1;
    l_src_offset    integer := 1;
    l_bfile_csid    number  := 0;
    l_lang_context  integer := 0;
    l_warning       integer := 0;
BEGIN
    dbms_lob.createtemporary(json_clob, true);

    dbms_lob.fileopen(json_file, dbms_lob.file_readonly);

    dbms_lob.loadclobfromfile(
        dest_lob     => json_clob,
        src_bfile    => json_file,
        amount       => dbms_lob.lobmaxsize,
        dest_offset  => l_dest_offset,
        src_offset   => l_src_offset,
        bfile_csid   => l_bfile_csid,
        lang_context => l_lang_context,
        warning      => l_warning
    );

    dbms_lob.fileclose(json_file);

    RETURN json_clob;
END;
/

--------------------------------------------------------------------------------
-- Teste de acces la fisierele JSON
--------------------------------------------------------------------------------
SELECT get_external_data('EXT_FILE_DS', 'incidents.json') AS doc FROM dual;
SELECT get_external_data('EXT_FILE_DS', 'maintenance_windows.json') AS doc FROM dual;
SELECT get_external_data('EXT_FILE_DS', 'special_events.json') AS doc FROM dual;
SELECT get_external_data('EXT_FILE_DS', 'telemetry_logs.json') AS doc FROM dual;

--------------------------------------------------------------------------------
-- incidents_view
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW incidents_view AS
WITH json AS (
    SELECT get_external_data('EXT_FILE_DS', 'incidents.json') doc
    FROM dual
)
SELECT
    incident_id,
    created_ts,
    category,
    severity,
    line_id,
    route_id,
    stop_id,
    description,
    status
FROM JSON_TABLE(
    (SELECT doc FROM json),
    '$[*]'
    COLUMNS (
        incident_id  VARCHAR2(20)  PATH '$.incident_id',
        created_ts   VARCHAR2(30)  PATH '$.created_ts',
        category     VARCHAR2(50)  PATH '$.category',
        severity     VARCHAR2(20)  PATH '$.severity',
        line_id      VARCHAR2(20)  PATH '$.line_id',
        route_id     VARCHAR2(20)  PATH '$.route_id',
        stop_id      VARCHAR2(20)  PATH '$.stop_id',
        description  VARCHAR2(400) PATH '$.description',
        status       VARCHAR2(20)  PATH '$.status'
    )
);

--------------------------------------------------------------------------------
-- maintenance_windows_view
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW maintenance_windows_view AS
WITH json AS (
    SELECT get_external_data('EXT_FILE_DS', 'maintenance_windows.json') doc
    FROM dual
)
SELECT
    work_id,
    start_ts,
    end_ts,
    line_id,
    route_id,
    affected_stops,
    work_type,
    impact_level
FROM JSON_TABLE(
    (SELECT doc FROM json),
    '$[*]'
    COLUMNS (
        work_id         VARCHAR2(20)  PATH '$.work_id',
        start_ts        VARCHAR2(30)  PATH '$.start_ts',
        end_ts          VARCHAR2(30)  PATH '$.end_ts',
        line_id         VARCHAR2(20)  PATH '$.line_id',
        route_id        VARCHAR2(20)  PATH '$.route_id',
        affected_stops  VARCHAR2(400) FORMAT JSON PATH '$.affected_stops',
        work_type       VARCHAR2(100) PATH '$.work_type',
        impact_level    VARCHAR2(20)  PATH '$.impact_level'
    )
);

--------------------------------------------------------------------------------
-- special_events_view
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW special_events_view AS
WITH json AS (
    SELECT get_external_data('EXT_FILE_DS', 'special_events.json') doc
    FROM dual
)
SELECT
    event_id,
    event_date,
    area,
    event_type,
    expected_traffic_multiplier
FROM JSON_TABLE(
    (SELECT doc FROM json),
    '$[*]'
    COLUMNS (
        event_id                     VARCHAR2(20) PATH '$.event_id',
        event_date                   VARCHAR2(20) PATH '$.event_date',
        area                         VARCHAR2(50) PATH '$.area',
        event_type                   VARCHAR2(50) PATH '$.event_type',
        expected_traffic_multiplier  NUMBER       PATH '$.expected_traffic_multiplier'
    )
);

--------------------------------------------------------------------------------
-- telemetry_logs_view
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW telemetry_logs_view AS
WITH json AS (
    SELECT get_external_data('EXT_FILE_DS', 'telemetry_logs.json') doc
    FROM dual
)
SELECT
    telemetry_id,
    ts,
    vehicle_id,
    line_id,
    route_id,
    stop_id,
    speed,
    occupancy_estimate
FROM JSON_TABLE(
    (SELECT doc FROM json),
    '$[*]'
    COLUMNS (
        telemetry_id        VARCHAR2(20) PATH '$.telemetry_id',
        ts                  VARCHAR2(30) PATH '$.ts',
        vehicle_id          VARCHAR2(20) PATH '$.vehicle_id',
        line_id             VARCHAR2(20) PATH '$.line_id',
        route_id            VARCHAR2(20) PATH '$.route_id',
        stop_id             VARCHAR2(20) PATH '$.stop_id',
        speed               NUMBER       PATH '$.speed',
        occupancy_estimate  NUMBER       PATH '$.occupancy_estimate'
    )
);

--------------------------------------------------------------------------------
-- Verificare finala
--------------------------------------------------------------------------------
SELECT * FROM incidents_view;
SELECT * FROM maintenance_windows_view;
SELECT * FROM special_events_view;
SELECT * FROM telemetry_logs_view;

--------------------------------------------------------------------------------
-- 1. Se creeaza functia get_external_data pentru citirea fisierelor JSON.
-- 2. Se citesc fisierele din DIRECTORY-ul EXT_FILE_DS.
-- 3. JSON_TABLE transforma JSON array in linii relationale, folosind calea $[*].
-- 4. Se creeaza cele 4 view-uri relationale pentru DS4.
--------------------------------------------------------------------------------