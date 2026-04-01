--------------------------------------------------------------------------------
-- 02_DS3_Neo4j_RemoteViews_FDBO.sql
-- Se ruleaza in schema federata FDBO.
-- Scop: acceseaza Neo4j local prin Query API si expune datele ca view-uri SQL.
-- Endpoint: http://localhost:7474/db/neo4j/query/v2
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Curatare obiecte existente
--------------------------------------------------------------------------------
BEGIN EXECUTE IMMEDIATE 'DROP VIEW ds3_next_on_route_v'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW ds3_route_stops_v'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW ds3_depots_v'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW ds3_vehicles_v'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW ds3_stops_v'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW ds3_routes_v'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW ds3_lines_v'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION query_neo4j_rest_graph_data'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

--------------------------------------------------------------------------------
-- Functia query_neo4j_rest_graph_data
-- Functia face legatura dintre Oracle si Neo4j.
-- Ea trimite un query Cypher prin HTTP POST catre Neo4j Query API
-- si intoarce raspunsul JSON sub forma de CLOB.
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION query_neo4j_rest_graph_data(
    REST_URL     VARCHAR2,
    CYPHER_QUERY VARCHAR2,
    USER_NAME    VARCHAR2,
    PASS         VARCHAR2
)
RETURN CLOB
IS
    l_req          UTL_HTTP.req;
    l_resp         UTL_HTTP.resp;
    l_buffer       CLOB;
    l_chunk        VARCHAR2(32767);
    l_userpass     VARCHAR2(2000) := USER_NAME || ':' || PASS;
    l_query_clean  VARCHAR2(32767);
    l_statement    VARCHAR2(32767);
BEGIN
 ----------------------------------------------------------------------------
    -- Curatarea query-ului Cypher
    -- Query-ul este curatat de newline-uri, tab-uri si caractere speciale,
    -- pentru a putea fi inclus corect in body-ul JSON trimis catre Neo4j.
----------------------------------------------------------------------------
    l_query_clean := CYPHER_QUERY;
    l_query_clean := REPLACE(l_query_clean, '\', '\\');
    l_query_clean := REPLACE(l_query_clean, '"', '\"');
    l_query_clean := REPLACE(l_query_clean, CHR(13), ' ');
    l_query_clean := REPLACE(l_query_clean, CHR(10), ' ');
    l_query_clean := REPLACE(l_query_clean, CHR(9),  ' ');

    -- Construirea body-ului JSON - Neo4j Query API asteapta un obiect JSON care contine cheia "statement", iar valoarea acesteia este interogarea Cypher.

    l_statement := '{ "statement": "' || l_query_clean || '" }';

  ----------------------------------------------------------------------------
    -- Trimiterea request-ului HTTP POST
    -- Se seteaza headerele necesare, inclusiv Content-Type si Basic Auth, apoi query-ul este trimis catre endpoint-ul Neo4j Query API.
----------------------------------------------------------------------------
    l_req := UTL_HTTP.begin_request(REST_URL, 'POST');

    UTL_HTTP.set_header(l_req, 'Content-Type', 'application/json');
    UTL_HTTP.set_header(l_req, 'Content-Length', LENGTH(l_statement));
    UTL_HTTP.set_body_charset(l_req, 'UTF-8');

    UTL_HTTP.set_header(
        l_req,
        'Authorization',
        'Basic ' ||
        UTL_RAW.cast_to_varchar2(
            UTL_ENCODE.base64_encode(
                UTL_I18N.string_to_raw(l_userpass, 'AL32UTF8')
            )
        )
    );

    UTL_HTTP.write_text(l_req, l_statement);

    l_resp := UTL_HTTP.get_response(l_req);
    ----------------------------------------------------------------------------
    -- Citirea raspunsului JSON
    -- Raspunsul este citit in bucati si concatenat intr-un CLOB, pentru a putea fi prelucrat ulterior cu JSON_TABLE.
    ----------------------------------------------------------------------------
    DBMS_LOB.createtemporary(l_buffer, TRUE);

    BEGIN
        LOOP
            UTL_HTTP.read_text(l_resp, l_chunk, 32767);
            DBMS_LOB.writeappend(l_buffer, LENGTH(l_chunk), l_chunk);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.end_of_body THEN
            NULL;
    END;

    UTL_HTTP.end_response(l_resp);

    RETURN l_buffer;
END;
/
SHOW ERRORS;

--------------------------------------------------------------------------------
-- Test simplu de conectivitate
--------------------------------------------------------------------------------
SELECT query_neo4j_rest_graph_data(
    'http://localhost:7474/db/neo4j/query/v2',
    'RETURN 1 AS ok',
    'neo4j',
    'neo4j123'
) AS neo4j_test
FROM dual;

--------------------------------------------------------------------------------
-- DS3_LINES_V
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ds3_lines_v AS
WITH json_doc AS (
    SELECT query_neo4j_rest_graph_data(
        'http://localhost:7474/db/neo4j/query/v2',
        'MATCH (l:Line)
         RETURN l.line_id AS line_id,
                l.real_line_no AS real_line_no,
                l.mode AS line_mode,
                l.display_name AS display_name,
                l.source_overlap AS source_overlap
         ORDER BY l.line_id',
        'neo4j',
        'neo4j123'
    ) AS doc
    FROM dual
)
SELECT
    line_id,
    real_line_no,
    line_mode,
    display_name,
    source_overlap
FROM JSON_TABLE(
    (SELECT doc FROM json_doc),
    '$.data.values[*]'
    COLUMNS (
        line_id         VARCHAR2(20)  PATH '$[0]',
        real_line_no    VARCHAR2(20)  PATH '$[1]',
        line_mode       VARCHAR2(20)  PATH '$[2]',
        display_name    VARCHAR2(100) PATH '$[3]',
        source_overlap  VARCHAR2(10)  PATH '$[4]'
    )
);

--------------------------------------------------------------------------------
-- DS3_ROUTES_V
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ds3_routes_v AS
WITH json_doc AS (
    SELECT query_neo4j_rest_graph_data(
        'http://localhost:7474/db/neo4j/query/v2',
        'MATCH (r:Route)
         RETURN r.route_id AS route_id,
                r.line_id AS line_id,
                r.direction AS direction
         ORDER BY r.route_id',
        'neo4j',
        'neo4j123'
    ) AS doc
    FROM dual
)
SELECT
    route_id,
    line_id,
    direction
FROM JSON_TABLE(
    (SELECT doc FROM json_doc),
    '$.data.values[*]'
    COLUMNS (
        route_id   VARCHAR2(20)  PATH '$[0]',
        line_id    VARCHAR2(20)  PATH '$[1]',
        direction  VARCHAR2(30)  PATH '$[2]'
    )
);

--------------------------------------------------------------------------------
-- DS3_STOPS_V
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ds3_stops_v AS
WITH json_doc AS (
    SELECT query_neo4j_rest_graph_data(
        'http://localhost:7474/db/neo4j/query/v2',
        'MATCH (s:Stop)
         RETURN s.stop_id AS stop_id,
                s.stop_name AS stop_name,
                s.area AS area,
                s.shared_core AS shared_core
         ORDER BY s.stop_id',
        'neo4j',
        'neo4j123'
    ) AS doc
    FROM dual
)
SELECT
    stop_id,
    stop_name,
    area,
    shared_core
FROM JSON_TABLE(
    (SELECT doc FROM json_doc),
    '$.data.values[*]'
    COLUMNS (
        stop_id      VARCHAR2(20)   PATH '$[0]',
        stop_name    VARCHAR2(100)  PATH '$[1]',
        area         VARCHAR2(100)  PATH '$[2]',
        shared_core  VARCHAR2(10)   PATH '$[3]'
    )
);

--------------------------------------------------------------------------------
-- DS3_VEHICLES_V
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ds3_vehicles_v AS
WITH json_doc AS (
    SELECT query_neo4j_rest_graph_data(
        'http://localhost:7474/db/neo4j/query/v2',
        'MATCH (v:Vehicle)
         RETURN v.vehicle_id AS vehicle_id,
                v.vehicle_code AS vehicle_code,
                v.fleet_number AS fleet_number,
                v.vehicle_type AS vehicle_type,
                v.status AS status
         ORDER BY v.vehicle_id',
        'neo4j',
        'neo4j123'
    ) AS doc
    FROM dual
)
SELECT
    vehicle_id,
    vehicle_code,
    fleet_number,
    vehicle_type,
    status
FROM JSON_TABLE(
    (SELECT doc FROM json_doc),
    '$.data.values[*]'
    COLUMNS (
        vehicle_id    VARCHAR2(20)  PATH '$[0]',
        vehicle_code  VARCHAR2(20)  PATH '$[1]',
        fleet_number  VARCHAR2(50)  PATH '$[2]',
        vehicle_type  VARCHAR2(20)  PATH '$[3]',
        status        VARCHAR2(20)  PATH '$[4]'
    )
);

--------------------------------------------------------------------------------
-- DS3_DEPOTS_V
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ds3_depots_v AS
WITH json_doc AS (
    SELECT query_neo4j_rest_graph_data(
        'http://localhost:7474/db/neo4j/query/v2',
        'MATCH (d:Depot)
         RETURN d.depot_id AS depot_id,
                d.depot_name AS depot_name,
                d.city AS city,
                d.location AS location
         ORDER BY d.depot_id',
        'neo4j',
        'neo4j123'
    ) AS doc
    FROM dual
)
SELECT
    depot_id,
    depot_name,
    city,
    location
FROM JSON_TABLE(
    (SELECT doc FROM json_doc),
    '$.data.values[*]'
    COLUMNS (
        depot_id    VARCHAR2(20)   PATH '$[0]',
        depot_name  VARCHAR2(100)  PATH '$[1]',
        city        VARCHAR2(50)   PATH '$[2]',
        location    VARCHAR2(100)  PATH '$[3]'
    )
);

--------------------------------------------------------------------------------
-- DS3_ROUTE_STOPS_V
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ds3_route_stops_v AS
WITH json_doc AS (
    SELECT query_neo4j_rest_graph_data(
        'http://localhost:7474/db/neo4j/query/v2',
        'MATCH (r:Route)-[rel:STOPS_AT]->(s:Stop)
         RETURN r.route_id AS route_id,
                s.stop_id AS stop_id,
                s.stop_name AS stop_name,
                rel.seq AS seq
         ORDER BY r.route_id, rel.seq',
        'neo4j',
        'neo4j123'
    ) AS doc
    FROM dual
)
SELECT
    route_id,
    stop_id,
    stop_name,
    seq
FROM JSON_TABLE(
    (SELECT doc FROM json_doc),
    '$.data.values[*]'
    COLUMNS (
        route_id   VARCHAR2(20)   PATH '$[0]',
        stop_id    VARCHAR2(20)   PATH '$[1]',
        stop_name  VARCHAR2(100)  PATH '$[2]',
        seq        NUMBER         PATH '$[3]'
    )
);

--------------------------------------------------------------------------------
-- DS3_NEXT_ON_ROUTE_V
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ds3_next_on_route_v AS
WITH json_doc AS (
    SELECT query_neo4j_rest_graph_data(
        'http://localhost:7474/db/neo4j/query/v2',
        'MATCH (a:Stop)-[r:NEXT_ON_ROUTE]->(b:Stop)
         RETURN r.route_id AS route_id,
                a.stop_id AS from_stop_id,
                b.stop_id AS to_stop_id,
                r.seq_from AS seq_from,
                r.seq_to AS seq_to
         ORDER BY r.route_id, r.seq_from',
        'neo4j',
        'neo4j123'
    ) AS doc
    FROM dual
)
SELECT
    route_id,
    from_stop_id,
    to_stop_id,
    seq_from,
    seq_to
FROM JSON_TABLE(
    (SELECT doc FROM json_doc),
    '$.data.values[*]'
    COLUMNS (
        route_id      VARCHAR2(20)  PATH '$[0]',
        from_stop_id  VARCHAR2(20)  PATH '$[1]',
        to_stop_id    VARCHAR2(20)  PATH '$[2]',
        seq_from      NUMBER        PATH '$[3]',
        seq_to        NUMBER        PATH '$[4]'
    )
);

--------------------------------------------------------------------------------
-- Verificari finale
--------------------------------------------------------------------------------
SELECT COUNT(*) AS cnt_lines        FROM ds3_lines_v;
SELECT COUNT(*) AS cnt_routes       FROM ds3_routes_v;
SELECT COUNT(*) AS cnt_stops        FROM ds3_stops_v;
SELECT COUNT(*) AS cnt_vehicles     FROM ds3_vehicles_v;
SELECT COUNT(*) AS cnt_depots       FROM ds3_depots_v;
SELECT COUNT(*) AS cnt_route_stops  FROM ds3_route_stops_v;
SELECT COUNT(*) AS cnt_next_route   FROM ds3_next_on_route_v;

SELECT * FROM ds3_lines_v;
SELECT * FROM ds3_routes_v;
SELECT * FROM ds3_stops_v;
SELECT * FROM ds3_vehicles_v;
SELECT * FROM ds3_depots_v;
SELECT * FROM ds3_route_stops_v;
SELECT * FROM ds3_next_on_route_v;