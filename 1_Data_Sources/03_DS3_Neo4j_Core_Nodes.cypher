CREATE
(:Line {line_id:'L001', real_line_no:'30', mode:'bus',  display_name:'Bus 30', source_overlap:true}),
(:Line {line_id:'L002', real_line_no:'41', mode:'bus',  display_name:'Bus 41', source_overlap:true}),
(:Line {line_id:'L003', real_line_no:'9',  mode:'tram', display_name:'Tram 9', source_overlap:true}),
(:Line {line_id:'L004', real_line_no:'46', mode:'bus',  display_name:'Bus 46', source_overlap:false}),
(:Line {line_id:'L005', real_line_no:'50', mode:'bus',  display_name:'Bus 50', source_overlap:false}),
(:Line {line_id:'L006', real_line_no:'20', mode:'bus',  display_name:'Bus 20', source_overlap:false}),
(:Line {line_id:'L007', real_line_no:'3',  mode:'tram', display_name:'Tram 3', source_overlap:false}),
(:Line {line_id:'L008', real_line_no:'6',  mode:'tram', display_name:'Tram 6', source_overlap:false}),
(:Line {line_id:'L009', real_line_no:'5',  mode:'tram', display_name:'Tram 5', source_overlap:false}),
(:Line {line_id:'L010', real_line_no:'1',  mode:'tram', display_name:'Tram 1', source_overlap:false});

CREATE
(:Route {route_id:'R001', direction:'canonical', line_id:'L001'}),
(:Route {route_id:'R003', direction:'canonical', line_id:'L002'}),
(:Route {route_id:'R005', direction:'canonical', line_id:'L003'}),
(:Route {route_id:'R006', direction:'canonical', line_id:'L004'}),
(:Route {route_id:'R007', direction:'canonical', line_id:'L005'}),
(:Route {route_id:'R008', direction:'canonical', line_id:'L006'}),
(:Route {route_id:'R009', direction:'canonical', line_id:'L007'}),
(:Route {route_id:'R010', direction:'canonical', line_id:'L008'}),
(:Route {route_id:'R011', direction:'canonical', line_id:'L009'}),
(:Route {route_id:'R012', direction:'canonical', line_id:'L010'});

MATCH (l:Line), (r:Route)
WHERE l.line_id = r.line_id
CREATE (l)-[:HAS_ROUTE]->(r);

CREATE
(:Depot {depot_id:'D001', depot_name:'Depou Copou', city:'Iasi', location:'Copou'}),
(:Depot {depot_id:'D002', depot_name:'Depou Tatarasi', city:'Iasi', location:'Tatarasi'}),
(:Depot {depot_id:'D003', depot_name:'Depou Nicolina', city:'Iasi', location:'Nicolina'});

CREATE
(:Vehicle {vehicle_id:'V001', vehicle_code:'V001', fleet_number:'BUS-0123',  vehicle_type:'bus',  status:'operational'}),
(:Vehicle {vehicle_id:'V002', vehicle_code:'V002', fleet_number:'TRAM-004', vehicle_type:'tram', status:'maintenance'}),
(:Vehicle {vehicle_id:'V010', vehicle_code:'V010', fleet_number:'BUS-0456',  vehicle_type:'bus',  status:'operational'}),
(:Vehicle {vehicle_id:'V011', vehicle_code:'V011', fleet_number:'BUS-0788',  vehicle_type:'bus',  status:'operational'}),
(:Vehicle {vehicle_id:'V012', vehicle_code:'V012', fleet_number:'TRAM-009', vehicle_type:'tram', status:'operational'}),
(:Vehicle {vehicle_id:'V013', vehicle_code:'V013', fleet_number:'BUS-0810',  vehicle_type:'bus',  status:'operational'}),
(:Vehicle {vehicle_id:'V014', vehicle_code:'V014', fleet_number:'BUS-0820',  vehicle_type:'bus',  status:'operational'}),
(:Vehicle {vehicle_id:'V015', vehicle_code:'V015', fleet_number:'BUS-0830',  vehicle_type:'bus',  status:'operational'}),
(:Vehicle {vehicle_id:'V016', vehicle_code:'V016', fleet_number:'TRAM-010', vehicle_type:'tram', status:'operational'}),
(:Vehicle {vehicle_id:'V017', vehicle_code:'V017', fleet_number:'TRAM-011', vehicle_type:'tram', status:'operational'});

MATCH (v:Vehicle {vehicle_id:'V001'}), (d:Depot {depot_id:'D001'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V002'}), (d:Depot {depot_id:'D002'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V010'}), (d:Depot {depot_id:'D003'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V011'}), (d:Depot {depot_id:'D001'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V012'}), (d:Depot {depot_id:'D002'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V013'}), (d:Depot {depot_id:'D001'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V014'}), (d:Depot {depot_id:'D003'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V015'}), (d:Depot {depot_id:'D001'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V016'}), (d:Depot {depot_id:'D002'}) CREATE (v)-[:BASED_AT]->(d);
MATCH (v:Vehicle {vehicle_id:'V017'}), (d:Depot {depot_id:'D002'}) CREATE (v)-[:BASED_AT]->(d);

MATCH (v:Vehicle {vehicle_id:'V001'}), (l:Line {line_id:'L001'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V010'}), (l:Line {line_id:'L002'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V002'}), (l:Line {line_id:'L003'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V011'}), (l:Line {line_id:'L004'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V013'}), (l:Line {line_id:'L005'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V014'}), (l:Line {line_id:'L006'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V012'}), (l:Line {line_id:'L007'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V016'}), (l:Line {line_id:'L008'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V017'}), (l:Line {line_id:'L009'}) CREATE (v)-[:SERVES]->(l);
MATCH (v:Vehicle {vehicle_id:'V002'}), (l:Line {line_id:'L010'}) CREATE (v)-[:SERVES]->(l);