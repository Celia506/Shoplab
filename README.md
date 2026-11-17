# ShopLab - Application fil rouge e-commerce

ShopLab est l'application e-commerce utilisée comme support du module M07, Elle se compose de :

| Service | Rôle | Accès depuis le poste |
|---------|------|-----------------------|
| `db` | Base PostgreSQL 16 initialisée avec le schéma et le jeu de données de référence | `localhost:5432` (DBeaver) |
| `api` | API REST Node.js + page web minimale | http://localhost:3000 |
| `adminer` | Interface web d'administration de la base (optionnelle) | http://localhost:8080 |

---

## 1. Démarrage rapide

Prérequis : Docker Desktop (ou Docker Engine + plugin Compose) installé et démarré.

```bash
cd shoplab
cp .env.example .env          # Windows PowerShell : Copy-Item .env.example .env
docker compose up -d --wait   # construit l'API, démarre la base et l'API
docker compose ps             # les services doivent être "healthy" / "running"
```

Vérifications :

- http://localhost:3000 affiche le catalogue et le bandeau `v1.0.0 - local`
- http://localhost:3000/api/sante renvoie `{"statut":"ok","base":"ok"}`

Connexion DBeaver : PostgreSQL, hôte `localhost`, port `5432`, base `shoplab`, utilisateur `shoplab`, mot de passe `shoplab`.

Si un port est déjà utilisé sur le poste (PostgreSQL local, autre application), modifier `DB_PORT`, `APP_PORT` ou `ADMINER_PORT` dans `.env`.

Interface Adminer (optionnelle) : `docker compose --profile outils up -d`, puis http://localhost:8080 (système PostgreSQL, serveur `db`).

---

## 2. Commandes utiles

| Besoin | Commande |
|--------|----------|
| Démarrer | `docker compose up -d --wait` |
| Voir l'état | `docker compose ps` |
| Lire les logs de l'API | `docker compose logs -f api` |
| Ouvrir un terminal SQL | `docker compose exec db psql -U shoplab -d shoplab` |
| Arrêter (données conservées) | `docker compose down` |
| Supprimer les données et repartir du seed | `docker compose down -v` puis `docker compose up -d --wait` |

Scripts fournis (dossier `scripts/`, version `.sh` pour macOS / Linux / Git Bash, `.ps1` pour Windows PowerShell) :

| Script | Effet |
|--------|-------|
| `reset` | Remise à zéro complète : supprime le volume, recrée la base (schéma + seed) |
| `reset-seed` | Vide les tables et rejoue le seed, sans toucher au conteneur |
| `snapshot [nom]` | Sauvegarde l'état courant dans `snapshots/<nom>.dump` |
| `restore <nom>` | Supprime la base puis restaure `snapshots/<nom>.dump` (aucun objet créé après le snapshot ne subsiste) |
| `empreinte` | Affiche les volumes et sommes de contrôle de la base |

---

## 3. Plusieurs environnements sur le même poste

Les fichiers `env/test.env` et `env/recette.env` décrivent deux autres environnements (ports, mot de passe, nom d'environnement différents). Le nom de projet `-p` isole les conteneurs et les volumes :

```bash
docker compose -p shoplab-test    --env-file env/test.env    up -d --wait   # API sur :3001, base sur :5433
docker compose -p shoplab-recette --env-file env/recette.env up -d --wait   # API sur :3002, base sur :5434
docker compose -p shoplab-test    --env-file env/test.env    down -v
```

Les scripts utilisent le projet courant : `export COMPOSE_PROJECT_NAME=shoplab-test` (PowerShell : `$env:COMPOSE_PROJECT_NAME="shoplab-test"`) avant de les lancer.

---

## 4. Modèle de données

```
clients 1---n adresses
clients 1---n commandes n---1 codes_promo
commandes 1---n lignes_commande n---1 produits n---1 categories
commandes 1---n paiements
commandes 1---n historique_statuts
clients 1---n avis n---1 produits
```

| Table | Contenu | Points d'attention |
|-------|---------|--------------------|
| `clients` | Comptes clients | Données personnelles (nom, e-mail, téléphone, date de naissance, hash du mot de passe) |
| `adresses` | Adresses de livraison | Données personnelles |
| `categories`, `produits` | Catalogue | `stock` non contraint techniquement |
| `codes_promo` | Codes promotionnels | Validité par dates et montant minimum |
| `commandes` | En-tête de commande | Montants calculés et stockés |
| `lignes_commande` | Détail des produits commandés | Prix figé au moment de la commande |
| `historique_statuts` | Trace des changements de statut | Permet de contrôler les transitions |
| `paiements` | Tentatives de paiement | Seuls les 4 derniers chiffres de carte sont stockés |
| `avis` | Notes et commentaires clients | Note de 1 à 5 |

---

## 5. Règles métier (spécification)

| Id | Règle |
|----|-------|
| RG01 | Livraison STANDARD : 4,90 EUR si le montant des produits est strictement inférieur à 50,00 EUR, offerte à partir de 50,00 EUR |
| RG02 | Livraison EXPRESS : 9,90 EUR quel que soit le montant |
| RG03 | Retrait en point relais (RETRAIT) : gratuit, pas d'adresse de livraison |
| RG04 | Quantité par ligne de commande : de 1 à 10 |
| RG05 | Un code promo s'applique s'il est actif, si la date de commande est comprise entre `date_debut` et `date_fin` (incluses) et si le montant des produits est supérieur ou égal à `montant_minimum`. La remise porte sur le montant des produits ; les frais de livraison sont calculés sur le montant des produits avant remise |
| RG06 | Transitions de statut autorisées : CREEE vers PAYEE ou ANNULEE ; PAYEE vers EXPEDIEE ou ANNULEE ; EXPEDIEE vers LIVREE. LIVREE et ANNULEE sont des états finaux |
| RG07 | Une commande PAYEE, EXPEDIEE ou LIVREE possède un paiement ACCEPTE dont le montant est égal au montant total. Une commande annulée après paiement a son paiement au statut REMBOURSE |
| RG08 | L'adresse e-mail identifie un client de manière unique (sans distinction de casse) |
| RG09 | Le client doit être majeur à la date d'inscription |
| RG10 | Le stock d'un produit ne peut pas être négatif |
| RG11 | Seul un client ayant reçu un produit (commande LIVREE) peut laisser un avis sur ce produit |
| RG12 | `montant_produits` = somme des (quantité x prix unitaire) des lignes ; `montant_total` = `montant_produits` - `remise` + `frais_livraison` |

Une partie de ces règles est vérifiée par l'API lors de la création d'une commande, mais **pas toutes par la base** : les données historiques peuvent donc contenir des écarts. Les détecter fait partie du travail du testeur.

---

## 6. API

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/sante` | État de l'API et de la connexion à la base |
| GET | `/api/version` | Version et nom de l'environnement |
| GET | `/api/produits` | Produits actifs |
| GET | `/api/commandes?statut=LIVREE` | 100 dernières commandes, filtre optionnel |
| GET | `/api/commandes/{numero}` | Détail : lignes, paiements, historique |
| POST | `/api/commandes` | Création (corps ci-dessous) |
| POST | `/api/commandes/{numero}/statut` | Changement de statut `{"statut": "PAYEE"}` |

```json
{
  "client_id": 1,
  "mode_livraison": "STANDARD",
  "code_promo": "BIENVENUE10",
  "lignes": [{ "produit_id": 2, "quantite": 1 }]
}
```

Exemple en ligne de commande :

```bash
curl -X POST http://localhost:3000/api/commandes -H "Content-Type: application/json" \
  -d '{"client_id":1,"mode_livraison":"STANDARD","lignes":[{"produit_id":2,"quantite":1}]}'
```

---

## 7. Jeu de données de référence (seed 1.0.0)

Fichier `db/init/02_seed.sql`, chargé automatiquement au premier démarrage. Données entièrement fictives : e-mails sur les domaines réservés `example.com/.org/.net`, téléphones dans la plage `06 39 98 xx xx` réservée à la fiction.

| Élément | Valeur attendue |
|---------|-----------------|
| clients | 50 |
| adresses | 58 |
| produits | 30 |
| codes_promo | 6 |
| commandes | 80 |
| lignes_commande | 199 |
| historique_statuts | 250 |
| paiements | 75 |
| avis | 39 |
| somme_montant_total | 13962.62 |
| somme_stock | 2212 |
| empreinte_md5 | d58c4f7f99dee659737ed517d57b0a74 |

Ces valeurs sont obtenues avec `scripts/empreinte`. Toute différence signifie que la base n'est plus dans l'état de référence.
