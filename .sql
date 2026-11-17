/*A1. Produits actifs du plus cher au moins cher*/
SELECT * FROM produits
order by prix_ttc desc;

/*A2. Produits en rupture de stock */
SELECT reference, nom, prix_ttc FROM produits 
where stock <= 0;

/*A3. Clients inscrits en 2026*/
SELECT email, prenom, nom FROM clients 
where date_inscription >= '2026-01-01' 
and date_inscription  <= '2026-12-31';
/*OU*/
SELECT email, prenom, nom FROM clients 
where date_inscription 
BETWEEN '2026-01-01' and '2027-01-01';

/*A4. Produits dont le nom contient "lot */
SELECT * FROM produits 
where nom Ilike '%lot%';

/*A5. Clients sans téléphone ou sans date de naissance */
SELECT * FROM clients
WHERE telephone is null 
and date_naissance is null;

/*A6. Commandes STANDARD de plus de 100 EUR*/
SELECT * FROM commandes 
WHERE mode_livraison = 'STANDARD' 
and montant_total > '100';

-- A7. Nombre de commandes par statut.
SELECT count(numero),c.statut  
FROM commandes c 
group by  c.statut;

-- A8. Pour les commandes livrées : nombre, chiffre d'affaires et panier moyen par mode de livraison.
SELECT mode_livraison,
      avg(c.montant_total) as panier_moyen,
      count(c.id) as nombre_commande, 
      sum(c.montant_total) as chiffre_affaire
FROM commandes c 
where c.statut = 'LIVREE'
Group by mode_livraison;

-- A9. Liste des commandes avec le prénom et le nom du client.
SELECT 
      co.numero, 
      cl.prenom, 
      cl.nom 
FROM clients cl
JOIN commandes co
ON cl.id = co.client_id;

-- A10. Détail de la commande CMD-2026-00007 : référence et nom des produits, quantité, prix unitaire, sous-total. 
SELECT 
      p.reference,
      p.nom,
      lc.quantite,
      lc.prix_unitaire,
      (lc.quantite * lc.prix_unitaire) AS sous_total,
      c.montant_produits
FROM commandes c
JOIN lignes_commande lc ON c.id = lc.commande_id
JOIN produits p ON p.id = lc.produit_id
WHERE c.numero = 'CMD-2026-00007';
-- le sous_total a une differnece de 5 euro avec le total - la livraison

-- A11. Clients qui n'ont jamais passé de commande.
Select 
      cl.id, 
      cl.prenom, 
      cl.nom 
FROM clients cl 
LEFT JOIN commandes c ON c.client_id = cl.id 
Where c.id is NULL
-- avec left join , je recupere tout les clients meme si il ny a pas de commande_id donc NULL,

-- A12. Top 5 des produits les plus vendus en quantité, hors commandes annulées.
SELECT 
      p.nom,
      p.reference,
		SUM(lc.quantite) AS quantite_vendue
FROM produits p 
JOIN lignes_commande lc ON lc.produit_id = p.id
JOIN commandes c ON c.id = lc.commande_id
where c.statut <> 'ANNULEE'
GROUP BY  p.id, p.nom , p.reference
ORDER by quantite_vendue desc
LIMIT 5


-- A13. Chiffre d'affaires mensuel des commandes livrées.

-- A14. Catégories dont le chiffre d'affaires (hors annulations) dépasse 1 000 EUR.

-- A15. Pour chaque code promo : nombre d'utilisations et remise totale accordée (y compris les codes jamais utilisés).