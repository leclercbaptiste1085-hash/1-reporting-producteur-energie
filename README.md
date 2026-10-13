# Reporting producteur d'énergies renouvelables

**Question de gestion** — Un producteur éolien et solaire des Hauts-de-France a-t-il tenu son budget sur les huit premiers mois de 2026 ? Si non, l'écart vient-il de la production (volume) ou des prix de marché (prix) ?

Données réelles, heure par heure : production régionale RTE et prix spot de l'électricité en France.
Période : janvier à août 2026.

---

## Résultats

| | Réel | Budget | Écart |
|---|---:|---:|---:|
| Chiffre d'affaires | 6,00 M€ | 6,39 M€ | **−383 k€ (−6,0 %)** |
| dont effet volume | | | −535 k€ |
| dont effet prix | | | +152 k€ |

**Le manque à gagner vient de la production, pas des prix.** Il a moins venté que prévu : 84 055 MWh éoliens produits pour 92 013 MWh budgétés. La hausse des prix de marché a compensé moins d'un tiers de cet écart.

| Filière | Volume réel | Volume budget | Prix capté | Prix budget | Écart volume | Écart prix |
|---|---:|---:|---:|---:|---:|---:|
| Éolien | 84 055 MWh | 92 013 MWh | 64,2 €/MWh | 62 €/MWh | −493 k€ | +187 k€ |
| Solaire | 15 245 MWh | 16 239 MWh | 39,7 €/MWh | 42 €/MWh | −42 k€ | −35 k€ |

**Trois constats pour la direction :**

1. **Le solaire vend mal sa production.** Il capte 39,7 €/MWh, quand le prix moyen du marché tourne autour de 73 €/MWh. Tous les panneaux produisent aux mêmes heures, ce qui fait baisser le prix précisément quand le producteur vend. C'est l'effet de cannibalisation.
2. **452 heures à prix négatif.** Pendant ces heures, le producteur paie pour injecter son électricité, soit −77 k€ de chiffre d'affaires. Le solaire en supporte les trois quarts (−56 k€).
3. **Les écarts mensuels sont très volatils** : +501 k€ d'effet prix en janvier, −458 k€ en février. Un reporting seulement annuel masquerait le risque. Le suivi doit être mensuel.

| Mois | CA réel | CA budget | Effet volume | Effet prix |
|---|---:|---:|---:|---:|
| Janvier | 1 538 k€ | 1 096 k€ | −60 k€ | +501 k€ |
| Février | 612 k€ | 980 k€ | +90 k€ | −458 k€ |
| Mars | 617 k€ | 983 k€ | −184 k€ | −181 k€ |
| Avril | 269 k€ | 791 k€ | −160 k€ | −362 k€ |
| Mai | 357 k€ | 722 k€ | −204 k€ | −161 k€ |
| Juin | 531 k€ | 609 k€ | +10 k€ | −88 k€ |
| Juillet | 944 k€ | 625 k€ | −39 k€ | +358 k€ |
| Août | 1 135 k€ | 582 k€ | +11 k€ | +543 k€ |

---

## Méthode

**1. Collecte** (`collecte.py`)
- Production éolienne et solaire des Hauts-de-France, par demi-heure : RTE eCO2mix, via l'ODRE. On obtient 11 662 demi-heures.
- Prix spot horaires France : Ember, source ENTSO-E. On obtient 5 830 heures.

**2. Hypothèses du producteur** (`sql/02_budget.sql`)
- Le producteur détient 1 % de l'éolien régional et 1,5 % du solaire régional.
- Budget éolien : 70 MW × heures du mois × facteur de charge moyen.
- Budget solaire : production estimée par PVGIS pour une centrale de 20 MWc près de Lille.
- Prix budget : 62 €/MWh pour l'éolien, 42 €/MWh pour le solaire.

**3. Calcul heure par heure** (`sql/03_vues.sql`)
- **Énergie** : la puissance moyenne sur l'heure, multipliée par 1 heure, donne l'énergie en MWh.
- **Chiffre d'affaires** : énergie × prix spot de l'heure.
- **Changement d'heure** : la jointure se fait en heure UTC. Il n'y a donc ni doublon ni trou aux passages à l'heure d'été et d'hiver.
- **Valeurs manquantes** : l'API renvoie parfois « - » au lieu d'un nombre. Ces valeurs sont neutralisées avant la conversion en nombre.

**4. Décomposition de l'écart**

```
Écart volume = (volume réel − volume budget) × prix budget
Écart prix   = (prix capté − prix budget)    × volume réel
Écart total  = CA réel − CA budget = écart volume + écart prix
```

Le *prix capté* est le CA réel divisé par le volume réel. C'est le prix moyen effectivement obtenu, pondéré par les heures où l'on produit. Il diffère du prix moyen du marché.

**5. Contrôles** (`sql/04_controles.sql`)
- Nombre de lignes chargées.
- Totaux de référence.
- Vérification que l'effet volume plus l'effet prix redonnent l'écart total.

## Reproduire

```bash
python collecte.py                    # télécharge donnees/
createdb energie
psql -d energie -f sql/01_tables.sql  # à lancer dans cmd, depuis ce dossier
psql -d energie -f sql/02_budget.sql
psql -d energie -f sql/03_vues.sql
psql -d energie -f sql/04_controles.sql
```

Outils : Python 3 (bibliothèque standard uniquement), PostgreSQL 16.

## Limites

- **Le producteur est fictif.** Sa production est une quote-part fixe de la production régionale réelle.
- **Le budget est construit pour l'exercice** à partir de moyennes historiques. Ce n'est pas un budget d'entreprise réel.
- **Les revenus sont valorisés au prix spot**, sans contrat d'achat (PPA), ni complément de rémunération, ni coûts d'équilibrage.

## Suite

- Modèle Power BI connecté à la base, avec des mesures DAX qui recalculent les écarts. La vue `v_ecarts_mensuels` sert de référence pour vérifier les totaux.

---

<sub>Sources : RTE eCO2mix via ODRE (Licence Ouverte Etalab) · Ember, *European wholesale electricity price data* (CC BY 4.0). · **EN** — Budget-vs-actual reporting for a wind and solar producer, using real hourly French market data (Jan–Aug 2026). Revenue was 6.0% below budget, driven by volume (−€535k) and partly offset by price (+€152k). Solar captured only €39.7/MWh because of the cannibalisation effect.</sub>
