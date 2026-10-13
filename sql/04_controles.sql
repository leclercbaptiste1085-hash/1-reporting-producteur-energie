-- sql/04_controles.sql : verifications et chiffres de reference
SELECT count(*) AS demi_heures FROM prod_regionale;   -- 11662
SELECT count(*) AS heures FROM prix_spot;            -- 5830

SELECT round(sum(ca_eur)) AS ca_reel, round(sum(ca_budget)) AS ca_budget,
       round(sum(ecart_volume)) AS ecart_volume, round(sum(ecart_prix)) AS ecart_prix
FROM v_ecarts_mensuels;

-- Heures a prix negatif : le producteur paie pour injecter
SELECT count(DISTINCT heure_utc) AS heures_prix_negatif,
       round(sum(ca_eur)) AS ca_aux_prix_negatifs
FROM v_revenus_horaires
WHERE prix_eur_mwh < 0;
