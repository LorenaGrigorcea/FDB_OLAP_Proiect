CREATE
(:Stop {stop_id:'S001', stop_name:'Copou', area:'Copou', shared_core:false}),
(:Stop {stop_id:'S002', stop_name:'Fundatie', area:'Centru', shared_core:false}),
(:Stop {stop_id:'S003', stop_name:'Piata Unirii', area:'Centru', shared_core:true}),
(:Stop {stop_id:'S004', stop_name:'Targu Cucu', area:'Centru', shared_core:true}),
(:Stop {stop_id:'S005', stop_name:'Podu Ros', area:'Centru-Sud', shared_core:false}),
(:Stop {stop_id:'S006', stop_name:'Nicolina', area:'Nicolina', shared_core:false}),
(:Stop {stop_id:'S007', stop_name:'Gara', area:'Gara', shared_core:false}),
(:Stop {stop_id:'S008', stop_name:'Pacurari', area:'Pacurari', shared_core:false}),
(:Stop {stop_id:'S009', stop_name:'Canta', area:'Canta', shared_core:false}),
(:Stop {stop_id:'S010', stop_name:'Tatarasi Nord', area:'Tatarasi', shared_core:true}),
(:Stop {stop_id:'S011', stop_name:'Tatarasi Sud', area:'Tatarasi', shared_core:false}),
(:Stop {stop_id:'S012', stop_name:'Dacia', area:'Dacia', shared_core:false}),
(:Stop {stop_id:'S013', stop_name:'Tudor Vladimirescu', area:'Tudor', shared_core:false}),
(:Stop {stop_id:'S014', stop_name:'Bucium', area:'Bucium', shared_core:false}),
(:Stop {stop_id:'S015', stop_name:'Aeroport', area:'Aeroport', shared_core:false}),
(:Stop {stop_id:'S016', stop_name:'Tehnopolis', area:'Zona Industriala', shared_core:false}),
(:Stop {stop_id:'S017', stop_name:'Dancu', area:'Dancu', shared_core:false}),
(:Stop {stop_id:'S018', stop_name:'Tehnopolis Terminal', area:'Zona Industriala', shared_core:true});

MATCH (r:Route {route_id:'R001'}), (s:Stop {stop_id:'S009'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R001'}), (s:Stop {stop_id:'S008'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R001'}), (s:Stop {stop_id:'S007'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R001'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);
MATCH (r:Route {route_id:'R001'}), (s:Stop {stop_id:'S004'}) CREATE (r)-[:STOPS_AT {seq:5}]->(s);
MATCH (r:Route {route_id:'R001'}), (s:Stop {stop_id:'S005'}) CREATE (r)-[:STOPS_AT {seq:6}]->(s);
MATCH (r:Route {route_id:'R001'}), (s:Stop {stop_id:'S014'}) CREATE (r)-[:STOPS_AT {seq:7}]->(s);

MATCH (r:Route {route_id:'R003'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R003'}), (s:Stop {stop_id:'S005'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R003'}), (s:Stop {stop_id:'S006'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R003'}), (s:Stop {stop_id:'S010'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);
MATCH (r:Route {route_id:'R003'}), (s:Stop {stop_id:'S011'}) CREATE (r)-[:STOPS_AT {seq:5}]->(s);

MATCH (r:Route {route_id:'R005'}), (s:Stop {stop_id:'S001'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R005'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R005'}), (s:Stop {stop_id:'S005'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R005'}), (s:Stop {stop_id:'S013'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);
MATCH (r:Route {route_id:'R005'}), (s:Stop {stop_id:'S016'}) CREATE (r)-[:STOPS_AT {seq:5}]->(s);
MATCH (r:Route {route_id:'R005'}), (s:Stop {stop_id:'S018'}) CREATE (r)-[:STOPS_AT {seq:6}]->(s);

MATCH (r:Route {route_id:'R006'}), (s:Stop {stop_id:'S008'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R006'}), (s:Stop {stop_id:'S007'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R006'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R006'}), (s:Stop {stop_id:'S013'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);
MATCH (r:Route {route_id:'R006'}), (s:Stop {stop_id:'S014'}) CREATE (r)-[:STOPS_AT {seq:5}]->(s);

MATCH (r:Route {route_id:'R007'}), (s:Stop {stop_id:'S007'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R007'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R007'}), (s:Stop {stop_id:'S004'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R007'}), (s:Stop {stop_id:'S015'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);

MATCH (r:Route {route_id:'R008'}), (s:Stop {stop_id:'S011'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R008'}), (s:Stop {stop_id:'S004'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R008'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R008'}), (s:Stop {stop_id:'S008'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);
MATCH (r:Route {route_id:'R008'}), (s:Stop {stop_id:'S012'}) CREATE (r)-[:STOPS_AT {seq:5}]->(s);

MATCH (r:Route {route_id:'R009'}), (s:Stop {stop_id:'S007'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R009'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R009'}), (s:Stop {stop_id:'S004'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R009'}), (s:Stop {stop_id:'S010'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);
MATCH (r:Route {route_id:'R009'}), (s:Stop {stop_id:'S017'}) CREATE (r)-[:STOPS_AT {seq:5}]->(s);

MATCH (r:Route {route_id:'R010'}), (s:Stop {stop_id:'S012'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R010'}), (s:Stop {stop_id:'S007'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R010'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R010'}), (s:Stop {stop_id:'S004'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);
MATCH (r:Route {route_id:'R010'}), (s:Stop {stop_id:'S010'}) CREATE (r)-[:STOPS_AT {seq:5}]->(s);

MATCH (r:Route {route_id:'R011'}), (s:Stop {stop_id:'S012'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R011'}), (s:Stop {stop_id:'S007'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R011'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R011'}), (s:Stop {stop_id:'S004'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);
MATCH (r:Route {route_id:'R011'}), (s:Stop {stop_id:'S018'}) CREATE (r)-[:STOPS_AT {seq:5}]->(s);

MATCH (r:Route {route_id:'R012'}), (s:Stop {stop_id:'S001'}) CREATE (r)-[:STOPS_AT {seq:1}]->(s);
MATCH (r:Route {route_id:'R012'}), (s:Stop {stop_id:'S003'}) CREATE (r)-[:STOPS_AT {seq:2}]->(s);
MATCH (r:Route {route_id:'R012'}), (s:Stop {stop_id:'S005'}) CREATE (r)-[:STOPS_AT {seq:3}]->(s);
MATCH (r:Route {route_id:'R012'}), (s:Stop {stop_id:'S010'}) CREATE (r)-[:STOPS_AT {seq:4}]->(s);

MATCH (a:Stop {stop_id:'S009'}), (b:Stop {stop_id:'S008'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R001', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S008'}), (b:Stop {stop_id:'S007'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R001', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S007'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R001', seq_from:3, seq_to:4}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S004'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R001', seq_from:4, seq_to:5}]->(b);
MATCH (a:Stop {stop_id:'S004'}), (b:Stop {stop_id:'S005'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R001', seq_from:5, seq_to:6}]->(b);
MATCH (a:Stop {stop_id:'S005'}), (b:Stop {stop_id:'S014'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R001', seq_from:6, seq_to:7}]->(b);

MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S005'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R003', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S005'}), (b:Stop {stop_id:'S006'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R003', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S006'}), (b:Stop {stop_id:'S010'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R003', seq_from:3, seq_to:4}]->(b);
MATCH (a:Stop {stop_id:'S010'}), (b:Stop {stop_id:'S011'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R003', seq_from:4, seq_to:5}]->(b);

MATCH (a:Stop {stop_id:'S001'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R005', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S005'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R005', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S005'}), (b:Stop {stop_id:'S013'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R005', seq_from:3, seq_to:4}]->(b);
MATCH (a:Stop {stop_id:'S013'}), (b:Stop {stop_id:'S016'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R005', seq_from:4, seq_to:5}]->(b);
MATCH (a:Stop {stop_id:'S016'}), (b:Stop {stop_id:'S018'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R005', seq_from:5, seq_to:6}]->(b);

MATCH (a:Stop {stop_id:'S008'}), (b:Stop {stop_id:'S007'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R006', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S007'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R006', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S013'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R006', seq_from:3, seq_to:4}]->(b);
MATCH (a:Stop {stop_id:'S013'}), (b:Stop {stop_id:'S014'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R006', seq_from:4, seq_to:5}]->(b);

MATCH (a:Stop {stop_id:'S007'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R007', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S004'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R007', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S004'}), (b:Stop {stop_id:'S015'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R007', seq_from:3, seq_to:4}]->(b);

MATCH (a:Stop {stop_id:'S011'}), (b:Stop {stop_id:'S004'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R008', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S004'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R008', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S008'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R008', seq_from:3, seq_to:4}]->(b);
MATCH (a:Stop {stop_id:'S008'}), (b:Stop {stop_id:'S012'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R008', seq_from:4, seq_to:5}]->(b);

MATCH (a:Stop {stop_id:'S007'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R009', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S004'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R009', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S004'}), (b:Stop {stop_id:'S010'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R009', seq_from:3, seq_to:4}]->(b);
MATCH (a:Stop {stop_id:'S010'}), (b:Stop {stop_id:'S017'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R009', seq_from:4, seq_to:5}]->(b);

MATCH (a:Stop {stop_id:'S012'}), (b:Stop {stop_id:'S007'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R010', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S007'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R010', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S004'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R010', seq_from:3, seq_to:4}]->(b);
MATCH (a:Stop {stop_id:'S004'}), (b:Stop {stop_id:'S010'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R010', seq_from:4, seq_to:5}]->(b);

MATCH (a:Stop {stop_id:'S012'}), (b:Stop {stop_id:'S007'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R011', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S007'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R011', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S004'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R011', seq_from:3, seq_to:4}]->(b);
MATCH (a:Stop {stop_id:'S004'}), (b:Stop {stop_id:'S018'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R011', seq_from:4, seq_to:5}]->(b);

MATCH (a:Stop {stop_id:'S001'}), (b:Stop {stop_id:'S003'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R012', seq_from:1, seq_to:2}]->(b);
MATCH (a:Stop {stop_id:'S003'}), (b:Stop {stop_id:'S005'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R012', seq_from:2, seq_to:3}]->(b);
MATCH (a:Stop {stop_id:'S005'}), (b:Stop {stop_id:'S010'}) CREATE (a)-[:NEXT_ON_ROUTE {route_id:'R012', seq_from:3, seq_to:4}]->(b);