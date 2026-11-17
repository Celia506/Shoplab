/*A1. Produits actifs du plus cher au moins cher*/
select * from produits
order by prix_ttc desc

/*A2. Produits en rupture de stock */
select reference, nom, prix_ttc from produits 
where stock <= 0

/*A3. Clients inscrits en 2026*/
select email, prenom, nom from clients 
where date_inscription >= '2026-01-01' 
and date_inscription  <= '2026-12-31'
/*OU*/
select email, prenom, nom from clients 
where date_inscription BETWEEN '2026-01-01' and '2027-01-01'

/*A4. Produits dont le nom contient "lot */
select * from produits 
where nom Ilike '%lot%'

/*A5. Clients sans téléphone ou sans date de naissance */
select * FROM clients
WHERE telephone is null and date_naissance is null

/*A6. Commandes STANDARD de plus de 100 EUR*/
SELECT * FROM commandes 
WHERE mode_livraison = 'STANDARD' and montant_total > '100'

