-- sql/03_vues.sql : production et chiffre d'affaires heure par heure

-- Part du producteur : 1 % de l'eolien regional, 1,5 % du solaire regional.
-- Puissance moyenne (MW) sur une heure x 1 heure = energie (MWh).
CREATE OR REPLACE VIEW v_production_horaire AS
SELECT date_trunc('hour', p.date_heure AT TIME ZONE 'UTC') AS heure_utc,
       f.filiere,
       AVG(f.mw) * f.part AS mwh
FROM prod_regionale p
CROSS JOIN LATERAL (VALUES
    ('Eolien',  NULLIF(NULLIF(p.eolien, '-'), '')::numeric,  0.01),
    ('Solaire', NULLIF(NULLIF(p.solaire, '-'), '')::numeric, 0.015)
) AS f(filiere, mw, part)
GROUP BY 1, 2, f.part;

-- Jointure avec les prix en heure UTC : pas de doublon ni de trou au changement d'heure
CREATE OR REPLACE VIEW v_revenus_horaires AS
SELECT p.heure_utc,
       ((p.heure_utc AT TIME ZONE 'UTC') AT TIME ZONE 'Europe/Paris')::date AS date_locale,
       p.filiere,
       COALESCE(p.mwh, 0) AS mwh,
       s.prix_eur_mwh,
       COALESCE(p.mwh, 0) * s.prix_eur_mwh AS ca_eur
FROM v_production_horaire p
JOIN prix_spot s ON s.heure_utc = p.heure_utc;

-- Synthese mensuelle et ecarts : sert de reference pour verifier les mesures DAX
CREATE OR REPLACE VIEW v_ecarts_mensuels AS
WITH m AS (
    SELECT date_trunc('month', date_locale)::date AS mois, filiere,
           SUM(mwh) AS volume_mwh, SUM(ca_eur) AS ca_eur,
           SUM(ca_eur) / NULLIF(SUM(mwh), 0) AS prix_capte,
           AVG(prix_eur_mwh) AS prix_moyen_marche
    FROM v_revenus_horaires
    GROUP BY 1, 2
)
SELECT m.mois, m.filiere,
       m.volume_mwh, b.volume_mwh AS volume_budget,
       m.prix_capte, m.prix_moyen_marche, b.prix_eur_mwh AS prix_budget,
       m.ca_eur, b.volume_mwh * b.prix_eur_mwh AS ca_budget,
       (m.volume_mwh - b.volume_mwh) * b.prix_eur_mwh AS ecart_volume,
       (m.prix_capte - b.prix_eur_mwh) * m.volume_mwh AS ecart_prix
FROM m
JOIN budget b USING (mois, filiere);
