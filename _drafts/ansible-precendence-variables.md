---
title: Ansible - Précédence des variables
tags: [ Ansible, ci-cd ]
layout: post
category: devops
complexity: 1
has_code: true
disableComments: true
---
Ansible est un outil open-source d'automatisation de la gestion de configuration, du déploiement d'applications, voir de l'orchestration de tâches IT que j'utilise régulièrement pour le déploiement automatisé de configuration de serveurs ou de mise à jour d'application. 

Ansible a plusieurs avantages à mon goût :
- ne nécessite par d'installer un logiciel sur les nœuds/serveurs gérés.
- syntaxe basée sur YAML que l'on retrouve dans de nombreux autres outils (bon, ce n'est pas forcément le meilleur choix).
- description principalement de l'état final attendu plutôt que des étapes pour l'atteindre
- documentation détaillée
- composants facilement réutilisables (Rôles, Ansible Galaxy, etc.)

## Importance des variables dans Ansible

De part sa flexibilité, les variables dans Ansible jouent un rôle essentiel, elles permettent de rendre les `playbooks` et les `rôles` plus dynamique et réutilisable :

- permettent de définir des valeurs par défaut pour les `rôles`, les `playbooks`, les `hosts` (serveurs), les `inventories` (environnement).
- le mécanisme de surcharge et de précédence permet sa grande flexibilité
- factorisation et réutilisation des valeurs : réutilisation d'une valeur définie une seule fois
- simplification de la maintenance, un bon découpage permet de retrouver les variables à mettre à jour rapidement en fonction des cas d'usages (upgrade de version vs. nouveau serveur)
- sécurité avec `ansible vault` qui permet de crypter les variables sensibles
- construction de variable à partir d'autres variables.

Exemple :

```yaml
---
- hosts: webservers
  vars:
    server_name: "example.com"
    deploy_path: "/var/www/html"
  tasks:
    - name: Deploy application
      copy:
        src: /local/path/to/app
        dest: "{{ deploy_path }}"
    - name: Configure server
      template:
        src: /local/path/to/{{ server_name }}.j2
        dest: /etc/nginx/sites-available/{{ server_name }}
```

Ici, les variables `server_name` et `deploy_path` rendent le playbook plus facile à maintenir.

La documentation d'Ansible propose une douzaine d'emplacements où des variables peuvent être définies, si on ne comprend pas le principe sous-jacent et le fonctionnement de surcharge/précédence, on se retrouve vite perdu, avec des variables en conflits ou non définie quand on en a besoin.

C'est donc l'objectif de cet article, de vous aidez à y voir plus clair.

## Qu'est-ce que la Précédence des Variables ?

La documentation d'`Ansible` présente [22 niveaux de définition des variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#understanding-variable-precedence), mais quand on y regarde de plus prêt il y a un peu de redondance et certains niveaux sont très rarement utilisés.

Le principe général est de partir du niveau le plus générique (facilement surchargé), vers le niveau spécifique (qui surcharge tout ce qui a été définie précédemment).

### Principaux groupes de variables

- Role
- 

### Définition et concept
### Pourquoi la précédence est-elle cruciale ?

## Les Niveaux de Précédence des Variables dans Ansible

### Variables de la ligne de commande
### Variables des tâches
### Variables des blocs
### Variables des rôles
### Variables des groupes d'inventaire
### Variables des hôtes
### Variables par défaut
### Variables fact
### Variables d'environnement
### Variables de fichiers YAML et JSON
### Variables de Playbooks
## Exemples Pratiques de Précédence des Variables

### Exemple simple avec un Playbook
### Utilisation des rôles et précédence des variables
### Exemple avancé avec des groupes et des hôtes

## Résolution des Conflits de Variables

### Techniques pour éviter les conflits
### Stratégies de résolution lors des conflits de variables
### Utilisation de la fonction set_fact

## Bonnes Pratiques pour la Gestion des Variables

### Organisation des variables
### Documentation des variables
### Utilisation des namespaces
## Outils et Ressources Complémentaires

### Modules Ansible utiles pour la gestion des variables
### Documentation officielle d'Ansible
### Communautés et forums de discussion
## Conclusion

### Récapitulatif des points clés
### Importance de la maîtrise de la précédence des variables
### Encouragement à l'expérimentation et à l'apprentissage continu
