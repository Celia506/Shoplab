-- Vide toutes les tables et remet les sequences a 1.
-- Utilise par scripts/reset-seed avant de rejouer 02_seed.sql.
TRUNCATE avis, paiements, historique_statuts, lignes_commande, commandes,
         codes_promo, produits, categories, adresses, clients
RESTART IDENTITY CASCADE;
