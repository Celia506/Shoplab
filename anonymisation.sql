-- Étape 3 : script d'anonymisation (25 min)
-- Écrivez anonymisation.sql, encadré par une transaction, qui applique vos techniques. Contraintes :
 
--1.  L'unicité de l'e-mail est conservée (contrainte UNIQUE)
 
UPDATE clients
SET email = 'qa_' || gen_random_uuid() || '@test.fr'
Select count (*) from clients where email not like 'qa_%@test.fr';
 
-- mot de passe
update clients set mot_de_passe_hash = MD5('MotDePasse_Test') ;
 
-- Nom prenom
UPDATE clients SET NOM = 'test';
UPDATE clients SET prenom = 'TEST';
 
-- client.telephone  masquage pas besoin car deja masquer
 
-- client date de naissance '' generalisation:
update clients set date_naissance = make_date(extract (year FROM date_naissance)::int, 7, 1);
select date_naissance  from clients
 
-- Adresses
Update adresses  SET libelle = 'null';
select count(*) from adresses where libelle = 'null'; car not null
 
UPDATE adresses set code_postal = left(code_postal, 2) || '000';
select code_postal from adresses;
 
Update adresses SET rue = '6 rue test';
select rue from adresses ;
 
update adresses set ville = 'xxxxx';
select ville from adresses ;
 
-- Pour le pays pas besoin car pas sensible car tous 'FR'
 
-- CB
UPDATE paiements SET carte_4_derniers = NULL;
 
Select count (*) from paiements where carte_4__derniers is not NULL    ( pour la vérification )
 
Select count (*) from avis where commentaires <> 'anonymisé';
 
select count(*) from clients where nom <> 'test'
 
-- Commentaires
UPDATE avis SET commentaire = 'anonymisé'
Select count (*) from avis where commentaires <> 'anonymisé';










-- Etape 4 : Controles

-- aucun e-mail d'origine ne subsiste (comment le vérifier sans les avoir gardés ?)
Select count (*) from clients where email not like 'qa_%@test.fr';

--les volumes de chaque table sont inchangés

select count(*) from adresses;
select count(*) from avis;
select count(*) from categories;
select count(*) from clients;
select count(*) from codes_promo;
select count(*) from commandes;
select count(*) from historique_statuts;
select count(*) from lignes_commande;
select count(*) from paiements;
select count(*) from produits;

-- les dates de naissance sont toutes généralisées

select count(*) from clients where date_naissance = make_date(extract (year FROM date_naissance)::int, 7, 1) or date_naissance is null;

-- aucune violation nouvelle des règles RG01 à RG12

-- On rejoue le script de vérification des règles RG01 à RG12 fait dans les TP précédents (Atelier J2 - partie B)

-- Voir la suite des réponses sur le doc.