"""Projet 3 - Telecharge les donnees reelles de janvier a aout 2026 dans donnees/.

- Production eolienne et solaire des Hauts-de-France par demi-heure (RTE eCO2mix, via ODRE)
- Prix spot horaires de l'electricite en France (Ember, source ENTSO-E)
"""
import csv
import io
import urllib.parse
import urllib.request
import zipfile
from pathlib import Path

DEBUT, FIN = "2026-01-01", "2026-09-01"
DOSSIER = Path(__file__).parent / "donnees"
DOSSIER.mkdir(exist_ok=True)

# 1. Production regionale : puissance moyenne en MW par demi-heure, heure UTC
filtre = (f"libelle_region=\"Hauts-de-France\" and date_heure>=date'{DEBUT}' "
          f"and date_heure<date'{FIN}'")
url = ("https://odre.opendatasoft.com/api/explore/v2.1/catalog/datasets/"
       "eco2mix-regional-cons-def/exports/csv?"
       + urllib.parse.urlencode({"select": "date_heure,eolien,solaire", "where": filtre,
                                 "order_by": "date_heure", "delimiter": ","}))
with urllib.request.urlopen(url) as reponse:
    texte = reponse.read().decode("utf-8-sig")
with open(DOSSIER / "production_regionale.csv", "w", encoding="utf-8", newline="") as f:
    f.write(texte)
print("Production :", texte.count("\n") - 1, "demi-heures")

# 2. Prix spot horaires France
url = ("https://files.ember-energy.org/public-downloads/price/outputs/"
       "european_wholesale_electricity_price_data_hourly.zip")
with urllib.request.urlopen(url) as reponse:
    archive = zipfile.ZipFile(io.BytesIO(reponse.read()))
with archive.open("France.csv") as f:
    lignes = [l for l in csv.DictReader(io.TextIOWrapper(f, encoding="utf-8"))
              if DEBUT <= l["Datetime (UTC)"] < FIN]
with open(DOSSIER / "prix_spot_horaire.csv", "w", encoding="utf-8", newline="") as f:
    w = csv.writer(f)
    w.writerow(["heure_utc", "heure_locale", "prix_eur_mwh"])
    w.writerows([l["Datetime (UTC)"], l["Datetime (Local)"], l["Price (EUR/MWhe)"]] for l in lignes)
print("Prix :", len(lignes), "heures")
