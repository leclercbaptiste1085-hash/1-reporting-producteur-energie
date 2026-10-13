-- sql/02_budget.sql : budget 2026 (hypotheses)
-- Eolien : 70 MW x heures du mois x facteur de charge mensuel moyen du nord de la France
-- Solaire : production PVGIS d'une centrale de 20 MWc pres de Lille
-- Prix : prix de vente retenus au budget (le solaire se vend moins cher : il produit quand tout le monde produit)
INSERT INTO budget VALUES
('2026-01-01','Eolien',17186,62), ('2026-02-01','Eolien',15053,62), ('2026-03-01','Eolien',14582,62),
('2026-04-01','Eolien',11088,62), ('2026-05-01','Eolien',9895,62),  ('2026-06-01','Eolien',8064,62),
('2026-07-01','Eolien',8333,62),  ('2026-08-01','Eolien',7812,62),  ('2026-09-01','Eolien',9576,62),
('2026-10-01','Eolien',13020,62), ('2026-11-01','Eolien',14616,62), ('2026-12-01','Eolien',17186,62),
('2026-01-01','Solaire',736,42),  ('2026-02-01','Solaire',1101,42), ('2026-03-01','Solaire',1868,42),
('2026-04-01','Solaire',2467,42), ('2026-05-01','Solaire',2573,42), ('2026-06-01','Solaire',2600,42),
('2026-07-01','Solaire',2579,42), ('2026-08-01','Solaire',2315,42), ('2026-09-01','Solaire',2029,42),
('2026-10-01','Solaire',1454,42), ('2026-11-01','Solaire',868,42),  ('2026-12-01','Solaire',659,42);
