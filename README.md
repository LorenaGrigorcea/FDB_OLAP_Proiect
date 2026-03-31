# FDB_OLAP_Proiect
## Arhitectură de baze de date federate pentru analiza transportului public urban din municipiul Iași

### Descriere generală
Acest repository conține proiectul realizat în cadrul disciplinei FDB/OLAP și urmărește proiectarea și implementarea unei arhitecturi de baze de date federate pentru analiza transportului public urban din municipiul Iași.

Ideea centrală a proiectului este integrarea unor surse de date eterogene, provenite din tehnologii și modele diferite, într-o structură unitară de acces și analiză. Au fost utilizate surse relaționale pentru date tranzacționale și operaționale, o sursă de tip graf pentru modelarea rețelei de transport și o sursă documentară bazată pe fișiere JSON pentru evenimente și incidente operaționale. Pe baza acestora a fost construit un model de acces federat, un model de integrare și un strat analitic orientat spre interogări multidimensionale de tip ROLAP.

Proiectul include și componenta web, prin care datele integrate sunt expuse și pot fi accesate într-o manieră mai ușor de demonstrat și evaluat.

### Scopul proiectului
Scopul acestui studiu de caz este realizarea unei soluții federate care să permită:
- integrarea surselor de date eterogene într-un cadru comun;
- accesul unificat la date provenite din sisteme diferite;
- definirea unui model analitic pentru interogări de tip business intelligence;
- expunerea datelor prin servicii web și interfață web;
- demonstrarea modului în care tehnologii diferite pot colabora într-o arhitectură coerentă.

### Sursele de date utilizate
Proiectul este construit pe baza a patru surse externe de date:

#### DS1, Oracle Database
Sursă relațională dedicată tranzacțiilor de ticketing și plăților. Aceasta acoperă zona de vânzare de bilete, înregistrare a plăților și validare a titlurilor de călătorie.

#### DS2, PostgreSQL
Sursă relațională pentru date operaționale și resurse umane. Aceasta include informații despre angajați, depouri, vehicule, ture și pontaj. Pentru această sursă a fost realizată și o expunere REST prin PostgREST.

#### DS3, Neo4j
Sursă de tip graf utilizată pentru modelarea topologiei rețelei de transport public. Ea descrie relațiile dintre linii, rute, stații, vehicule și depouri și permite analize de conectivitate și structură a rețelei.

#### DS4, JSON files
Sursă documentară bazată pe fișiere JSON externe. Aceasta conține date despre incidente, mentenanță, evenimente speciale și telemetrie și este integrată în Oracle prin mecanisme dedicate pentru fișiere externe și procesare JSON.

### Obiective urmărite
Prin acest proiect au fost urmărite mai multe obiective concrete:
- definirea structurii fiecărei surse de date;
- popularea surselor cu date relevante pentru studiul de caz;
- realizarea mecanismelor de acces federat;
- integrarea surselor într-un model comun;
- construirea unui strat analitic bazat pe view-uri și interogări ROLAP;
- pregătirea unei componente web pentru expunerea datelor;
- documentarea etapelor de proiect conform cerințelor de evaluare.

### Structura repository-ului
Repository-ul este organizat pe etape și componente ale proiectului.

#### 1. Data Sources
Această secțiune conține sursele de date externe și fișierele necesare pentru definirea și popularea acestora:
- scripturi Oracle pentru DS1;
- scripturi PostgreSQL pentru DS2;
- scripturi Cypher și SQL pentru DS3;
- fișiere JSON și scripturi Oracle pentru DS4;
- documentația aferentă fiecărei surse.

#### 2. Access Model
Această parte conține scripturile care definesc modelul de acces federat, inclusiv view-uri și mecanisme de conectare între sursele externe și schema de integrare.

#### 3. Integration and Analytical Model
Aici se află scripturile care definesc modelul de integrare și stratul analitic. Sunt incluse structurile și interogările folosite pentru agregări, analiză multidimensională și exploatarea datelor într-o logică de tip ROLAP.

#### 4. Web Model
Această secțiune include fișierele necesare pentru componenta web:
- activarea și configurarea accesului prin ORDS;
- expunerea obiectelor relevante prin REST;
- documentația necesară pentru rulare și demonstrare.

#### 5. Documentation
Repository-ul conține și documentația Word aferentă etapelor proiectului, redactată conform template-urilor și cerințelor de evaluare.

### Organizarea practică a fișierelor
În cadrul proiectului se regăsesc, în principal, următoarele tipuri de fișiere:
- scripturi SQL pentru definirea schemelor, view-urilor și drepturilor de acces;
- scripturi DML pentru popularea datelor;
- scripturi Cypher pentru modelul graf din Neo4j;
- fișiere JSON cu date documentare;
- documentație `.docx` pentru fiecare etapă a proiectului;
- fișiere de configurare pentru PostgREST și componenta web.

### Exemple de conținut din repository
Printre fișierele importante incluse în repository se află:
- scripturile DS1 pentru Oracle, împărțite pe setup, schemă, date, acces și testare;
- scripturile DS2 pentru PostgreSQL și configurarea serverului PostgREST;
- scripturile DS3 pentru popularea și verificarea modelului Neo4j, împreună cu view-urile remote din Oracle;
- fișierele JSON pentru DS4 și scripturile de integrare a acestora în Oracle;
- scripturile pentru modelul analitic și operațional;
- scripturile ORDS pentru componenta web.

### Fluxul general al proiectului
Proiectul urmează un flux logic în mai multe etape:
1. definirea și popularea surselor de date externe;
2. configurarea mecanismelor de acces;
3. realizarea integrării surselor în schema federată;
4. construirea stratului analitic;
5. expunerea componentelor relevante prin servicii web;
6. documentarea și pregătirea pentru evaluare.

### Tehnologii utilizate
Pentru realizarea proiectului au fost folosite următoarele tehnologii:
- Oracle Database
- PostgreSQL
- PostgREST
- Neo4j
- JSON
- Oracle SQL și PL/SQL
- Cypher
- Spark SQL
- ORDS
- Oracle APEX

### Rezultatul obținut
Rezultatul proiectului este o arhitectură federată capabilă să unifice date provenite din surse eterogene și să le ofere într-o formă potrivită pentru analiză, interogare și expunere web. Proiectul demonstrează atât integrarea tehnică a surselor, cât și utilitatea unui strat analitic construit peste acestea.

### Observații finale
Repository-ul include atât partea de implementare, cât și partea de documentație. Structura sa urmărește etapele proiectului și permite evaluarea separată a fiecărei componente: surse de date, model de acces, model de integrare și analiză, respectiv model web.

Acest proiect a fost realizat în scop academic, pentru a demonstra proiectarea și implementarea unei soluții federate aplicate pe un studiu de caz concret din domeniul transportului public urban.
