-- =============================================================================
-- Empreinte de l'etat de la base ShopLab
-- A executer apres une restauration pour verifier le retour a l'etat de reference.
-- Valeurs attendues pour le seed 1.0.0 : voir README (section Empreinte).
-- =============================================================================
SELECT 'clients'            AS element, COUNT(*)::text AS valeur FROM clients
UNION ALL SELECT 'adresses',           COUNT(*)::text FROM adresses
UNION ALL SELECT 'produits',           COUNT(*)::text FROM produits
UNION ALL SELECT 'codes_promo',        COUNT(*)::text FROM codes_promo
UNION ALL SELECT 'commandes',          COUNT(*)::text FROM commandes
UNION ALL SELECT 'lignes_commande',    COUNT(*)::text FROM lignes_commande
UNION ALL SELECT 'historique_statuts', COUNT(*)::text FROM historique_statuts
UNION ALL SELECT 'paiements',          COUNT(*)::text FROM paiements
UNION ALL SELECT 'avis',               COUNT(*)::text FROM avis
UNION ALL SELECT 'somme_montant_total', COALESCE(SUM(montant_total), 0)::text FROM commandes
UNION ALL SELECT 'somme_stock',        COALESCE(SUM(stock), 0)::text FROM produits
UNION ALL SELECT 'empreinte_md5',      md5(string_agg(numero || statut || montant_total, ',' ORDER BY id)) FROM commandes;
