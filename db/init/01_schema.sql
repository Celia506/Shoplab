-- =============================================================================
-- ShopLab - Application fil rouge e-commerce
-- Schema de la base de donnees (PostgreSQL 16)
-- Module M07 - Donnees de test & environnements
-- =============================================================================
-- Ce script est execute automatiquement au premier demarrage du conteneur
-- PostgreSQL (repertoire /docker-entrypoint-initdb.d).
-- Certaines regles metier ne sont volontairement PAS garanties par des
-- contraintes techniques : c'est au testeur de les controler (voir README).
-- =============================================================================

SET client_encoding = 'UTF8';

-- -----------------------------------------------------------------------------
-- Clients
-- -----------------------------------------------------------------------------
CREATE TABLE clients (
    id                     SERIAL PRIMARY KEY,
    email                  VARCHAR(150) NOT NULL UNIQUE,
    mot_de_passe_hash      VARCHAR(100) NOT NULL,
    prenom                 VARCHAR(60)  NOT NULL,
    nom                    VARCHAR(60)  NOT NULL,
    telephone              VARCHAR(20),
    date_naissance         DATE,
    date_inscription       TIMESTAMP    NOT NULL DEFAULT now(),
    statut                 VARCHAR(10)  NOT NULL DEFAULT 'ACTIF'
                           CHECK (statut IN ('ACTIF', 'SUSPENDU', 'SUPPRIME')),
    consentement_marketing BOOLEAN      NOT NULL DEFAULT false
);

COMMENT ON TABLE clients IS 'Comptes clients de la boutique';
COMMENT ON COLUMN clients.statut IS 'ACTIF, SUSPENDU ou SUPPRIME (compte cloture a la demande du client)';

-- -----------------------------------------------------------------------------
-- Adresses de livraison
-- -----------------------------------------------------------------------------
CREATE TABLE adresses (
    id           SERIAL PRIMARY KEY,
    client_id    INTEGER      NOT NULL REFERENCES clients(id),
    libelle      VARCHAR(30)  NOT NULL DEFAULT 'Domicile',
    rue          VARCHAR(150) NOT NULL,
    code_postal  VARCHAR(10)  NOT NULL,
    ville        VARCHAR(80)  NOT NULL,
    pays         VARCHAR(2)   NOT NULL DEFAULT 'FR',
    par_defaut   BOOLEAN      NOT NULL DEFAULT false
);

-- -----------------------------------------------------------------------------
-- Catalogue
-- -----------------------------------------------------------------------------
CREATE TABLE categories (
    id   SERIAL PRIMARY KEY,
    nom  VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE produits (
    id            SERIAL PRIMARY KEY,
    reference     VARCHAR(20)   NOT NULL UNIQUE,
    nom           VARCHAR(120)  NOT NULL,
    categorie_id  INTEGER       NOT NULL REFERENCES categories(id),
    prix_ttc      NUMERIC(10,2) NOT NULL CHECK (prix_ttc > 0),
    stock         INTEGER       NOT NULL DEFAULT 0,   -- RG10 : stock >= 0 (non contraint)
    poids_g       INTEGER       NOT NULL DEFAULT 0,
    actif         BOOLEAN       NOT NULL DEFAULT true
);

-- -----------------------------------------------------------------------------
-- Codes promotionnels
-- -----------------------------------------------------------------------------
CREATE TABLE codes_promo (
    id               SERIAL PRIMARY KEY,
    code             VARCHAR(20)   NOT NULL UNIQUE,
    type_remise      VARCHAR(12)   NOT NULL CHECK (type_remise IN ('POURCENTAGE', 'MONTANT')),
    valeur           NUMERIC(10,2) NOT NULL CHECK (valeur > 0),
    date_debut       DATE          NOT NULL,
    date_fin         DATE          NOT NULL,
    montant_minimum  NUMERIC(10,2) NOT NULL DEFAULT 0,
    actif            BOOLEAN       NOT NULL DEFAULT true
);

-- -----------------------------------------------------------------------------
-- Commandes
-- -----------------------------------------------------------------------------
CREATE TABLE commandes (
    id                    SERIAL PRIMARY KEY,
    numero                VARCHAR(20)   NOT NULL UNIQUE,
    client_id             INTEGER       NOT NULL REFERENCES clients(id),
    adresse_livraison_id  INTEGER       REFERENCES adresses(id),   -- NULL si RETRAIT
    date_commande         TIMESTAMP     NOT NULL DEFAULT now(),
    statut                VARCHAR(10)   NOT NULL DEFAULT 'CREEE'
                          CHECK (statut IN ('CREEE', 'PAYEE', 'EXPEDIEE', 'LIVREE', 'ANNULEE')),
    mode_livraison        VARCHAR(10)   NOT NULL
                          CHECK (mode_livraison IN ('STANDARD', 'EXPRESS', 'RETRAIT')),
    code_promo_id         INTEGER       REFERENCES codes_promo(id),
    montant_produits      NUMERIC(10,2) NOT NULL DEFAULT 0,
    remise                NUMERIC(10,2) NOT NULL DEFAULT 0,
    frais_livraison       NUMERIC(10,2) NOT NULL DEFAULT 0,
    montant_total         NUMERIC(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE lignes_commande (
    id             SERIAL PRIMARY KEY,
    commande_id    INTEGER       NOT NULL REFERENCES commandes(id),
    produit_id     INTEGER       NOT NULL REFERENCES produits(id),
    quantite       INTEGER       NOT NULL CHECK (quantite > 0),   -- RG04 : max 10 (non contraint)
    prix_unitaire  NUMERIC(10,2) NOT NULL
);

CREATE TABLE historique_statuts (
    id              SERIAL PRIMARY KEY,
    commande_id     INTEGER     NOT NULL REFERENCES commandes(id),
    ancien_statut   VARCHAR(10),
    nouveau_statut  VARCHAR(10) NOT NULL,
    date_changement TIMESTAMP   NOT NULL DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- Paiements
-- -----------------------------------------------------------------------------
CREATE TABLE paiements (
    id               SERIAL PRIMARY KEY,
    commande_id      INTEGER       NOT NULL REFERENCES commandes(id),
    date_paiement    TIMESTAMP     NOT NULL DEFAULT now(),
    montant          NUMERIC(10,2) NOT NULL,
    moyen            VARCHAR(10)   NOT NULL CHECK (moyen IN ('CB', 'PAYPAL', 'VIREMENT')),
    statut           VARCHAR(10)   NOT NULL CHECK (statut IN ('ACCEPTE', 'REFUSE', 'REMBOURSE')),
    carte_4_derniers CHAR(4)
);

-- -----------------------------------------------------------------------------
-- Avis clients
-- -----------------------------------------------------------------------------
CREATE TABLE avis (
    id           SERIAL PRIMARY KEY,
    produit_id   INTEGER   NOT NULL REFERENCES produits(id),
    client_id    INTEGER   NOT NULL REFERENCES clients(id),
    note         SMALLINT  NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire  TEXT,
    date_avis    TIMESTAMP NOT NULL DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- Index utiles aux requetes de controle
-- -----------------------------------------------------------------------------
CREATE INDEX idx_commandes_client  ON commandes(client_id);
CREATE INDEX idx_commandes_statut  ON commandes(statut);
CREATE INDEX idx_lignes_commande   ON lignes_commande(commande_id);
CREATE INDEX idx_paiements_commande ON paiements(commande_id);
