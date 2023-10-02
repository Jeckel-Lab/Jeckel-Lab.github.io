---
layout: post
title: Pourquoi ne jamais versionner les tokens dans un repository
description: "Découvrez les risques de sécurité liés à la version des tokens, mots de passe et clés d'accès dans Git. Apprenez pourquoi cette pratique est à éviter et comment adopter de bonnes pratiques pour protéger vos informations sensibles."
keywords: "Git, Tokens, Mots de passe, Clés d'accès, Sécurité, Violation de la sécurité, Exposition d'informations sensibles, Piratage, Compromission de la sécurité, Révocation, Conflit d'environnement, Bonnes pratiques, Variables d'environnement, Gestionnaire de secrets, HashiCorp Vault, AWS Secrets Manager, Configuration d'environnement, Développement, Recette, Production, Référencement, Sécurité des données, Gestion de versions, Développeurs, Repository"
tags: [git, securité, page-expert-php, page-architecture]
category: devops
complexity: 1
---
Aujourd'hui, Git est devenu un incontournable dans tout projet de développement, indispensable à la gestion de version du code source et au travail en équipe.
Cependant, il y a de bonnes pratiques à avoir, des notions de sécurité, des erreurs à ne pas commettre.

L'une de ces erreurs que l'on retrouve hélas régulièrement est celui d'enregistrer dans Git des tokens d'api, bearer ou autre élément d'authentification. 

Parfois volontaire, souvent par erreur, voyons pourquoi c'est une pratique à bannir de tout projet.

## 1. Violation de la sécurité

Le stockage de ces tokens est avant tout un problème de sécurité.
### Exposition des informations sensibles

Lorsque l'on stocke des tokens / mots de passe / clés d'accès dans un repository Git, nous les exposons au public. Même si le repository est sécurisé et ouvert à un public restreint, l'ensemble de ce public va pouvoir accéder à ces informations.

Git est un système de gestion de version distribué, c'est-à-dire que chaque clone du repository contient non seulement la version en cours, mais aussi l'historique complet, y compris donc les commits précédents.

Pas conséquent, si des informations sensibles sont versionnées, même si elles sont supprimées par un commit correctif suivant reste à disposition de n'importe qui ayant accès au repository ou à l'un des clones. 

### Ouverture au piratage

La présence de tokens et mots de passe dans un repository Git peut donc entraîner une violation de la sécurité. Comme vu précédemment, sans suppression explicite de l'ensemble des commits impactés, ces tokens restent présents dans l'historique et donc accessible pour quiconque ayant au moins clone du repository.

Il est très facile d'écrire un bot qui scanne un repository pour y trouver une signature de token ou de mot de passe.

Ce genre de faille de sécurité peut créer une ouverture permettant d'accéder ensuite à d'autres fonctionnalités de l'entreprise et avoir ainsi des conséquences graves.

La sécurité est une préoccupation constante pour les entreprises et doit l'être aussi pour les développeurs. Ce genre de compromission peut nuire gravement à la réputation de l'entreprise et à la confiance accordée par ces clients et utilisateurs.

### Difficulté de révocation

En cas de compromission des informations de sécurité, il devient urgent de pouvoir révoquer ces informations. Mais lorsque ces informations sont versionnés sur un repository Git, il devient difficile d'identifier tous les environnements, poste de développeur, machines de déploiement où ces informations sont conservées. 
Il est alors difficile de les révoquer efficacement. 

## 2. Conflit d'environnement

D'une manière plus pragmatique, les tokens et mot de passe sont en général liés à l'intégration du projet à un outil extérieur à l'application. 

Conserver ces informations dans le repository crée donc un lien fort entre ces applications et ne permet donc plus la possibilité d'avoir une configuration différente en fonction de l'environnement (Développement vs. Recette vs. Production).

## 3. Bonnes pratiques

Pour éviter ces risques, il faut donc éviter à tout prix de stocker ces informations dans un repository.

D'autres solutions plus sécurisées existent :
- utiliser des variables d'environnements ou un fichier de configuration non versionné
- utiliser un gestionnaire de secrets comme HashiCorp Vault, AWS Secrets Manager
- il est aussi possible de versionner un vault dans lequel ces données sont hashées et ne sont disponibles qu'avec un mot de passe ou une passphrase (évidement, non versionné), possible avec Symfony Vault ou Ansible Vault.

Les secrets seront mis à disposition de l'application lors de son déploiement sur l'environnement cible.

En conclusion, versionner des informations sensibles dans un repository git est une mauvaise habitude souvent réalisée pour les mauvaises raisons et qui apporte beaucoup plus de problème qu'elle ne résout de solutions.
