# Évaluation M07 - Dossier de synthèse de la démarche de test

**Module** : M07 - Données de test & environnements : fiabilité et reproductibilité
**Bloc RNCP** : Bloc 2 - Conception et exécution des tests
**Date** : vendredi 11/12/2026, 14h00 à 17h00 (3h)
**Modalité** : en groupe de 4 personnes maximum, ou individuelle
**Documents autorisés** : tous les supports et productions de la semaine
**Assistant IA** : autorisé, à condition de consigner chaque usage dans le journal des prompts (modèle M01) et de ne jamais y saisir de données réelles

---

## L'idée

Pendant la semaine, vous avez produit beaucoup de choses : un catalogue de jeux de données, des requêtes de contrôle, des scripts de préparation, une anonymisation, un jeu synthétique, une fiche d'environnement, une procédure de restauration. Pris séparément, ce sont des exercices. Mis bout à bout, c'est **le travail réel d'un testeur qui prépare une campagne**.

L'évaluation vous demande de **constituer un dossier de synthèse unique et cohérent** à partir de vos productions. Ce dossier montre que vous avez compris la démarche globale : pourquoi chaque étape existe, ce qu'elle apporte à la suivante, et ce qu'elle change pour le métier de testeur.

Il n'y a **pas de nouveau travail technique** à réaliser. Vous reprenez, corrigez, harmonisez et reliez ce que vous avez fait du lundi au jeudi.

## Le contexte

L'équipe QA de ShopLab prépare la campagne de recette de la version 1.0 (`ressources/Contexte_Campagne_ShopLab.md`). Votre responsable de test vous demande un dossier qui permette à **un testeur qui arrive dans l'équipe** :

1. de comprendre quelles données la campagne utilise, et pourquoi ;
2. d'obtenir l'environnement et les données de la campagne **sans votre aide** ;
3. de vérifier **objectivement** que l'état obtenu est le bon ;
4. de savoir ce qu'il faut faire, et ne pas faire, avec les données de test.

**Le formateur jouera ce nouveau testeur** : il lira votre dossier, puis exécutera votre procédure telle qu'écrite sur un environnement neuf.

---

## Travailler en groupe

- **Constitution** : 4 personnes maximum. Vous pouvez reprendre votre groupe de la semaine, ou mettre en commun le travail de personnes qui travaillaient séparément. Un rendu individuel est également accepté.
- **Mise en commun** : si vos productions viennent de plusieurs personnes, elles ne sont pas cohérentes d'office (conventions de nommage, versions du catalogue, identifiants, graines). **Les harmoniser fait partie du travail évalué.**
- **Note** : le dossier reçoit une note commune. Chaque membre rédige en plus une **partie individuelle signée**, notée individuellement (section 9 du dossier). Un rendu individuel comporte aussi cette partie.
- **Répartition** : le dossier indique qui a contribué à quelle section.

---

## Le dossier attendu

Un **document principal** (`Dossier_Synthese_M07.md` ou `.pdf`), qui suit le fil de la démarche, et un dossier **`annexes/`** qui contient les productions auxquelles il renvoie. Le document principal ne recopie pas les scripts : il les présente, les justifie et y renvoie.

Un modèle de plan est fourni : `evaluation2/Modele_Dossier_Synthese.md`.

Longueur indicative : **15 pages maximum** hors annexes et hors parties individuelles.

### Les sections imposées

| # | Section | Ce que vous montrez | Productions mobilisées |
|---|---------|---------------------|------------------------|
| 0 | Présentation | Composition du groupe, répartition des contributions, versions utilisées (ShopLab, seed, catalogue, graine) | - |
| 1 | Le besoin en données | Comment on passe d'un cas de test aux données qui le rendent exécutable ; types de données utilisés ; valeurs limites | Activités J1, catalogue |
| 2 | Connaître la base avant de tester | Ce que contient la base de référence, comment on le vérifie, quelles incohérences on y a trouvées et ce qu'on en fait | Requêtes d'exploration et de contrôle, tableau des anomalies, fiches d'anomalie, réponse à B18 |
| 3 | Préparer ses données | Comment on crée des données de test fiables, identifiables et supprimables ; pourquoi un script rejouable | Scripts de préparation et de nettoyage |
| 4 | Données personnelles et données synthétiques | Quelles données sont sensibles, comment on les protège, quand on préfère des données synthétiques | Inventaire, script d'anonymisation, commande du générateur et graine |
| 5 | L'environnement de test | Ce qui compose l'environnement, comment on prouve qu'il est le bon, comment on diagnostique une panne | Fiche d'identité, tableau de diagnostic, smoke test |
| 6 | Reproductibilité | Comment on revient à un état connu, comment on le prouve, ce qui menace la reproductibilité (données datées, modifications manuelles) | Comparaison des stratégies, empreinte, checklist |
| 7 | Procédure de remise à l'état initial | La procédure complète, d'un poste neuf à l'état de campagne, avec l'empreinte attendue | Procédure consolidée |
| 8 | Bilan : le métier de testeur | Une page : ce que la démarche apporte au testeur et à l'équipe, ses limites, ce que vous feriez autrement | - |
| 9 | Parties individuelles | Une demi-page signée par membre | - |

### La traçabilité, fil rouge du dossier

Le dossier contient une **matrice de traçabilité** (en section 1 ou en annexe) qui relie, pour au moins 15 jeux de données :

`cas de test (CT-...)` → `jeu de données (JDD-...)` → `script ou requête qui le crée ou l'extrait` → `requête de contrôle qui le vérifie` → `état après exécution`

C'est cette matrice qui prouve la cohérence : un identifiant cité dans une section doit se retrouver, identique, dans les autres et dans les annexes.

### Pour chaque section 1 à 6

Répondez à trois questions, en quelques lignes chacune :

1. **Qu'avons-nous fait ?** Résumé, avec renvoi vers l'annexe.
2. **Pourquoi est-ce nécessaire ?** Le problème concret que cette étape évite, idéalement illustré par un exemple vu dans la semaine.
3. **Qu'est-ce que cela change pour le testeur ?** Ce que l'étape permet à un testeur, à l'équipe, ou à la campagne.

### Section 7 : la procédure

- Point de départ : un poste avec les outils du cours installés (Docker, DBeaver, Python), le dépôt du cours, et **rien de démarré**.
- Point d'arrivée : l'état de campagne décrit dans votre dossier (seed 1.0.0, vos données de préparation, votre jeu synthétique), avec son **empreinte de référence** relevée par vos soins.
- Chaque commande est écrite telle qu'elle doit être tapée. Prévoyez une section "En cas d'échec".

### Section 9 : la partie individuelle

Chaque membre rédige, seul et sous son nom, une demi-page qui répond à :

1. Quelle a été ma contribution au dossier ?
2. Quelle étape de la démarche m'a le plus appris, et pourquoi ?
3. Une situation de la semaine où une donnée ou un environnement mal maîtrisé aurait faussé un résultat de test. Qu'est-ce qui l'a évité, ou l'aurait évité ?

---

## Rendu

Une archive déposée avant **17h00** dans l'espace de la promotion :

- en groupe : `M07_Groupe_<NOM1>_<NOM2>_....zip`
- en individuel : `M07_<NOM>_<Prenom>.zip`

```
M07_.../
├── Dossier_Synthese_M07.md        (ou .pdf)
├── annexes/
│   ├── Catalogue_JDD_ShopLab.xlsx
│   ├── sql/                       exploration, contrôle, préparation, nettoyage, anonymisation
│   ├── synthetique/               commande de génération, graine, preuve de reproductibilité
│   ├── environnement/             fiche d'identité, diagnostic, smoke test, checklist
│   └── anomalies/                 tableau des anomalies, fiches d'anomalie
└── journal_prompts.md             (si usage de l'IA)
```

Le fichier SQL synthétique généré n'est pas à rendre : il doit pouvoir être **régénéré** à partir de votre procédure.

**Données** : aucune donnée réelle dans le dossier. Les données de test respectent les conventions du cours (`qa.xxx@example.com`, `QA-...`).

---

## Critères d'évaluation

| Critère | Portée | Poids |
|---------|--------|-------|
| C1. Cohérence globale et traçabilité | dossier | 20 % |
| C2. Compréhension de la démarche et justification métier | dossier | 20 % |
| C3. Qualité des productions techniques | dossier | 15 % |
| C4. Reproductibilité démontrée (procédure exécutée) | dossier | 15 % |
| C5. Conformité et sécurité des données | dossier | 10 % |
| C6. Partie individuelle | chaque membre | 20 % |

Détail : `evaluation2/Grille_Dossier_Synthese_M07.md`.

**Apprenants sans Docker** : la procédure et les commandes sont celles de `Secours_SQLite/`, avec la mention **(SQLite)** dans le titre du dossier.
