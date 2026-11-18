/*A1. Produits actifs du plus cher au moins cher*/
SELECT
      *
FROM
      produits
order by
      prix_ttc desc;

/*A2. Produits en rupture de stock */
SELECT
      reference,
      nom,
      prix_ttc
FROM
      produits
where
      stock <= 0;

/*A3. Clients inscrits en 2026*/
SELECT
      email,
      prenom,
      nom
FROM
      clients
where
      date_inscription >= '2026-01-01'
      and date_inscription <= '2026-12-31';

/*OU*/
SELECT
      email,
      prenom,
      nom
FROM
      clients
where
      date_inscription BETWEEN '2026-01-01'
      and '2027-01-01';

/*A4. Produits dont le nom contient "lot */
SELECT
      *
FROM
      produits
where
      nom Ilike '%lot%';

/*A5. Clients sans téléphone ou sans date de naissance */
SELECT
      *
FROM
      clients
WHERE
      telephone is null
      and date_naissance is null;

/*A6. Commandes STANDARD de plus de 100 EUR*/
SELECT
      *
FROM
      commandes
WHERE
      mode_livraison = 'STANDARD'
      and montant_total > '100';

-- A7. Nombre de commandes par statut.
SELECT
      count(numero),
      c.statut
FROM
      commandes c
group by
      c.statut;

-- A8. Pour les commandes livrées : nombre, chiffre d'affaires et panier moyen par mode de livraison.
SELECT
      mode_livraison,
      avg(c.montant_total) as panier_moyen,
      count(c.id) as nombre_commande,
      sum(c.montant_total) as chiffre_affaire
FROM
      commandes c
where
      c.statut = 'LIVREE'
Group by
      mode_livraison;

-- A9. Liste des commandes avec le prénom et le nom du client.
SELECT
      co.numero,
      cl.prenom,
      cl.nom
FROM
      clients cl
      JOIN commandes co ON cl.id = co.client_id;

-- A10. Détail de la commande CMD-2026-00007 : référence et nom des produits, quantité, prix unitaire, sous-total. 
SELECT
      p.reference,
      p.nom,
      lc.quantite,
      lc.prix_unitaire,
      (lc.quantite * lc.prix_unitaire) AS sous_total,
      c.montant_produits
FROM
      commandes c
      JOIN lignes_commande lc ON c.id = lc.commande_id
      JOIN produits p ON p.id = lc.produit_id
WHERE
      c.numero = 'CMD-2026-00007';

-- le sous_total a une differnece de 5 euro avec le total - la livraison
-- A11. Clients qui n'ont jamais passé de commande.
Select
      cl.id,
      cl.prenom,
      cl.nom
FROM
      clients cl
      LEFT JOIN commandes c ON c.client_id = cl.id
Where
      c.id is NULL 
      -- avec left join , je recupere tout les clients meme si il ny a pas de commande_id donc NULL,

-- A12. Top 5 des produits les plus vendus en quantité, hors commandes annulées.
SELECT
      p.nom,
      p.reference,
      SUM(lc.quantite) AS quantite_vendue
FROM
      produits p
      JOIN lignes_commande lc ON lc.produit_id = p.id
      JOIN commandes c ON c.id = lc.commande_id
where
      c.statut <> 'ANNULEE'
GROUP BY
      p.nom,
      p.reference
ORDER by
      quantite_vendue desc
LIMIT
      5 

-- A13. Chiffre d'affaires mensuel des commandes livrées.
-- avec date_trunc 
SELECT
      ROUND(SUM(montant_total), 2) ca,
      -- to_char(date_commande, 'YYYY-MM') AS mois,
      date_trunc('month', date_commande) as mois,
      COUNT(*) as nb_commandes
FROM
      commandes
WHERE
      statut = 'LIVREE'
GROUP BY
      mois
ORDER BY
      mois OU -- 5 lignes (juin a octobre 2026)
SELECT
      to_char(date_commande, 'YYYY-MM') AS mois,
      COUNT(*) AS nb,
      SUM(montant_total) AS ca
FROM
      commandes
WHERE
      statut = 'LIVREE'
GROUP BY
      mois
ORDER BY
      mois;

-- A14. Catégories dont le chiffre d'affaires (hors annulations) dépasse 1 000 EUR.
SELECT
      cat.nom as categorie,
      SUM (l.quantite * l.prix_unitaire) AS ca
FROM
      lignes_commande l
      JOIN produits p ON p.id = l.produit_id
      JOIN categories cat ON cat.id = p.categorie_id
      JOIN commandes c ON c.id = l.commande_id
WHERE
      c.statut <> 'ANNULEE'
GROUP BY
      cat.nom
HAVING
      SUM(l.quantite * l.prix_unitaire) > 1000
ORDER BY
      ca DESC 
      
-- A15. Pour chaque code promo : nombre d'utilisations et remise totale accordée (y compris les codes jamais utilisés).
SELECT
      cp.code,
      cp.actif,
      COUNT(c.id) AS utilisations,
      COALESCE (SUM (c.remise),) AS remise_totale
FROM
      codes_promo cp
      LEFT JOIN commandes c ON c.code_promo_id = cp.id
GROUP BY
      cp.code,
      cp.actif
ORDER BY
      utilisations DESC 

-- Partie B 

-- B1 RG01 : frais STANDARD (4,90 sous 50 EUR, 0 à partir de 50 EUR)
select
      c.numero,
      c.montant_total,
      c.frais_livraison,
      c.mode_livraison
from
      commandes c
where
      c.mode_livraison = 'STANDARD'
      and c.montant_total >= '50'
      and c.frais_livraison <> '0'
order by
      c.frais_livraison 
-- commande id en anomalie : 3, 14, 16 -> Payer des frais de livraison alors que le montant total est supérieur à 50 EUR
select
      c.id,
      c.numero,
      c.montant_total,
      c.frais_livraison,
      c.mode_livraison
from
      commandes c
where
      c.montant_total < '50'
      and c.frais_livraison <> '4.9'
order by
      c.frais_livraison -- résultat vide, pas d'anomalie pour les commandes inférieures à 50 EUR

-- B2   RG02 / RG03 : frais EXPRESS = 9,90 ; RETRAIT gratuit et sans adresse
select
      c.id,
      c.numero,
      c.adresse_livraison_id,
      c.mode_livraison,
      c.montant_total,
      c.frais_livraison
from
      commandes c
where
      c.mode_livraison = 'EXPRESS'
      and c.frais_livraison <> '9.90' 

-- RG02 : résultat vide, pas d'anomalie pour les commandes EXPRESS
select
      c.id,
      c.numero,
      c.adresse_livraison_id,
      c.mode_livraison,
      c.montant_total,
      c.frais_livraison
from
      commandes c
where
      c.mode_livraison = 'RETRAIT'
      and c.adresse_livraison_id is not null
      and c.frais_livraison <> '0' 
      
-- RG03 : résultat vide, pas d'anomalie pour les commandes RETRAIT
-- B3   RG04 : quantité de 1 à 10
select
      *
from
      lignes_commande lc
where
      lc.quantite is null
      or lc.quantite < 1
      or lc.quantite > 10 
      
-- commande id en anomalie : 120 -> quantité = 12

-- B4   RG05 : code promo actif, dans sa période, montant minimum atteint
select
      c.id,
      c.date_commande,
      c.code_promo_id,
      cp.date_debut,
      cp.date_fin,
      cp.actif,
      cp.montant_minimum,
      c.montant_total
from
      commandes c
      left join codes_promo cp on c.code_promo_id = cp.id
where
      c.date_commande not between cp.date_debut
      and cp.date_fin
      or c.montant_total < cp.montant_minimum
      or c.code_promo_id is not null
      and cp.actif <> true
order by
      c.code_promo_id 
-- commande id en anomalie : 64 -> date commande en dehors de la période du code promo et code promo désactivé
-- Pas d'anomalie pour le montant minimum atteint

-- B5   RG12 : montant_produits = somme des lignes de commandes
select
      c.id,
      c.montant_produits,
      SUM(lc.quantite * lc.prix_unitaire)
from
      commandes c
      join lignes_commande lc on c.id = lc.commande_id
group by
      c.montant_produits,
      c.id
having
      c.montant_produits <> SUM(lc.quantite * lc.prix_unitaire) 
-- commande id en anomalie : 7 -> montant_produits = 51.7 et somme des lignes de commandes = 46.7

-- B6   RG12 : montant_total = produits - remise + frais
select
      c.id,
      c.montant_total,
      c.montant_produits,
      c.code_promo_id,
      c.remise,
      c.frais_livraison
from
      commandes c
group by
      c.id,
      c.montant_total
having
      c.montant_total <> SUM(
            c.montant_produits - c.remise + c.frais_livraison
      ) 

-- commande id en anomalie : 2 montant total = 119.88 mais la somme des montants = 109.88

-- B7 RG07 : commande PAYEE / EXPEDIEE / LIVREE avec un paiement ACCEPTE du montant total
select
      c.id,
      c.statut as stat_commande,
      c.montant_total
from
      commandes c
where
      c.statut in ('PAYEE', 'EXPEDIEE', 'LIVREE')
      and not exists (
            select
                  1
            from
                  paiements p
            where
                  p.commande_id = c.id
                  and p.statut = 'ACCEPTE'
                  and c.montant_total = p.montant
      ) -- commande id en anomalie : 2,4,59
      
-- B7 RG07 : commande PAYEE / EXPEDIEE / LIVREE avec un paiement ACCEPTE du montant total

select
      c.id,
      c.statut as stat_commande,
      c.montant_total
from
      commandes c
where
      c.statut in ('PAYEE', 'EXPEDIEE', 'LIVREE')
      and not exists (
            select
                  1
            from
                  paiements p
            where
                  p.commande_id = c.id
                  and p.statut = 'ACCEPTE'
                  and c.montant_total = p.montant
      ) -- commande id en anomalie : 2,4,59

-- B8   RG07 : commande annulée sans paiement resté ACCEPTE
select
      c.id,
      c.statut as statut_commande,
      p2.statut as statut_paiement
from
      commandes c
      join paiements p2 on c.id = p2.commande_id
where
      c.statut = 'ANNULEE'
      and p2.statut = 'ACCEPTE'
      
      -- ou
select
      c.id,
      c.statut as statut_commande,
      p2.statut as statut_paiement
from
      commandes c
      join paiements p2 on c.id = p2.commande_id
where
      c.statut = 'ANNULEE'
      and not exists(
            select
                  1
            from
                  paiements p
            where
                  p.commande_id = c.id
                  and p.statut = 'REMBOURSE'
      ) -- commande id en anomalie : 11
      
-- B9   RG06 : aucune transition interdite dans l'historique
select
      hs.id,
      hs.ancien_statut,
      hs.nouveau_statut,
      hs.commande_id
from
      historique_statuts hs
where
      hs.ancien_statut = 'CREEE'
      and hs.nouveau_statut <> 'PAYEE'
      and hs.nouveau_statut <> 'ANNULEE' 
      -- commande id en anomalie : 8 (id 25 historique_statut)
select
      hs.id,
      hs.ancien_statut,
      hs.nouveau_statut,
      hs.commande_id
from
      historique_statuts hs
where
      hs.ancien_statut = 'PAYEE'
      and hs.nouveau_statut <> 'EXPEDIEE'
      and hs.nouveau_statut <> 'ANNULEE' 
      -- Pas d'anomalie pour les transitions PAYEE -> EXPEDIEE ou ANNULEE
select
      hs.id,
      hs.ancien_statut,
      hs.nouveau_statut,
      hs.commande_id
from
      historique_statuts hs
where
      hs.ancien_statut = 'EXPEDIEE'
      and hs.nouveau_statut <> 'LIVREE' 
      -- pas d'anomalie pour les transitions EXPEDIEE -> LIVREE
      
-- B10  RG06 : statut courant = dernier statut de l'historique
select
      hs.id,
      hs.ancien_statut,
      hs.nouveau_statut,
      hs.commande_id
from
      historique_statuts hs
where
      hs.ancien_statut = 'LIVREE'
      and hs.ancien_statut = 'ANNULEE' 
      -- pas d'anomalie. LIVREE et ANNULEE sont des statuts finaux.