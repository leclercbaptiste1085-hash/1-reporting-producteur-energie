-- sql/01_tables.sql : tables brutes et chargement des CSV
DROP TABLE IF EXISTS prod_regionale, prix_spot, budget CASCADE;

-- eolien et solaire en texte : l'API renvoie parfois "-" a la place d'un nombre
CREATE TABLE prod_regionale (date_heure timestamptz, eolien text, solaire text);
CREATE TABLE prix_spot (heure_utc timestamp PRIMARY KEY, heure_locale timestamp, prix_eur_mwh numeric);
CREATE TABLE budget (mois date, filiere text, volume_mwh numeric, prix_eur_mwh numeric,
                     PRIMARY KEY (mois, filiere));

\copy prod_regionale FROM 'donnees/production_regionale.csv' WITH (FORMAT csv, HEADER true)
\copy prix_spot FROM 'donnees/prix_spot_horaire.csv' WITH (FORMAT csv, HEADER true)
