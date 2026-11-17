/*A1. Produits actifs du plus cher au moins cher*/
select * from produits
order by prix_ttc desc

/*A2. Produits en rupture de stock */
select * from produits 
where stock = 0

/*A3. Clients inscrits en 2026*/
select * from clients 
where date_inscription >= '2026-01-01' 
and date_inscription  <= '2026-12-31'

/*A4. Produits dont le nom contient "lot */
select * from produits 
where nom like '%lot%'

/*A5. Clients sans téléphone ou sans date de naissance */
select * FROM clients
WHERE telephone is null and date_naissance is null

/*A6. Commandes STANDARD de plus de 100 EUR*/
SELECT * FROM public.commandes 
WHERE mode_livraison = 'STANDARD' and montant_total >= '100'