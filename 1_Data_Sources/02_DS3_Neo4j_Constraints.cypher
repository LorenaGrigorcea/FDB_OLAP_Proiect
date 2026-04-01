CREATE CONSTRAINT depot_id_unique IF NOT EXISTS
FOR (d:Depot) REQUIRE d.depot_id IS UNIQUE;

CREATE CONSTRAINT line_id_unique IF NOT EXISTS
FOR (l:Line) REQUIRE l.line_id IS UNIQUE;

CREATE CONSTRAINT route_id_unique IF NOT EXISTS
FOR (r:Route) REQUIRE r.route_id IS UNIQUE;

CREATE CONSTRAINT stop_id_unique IF NOT EXISTS
FOR (s:Stop) REQUIRE s.stop_id IS UNIQUE;

CREATE CONSTRAINT vehicle_id_unique IF NOT EXISTS
FOR (v:Vehicle) REQUIRE v.vehicle_id IS UNIQUE;