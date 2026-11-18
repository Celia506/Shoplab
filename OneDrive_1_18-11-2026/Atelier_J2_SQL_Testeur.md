# Atelier Jour 2 - SQL pour le testeur

**Module** : M07 - Données de test & environnements
**Durée** : Partie A 1h30 (matin) - Partie B 1h15 - Partie C 1h15 (durées indicatives, à adapter au rythme du groupe)
**Objectif** : contrôler, préparer et remettre en état les données de ShopLab en SQL
**Niveau** : Débutant à intermédiaire
**Mode** : Individuel (entraide en binôme encouragée)

**Prérequis**
- ShopLab démarré : `cd shoplab && docker compose up -d --wait`
- Connexion DBeaver : `localhost:5432`, base `shoplab`, utilisateur `shoplab`, mot de passe `shoplab`
- Mémo : `ressources/Memo_SQL_Testeur.md`

**En cas de fausse manipulation** : `docker compose down -v` puis `docker compose up -d --wait` remet la base à l'état de référence.

---

## Partie A - Explorer les données (matin)

Pour chaque question, écrivez la requête, exécutez-la et **notez le nombre de lignes obtenues**. Enregistrez toutes vos requêtes dans `explorer_shoplab.sql`.

### SELECT simple

**A1.** Liste des produits actifs (référence, nom, prix), du plus cher au moins cher.

**A2.** Produits en rupture de stock (stock inférieur ou égal à 0). Un résultat vous surprend-il ?

**A3.** Clients inscrits en 2026 (identifiant, prénom, nom, date d'inscription).

**A4.** Produits dont le nom contient "lot", sans tenir compte des majuscules.

**A5.** Clients sans numéro de téléphone **ou** sans date de naissance.

**A6.** Commandes en livraison STANDARD dont le montant total dépasse 100 EUR.

### Agrégats

**A7.** Nombre de commandes par statut.

**A8.** Pour les commandes livrées : nombre, chiffre d'affaires et panier moyen par mode de livraison.

### Jointures

**A9.** Liste des commandes avec le prénom et le nom du client.

**A10.** Détail de la commande `CMD-2026-00007` : référence et nom des produits, quantité, prix unitaire, sous-total. Comparez la somme des sous-totaux à `montant_produits`. Que constatez-vous ?

**A11.** Clients qui n'ont jamais passé de commande.

### Pour aller plus loin

**A12.** Top 5 des produits les plus vendus en quantité, hors commandes annulées.

**A13.** Chiffre d'affaires mensuel des commandes livrées.

**A14.** Catégories dont le chiffre d'affaires (hors annulations) dépasse 1 000 EUR.

**A15.** Pour chaque code promo : nombre d'utilisations et remise totale accordée (y compris les codes jamais utilisés).

---

## Partie B - Contrôler les règles métier

**Principe** : chaque requête renvoie les lignes **qui violent** la règle. Un résultat vide signifie que la règle est respectée.

La base contient **une douzaine d'anomalies** volontaires. Trouvez-les toutes.

| # | Règle à contrôler | Requête écrite | Lignes en anomalie |
|---|-------------------|----------------|--------------------|
| B1 | RG01 : frais STANDARD (4,90 sous 50 EUR, 0 à partir de 50 EUR) | | |
| B2 | RG02 / RG03 : frais EXPRESS = 9,90 ; RETRAIT gratuit et sans adresse | | |
| B3 | RG04 : quantité de 1 à 10 | | |
| B4 | RG05 : code promo actif, dans sa période, montant minimum atteint | | |
| B5 | RG12 : `montant_produits` = somme des lignes | | |
| B6 | RG12 : `montant_total` = produits - remise + frais | | |
| B7 | RG07 : commande PAYEE / EXPEDIEE / LIVREE avec un paiement ACCEPTE du montant total | | |
| B8 | RG07 : commande annulée sans paiement resté ACCEPTE | | |
| B9 | RG06 : aucune transition interdite dans l'historique | | |
| B10 | RG06 : statut courant = dernier statut de l'historique | | |
| B11 | RG08 : e-mails uniques sans distinction de casse | | |
| B12 | RG09 : client majeur à l'inscription | | |
| B13 | RG10 : stock non négatif | | |
| B14 | RG11 : avis uniquement par un client ayant reçu le produit | | |
| B15 | Intégrité : l'adresse de livraison appartient au client de la commande | | |
| B16 | RGPD : un client SUPPRIME n'a plus de données personnelles | | |

**Indices** : `GROUP BY ... HAVING`, `NOT EXISTS`, `lower()`, `age()`, `NOT BETWEEN`, jointure entre `commandes` et `adresses`.

Livrable : `controle_shoplab.sql`, une requête par règle, chacune précédée d'un commentaire (règle, résultat attendu, résultat obtenu).

**Question B17** : pour deux anomalies de votre choix, rédigez le résumé d'une fiche d'anomalie (titre, étapes, attendu, obtenu, preuve).

---

## Partie C - Préparer et remettre en état

**Avant de commencer** : passez DBeaver en mode de transaction **manuel**. Encadrez chaque bloc par `BEGIN;` ... `COMMIT;`.

**Convention obligatoire** : e-mails `qa.xxx@example.com`, références produit `QA-xxx`, numéros de commande `QA-xxxxx`.

**C1.** Créez un client de test `qa.nominal@example.com` (majeur, actif) avec une adresse par défaut. Utilisez `INSERT ... SELECT` pour l'adresse (sans écrire l'identifiant du client en dur).

**C2.** Créez trois produits de test : un à 50,00 EUR, un à 49,99 EUR, un en rupture de stock.

**C3.** Créez une commande `QA-00001` au statut **PAYEE**, cohérente avec toutes les règles : une ligne, un paiement accepté du montant total, un historique CREEE puis PAYEE. Vérifiez-la avec vos requêtes de la partie B : aucune ne doit la signaler.

**C4.** Mettez le code `NOEL15` en état d'être utilisé aujourd'hui (dates relatives à `current_date`). Notez d'abord ses valeurs d'origine.

**C5.** Démonstration de sécurité : dans une transaction, exécutez `UPDATE produits SET stock = 0;` sans WHERE, constatez le résultat, puis annulez. Vérifiez que les stocks sont intacts.

**C6.** Écrivez le script de nettoyage qui supprime **toutes** les données QA créées et remet `NOEL15` dans son état d'origine. Vérifiez qu'il ne reste aucune donnée QA.

**C7.** Rendez votre script de préparation **rejouable** : exécuté deux fois de suite, il doit réussir et produire le même état.

**C8.** Mettez à jour votre catalogue J1 : pour chaque JDD au statut "À créer", indiquez le script qui le crée ; pour chaque JDD existant, la requête qui l'extrait.

---

## Livrables

| Fichier | Contenu |
|---------|---------|
| `explorer_shoplab.sql` | Requêtes A1 à A15 |
| `controle_shoplab.sql` | Requêtes B1 à B16, commentées |
| `anomalies_shoplab.md` | Tableau des anomalies trouvées + 2 résumés de fiche |
| `preparation_jdd.sql` | Script rejouable de préparation |
| `nettoyage_jdd.sql` | Script de remise en état |
| Catalogue J1 mis à jour | Colonne "Valeurs / requête d'extraction" complétée |

**Vérification finale** : exécutez `preparation_jdd.sql`, puis `nettoyage_jdd.sql`, puis le script d'empreinte (`shoplab/scripts/empreinte.sh` ou `.ps1`). Les volumes doivent être revenus à ceux du seed (tableau du README).
