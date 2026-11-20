# Dossier de synthèse M07 - Préparation des données et de l'environnement de la campagne ShopLab 1.0

> Modèle de plan. Remplacez chaque texte entre crochets, supprimez les consignes en citation une fois la section rédigée.

## 0. Présentation

| Élément                   | Valeur                                                        |
| ------------------------- | ------------------------------------------------------------- |
| Groupe                    | [Axel DAGUERRE, Sarra HARAKATI, Adrien CIRADE, Celia SANSANO] |
| Date de rendu             | 20/11/2026                                                    |
| Application               | ShopLab 1.0.0                                                 |
| Données de référence      | seed 1.0.0                                                    |
| Version du catalogue      | [ex. 1.3]                                                     |
| Graine du jeu synthétique | [ex. 42]                                                      |
| Environnement             | Docker / Dbeaver                                              |

**Répartition des contributions**
Tout a été fait ensemble (partage d'écran)

**Harmonisation** (si les productions viennent de plusieurs personnes) : [ce qui a dû être mis en cohérence : conventions, identifiants, versions, et les choix faits]

- NB : première partie (groupe duo imposé -> Atelier J1) Sarra avec Axel. Adrien a fait le travail en solo.
  A partir du Atelier J2 on a fait le travail en groupe de 4

## 1. Le besoin en données

> Qu'avons-nous fait ? Pourquoi est-ce nécessaire ? Qu'est-ce que cela change pour le testeur ?

- Activité J1 : On a analysé les ambiguïtés en se basant sur la doc du projet (RG + contexte). On a également, trouvé les éléments manquants pour exécuter les cas de tests existants.
- C'est nécessaire pour être sûr de couvrir chaque exigences avec des jeux de données cohérents.
- Ce qui nous permet d'avoir de bon test avec un résultats attentu représentatif. Ce qui nous évite des "Faux positif" et "Faux négatif"

**Matrice de traçabilité** (au moins 15 lignes ; peut être placée en annexe)

| Cas de test | JDD                                                | Donnée (et valeur limite eventuelle)                                                          | Création ou extraction      | Contrôle                    | État après exécution                                                      |
| ----------- | -------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------- | --------------------------- | ------------------------------------------------------------------------- |
| CT-LIV-02   | adresse mail, mdp, tel, adresse postal, produit(s) | qa.client@CT-LIV-02.com, QaClientMdp666!, 0699669966, 10 Rue de Qa 66632 Paris, lampe (=50 €) | `\explorer_shoplab.sql.sql` | `\explorer_shoplab.sql.sql` | C'est une extraction de donnée, donc elles sont toujours présentes en BDD |

---

## 2. Connaître la base avant de tester

> Ce que contient la base, comment on le vérifie, les incohérences trouvées, et ce qu'on en fait.

- Atelier J2 : On a appris à faire des requêtes SQL afin d'extraire des données, faire des jointures, mise à jour de données, de la création et de la suppression ( update, select, insert, delete, jointure).

Renvois : `\explorer_shoplab.sql.sql`

## 3. Préparer ses données

- Atelier J2 : Toutes ces requetes nous ont servit pour faire un script SQL de génération de donnés de test, puis de nettoyage (à la fin de l'exécution de test).

Renvois : `\explorer_shoplab.sql.sql`

## 4. Données personnelles et données synthétiques

- Une donnée est personnelle dès qu'elle permet de remonté à un individu ou quand elle est croisé avec d'autre donnée qui identifie une personne.
- Qu'en tant que testeur nous n'avons pas le droit (RGPD) de conserver les données personnelle sur un environement de test. Nous devons rendre ces données synthétiques (anonymisation ou pseudonisation)

## 5. L'environnement de test

- On a découvert Docker (on connaissait de nom) et mieux compris son rôle et son utilité au sein des tests (remise en état du contenant).
- On a utilisé Dbeaver qui est un outil pratique afin de visiualisé la BDD et de la manipuler facilement. Il existe d'autre outil SQL de ce genre qui peuvent nous être utile dans l'équipe de test.

## 6. Reproductibilité

- Via Docker, on a appris qu'il est possible facilement d'avoir le même environnement isolée du client, ce qui nous permet de reproduire des bugs rencontrés sur site avec la même config.
- L'utilisation de script SQL dédié par test, permet de facilité la reproductibilité des tests avec les mêmes données.

## 7. Procédure de remise à l'état initial

**Point de départ** : [outils installés, dépôt récupéré, rien de démarré]

| Étape | Commande             | Résultat attendu                                              |
| ----- | -------------------- | ------------------------------------------------------------- |
| 1     | docker compose up -d | Pas de message d'erreur + création du conteneur               |
| 2     | docker compose ps    | Pas de message d'erreur, tout les services sont bien démarrés |

**Empreinte de référence de l'état de campagne**

| Élément       | Valeur |
| ------------- | ------ |
| commandes     |        |
| empreinte_md5 |        |

**En cas d'échec**

| Symptôme                    | Cause probable           | Action |
| --------------------------- | ------------------------ | ------ |
| un conteneur ne demarre pas | verifier les logs docker |

      connextion BDD impossible      |    veriifer les conteneurs et les parametre de connexion    |

---

## 8. Bilan : le métier de testeur

Le testeur doit s'assurer de la fiabilité des tests en maîtrisant les données utilisées et l'environnement dans lequel ils sont exécutés.

Il doit également faire attention au respect du RGPD, notamment en évitant l'utilisation de données personnelles réelles.

La préparation des données, leur traçabilité, le nettoyage après les tests et la reproductibilité de l'environnement sont donc des éléments essentiels pour obtenir des résultats fiables et exploitables.

## 9. Parties individuelles

### Sansano Celia

1. J'ai essayé de comprendre de nombreuses nouvelles notions. Je connaissais déjà la plupart des aspects techniques, mais j'ai encore du mal à me positionner dans le rôle du testeur. J'ai tendance à raisonner davantage comme une développeuse. C'était seulement ma deuxième semaine de formation et j'ai trouvé certains exercices difficiles à comprendre. Les énoncés ne me semblaient pas toujours très clairs, notamment lorsqu'on découvre le métier du test et que l'on n'a pas encore les bons réflexes.

2. L'étape qui m'a le plus appris :J'ai mieux compris le respect du RGPD, rechercher les informations nécessaires et identifier les données utiles à la préparation des tests.

3. Une situation où une donnée ou un environnement mal maîtrisé aurait faussé un résultat :Par exemple, si un test porte sur une commande avec un produit disponible en stock, mais que la donnée utilisée ne correspond pas à cette situation, le résultat du test peut être faussé. On pourrait conclure à tort que l'application présente un dysfonctionnement alors que le problème vient simplement du jeu de données utilisé.

### Sansano Célia
