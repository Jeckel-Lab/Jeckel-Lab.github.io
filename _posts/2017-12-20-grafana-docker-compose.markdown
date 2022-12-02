---
layout: post
title: Pré-configurer Grafana avec Docker-Compose
tags: [docker-compose, docker, grafana]
has_code: true
category: devops
complexity: 3
---
[Grafana](https://grafana.com/) est un excellent outil permettant de créer facilement des dashboards de monitoring en se branchant sur différentes sources de données. Ce projet est [open-source](https://github.com/grafana/grafana) et disponible sous la forme d’un [conteneur docker](https://hub.docker.com/r/grafana/grafana/), ce qui lui permet d’être intégré directement dans d’autres projets de plus grande envergure. C’est par exemple ce que j’ai fait avec [Omeglast](https://www.jeckel-lab.fr/omeglast/).  
Pour facilité son inclusion dans un projet, il est nécessaire d’avoir une solution pour initialiser Grafana directement avec une configuration propre à notre projet (accès aux sources de données, dashboards initialisés, etc.)  
Heureusement, Grafana avec quelques outils supplémentaires dispose de tous les éléments nécessaires.  

## Principe général

Grafana utilise par défaut un base de donnée SQLite pour stocker l’ensemble de sa configuration, mais il est possible, via quelques paramètre d’initialisation, de remplacer cette base par une autre base de notre choix, extérieur, et dont on aura un total contrôle.  
Ensuite, il ne nous restera qu’à configurer une fois Grafana, de sauvegarder cette configuration dans un fichier, et de pouvoir ensuite initialiser automatique notre base avec ce fichier sauvegardé.  
Pour info, l’ensemble du code source de ce tutoriel est disponible [sur github](https://github.com/jeckel/tutorials/tree/master/docker/2-pre-configure-grafana).

## Etape 1 : Installer Grafana avec docker-compose

Pour commencer, vous devez avoir [docker](https://docs.docker.com/engine/installation/) et [docker-compose](https://docs.docker.com/compose/install/) d’installés, si ce n’est le cas, aller voir les tutoriels associés, c’est très simple.  
On va donc commencer par initialiser Grafana seul, en utilisant docker-compose. Il suffit de copier le code suivant dans un fichier `docker-compose.yml`.

```yaml
version: '2'
services:
	grafana:
		image: grafana/grafana
	ports:
		- "3000:3000"
```

On lance l’application via `docker-compose up`, et après quelques secondes d’initialisation, l’application est disponible via l’url `http://localhost:3000`  
A ce stade, Grafana fonctionne, mais vous avez tout à configurer, la première chose à faire sera donc d’exporter la configuration à l’extérieur du conteneur pour la rendre persistante. Il existe plusieurs options, la première consiste à simplement créer un nouveau volume dans lequel sera enregistré cette configuration (c’est ce que vous trouverez dans la documentation de [grafana sur docker hub](https://hub.docker.com/r/grafana/grafana/)), mais il existe une autre option, bien plus sexy.

## Etape 2 : Ajouter une base de stockage de la configuration

En effet, en lisant la documentation de Grafana d’une part et de son image docker d’autre part, on découvre deux choses:

1.  il est possible de configurer Grafana pour qu’il stocke sa configuration dans une base de données externe (comme PostgreSQL par exemple)
2.  il est possible de redéfinir toutes les variables du fichier de configuration via des variables d’environnement injectée via docker.

Alors allons-y, modifions notre fichier `docker-compose.yml` en conséquence:

```yaml
version: '2'

volumes:
	grafana-pgdata:

services:
	# Grafana dedicated storage
	#
	grafana-storage:
		image: postgres:10-alpine
		volumes:
			- grafana-pgdata:/var/lib/postgresql/data
		environment:
			- POSTGRES_PASSWORD=password
			- POSTGRES_USER=admin
			- POSTGRES_DB=grafana

	# Grafana Server
	#
	grafana:
		image: grafana/grafana
		ports:
			- "3000:3000"
		environment:
			- GF_DATABASE_TYPE=postgres
			- GF_DATABASE_HOST=grafana-storage
			- GF_DATABASE_NAME=grafana
			- GF_DATABASE_USER=admin
			- GF_DATABASE_PASSWORD=password
```


Nous avons donc :

-   créé un volume pour y stocker la base de donnée de PosgreSQL « `grafana-pgdata`« 
-   créé un conteneur PostgreSQL initialisé avec une base « `grafana`« 
-   modifié la configuration de Grafana pour utiliser notre base PostgreSQL pour sa configuration

Y a plus qu’à lancer notre commande `docker-compose up`.  
CRACK.

```bash
Fail to initialize orm engine" logger=sqlstore error="Sqlstore::Migration failed err: dial tcp 172.23.0.2:5432: getsockopt: connection refused
```

Ok, ça plante, mais la raison est très simple, le premier lancement de PostgreSQL est assez long car il doit construire et initialiser la base de donnée, parallèlement, Grafana est beaucoup plus rapide, et donc n’arrivant pas à se connecter à PostgreSQL qui n’est pas encore disponible, s’arrête avec une erreur.  
Si vous lancer PostgreSQL seul en premier, et Grafana ensuite avec quelques secondes d’interval, tout fonctionne.

## Etape 3 : Ajouter un Healthcheck et séquencer le démarrage

Le Healthcheck est un petit bout de script qui permet de vérifier qu’un service est opérationnel. Et c’est ce que nous allons utiliser.  
Nous allons donc ajouter un petit script qui va nous permettre d’attendre que PostgreSQL soit disponible avant de lancer Grafana.  
Sur PostgreSQL, il y a une commande `pg_isready` qui nous permet de savoir si le serveur est prêt à traiter des requêtes ou non, et pour le lancer via docker, ça donne :

```bash
docker-compose exec grafana-storage pg_isready
```

Ajoutons ça dans un script `start.sh` qui va nous séquencer le démarrage :

```bash
#!/bin/bash

docker-compose up -d grafana-storage
until docker-compose exec grafana-storage pg_isready > /dev/null
do
	printf '.'
done
printf '\n'
docker-compose up
```

Cette fois-ci, même après avoir supprimer toutes les images, conteneurs et volumes, en lançant la commande `./start.sh` tout fonctionne correctement.

## Etape 4 : Exporter la sauvegarde

Nous avons donc maintenant Grafana qui fonctionne correctement et PostgreSQL qui contient toute la configuration de Grafana.  
Ce dont nous avons maintenant besoin c’est de pouvoir extraire la configuration de cette base de donnée pour pouvoir la sauvegarder avec notre application et pour la réimporter plus tard, automatiquement à l’installation de notre futur projet.  
Nous allons d’abord modifier notre fichier `docker-compose.yml` pour y ajouter un nouveau montage de dossier destiné à recevoir l’export de la base de données :

```yaml
version: '2.1'

volumes:
	grafana-pgdata:

services:
	# Grafana dedicated storage
	#
	grafana-storage:
		image: postgres:10-alpine
		volumes:
			- grafana-pgdata:/var/lib/postgresql/data
			- ./export:/var/export
		environment:
			- POSTGRES_PASSWORD=password
			- POSTGRES_USER=admin
			- POSTGRES_DB=grafana
		healthcheck:
			test: ["CMD", "pg_isready"]
			interval: 30s
			timeout: 1s
			retries: 5

	# Grafana Server
	#
	grafana:
		image: grafana/grafana
		ports:
			- "3000:3000"
		environment:
			- GF_DATABASE_TYPE=postgres
			- GF_DATABASE_HOST=grafana-storage
			- GF_DATABASE_NAME=grafana
			- GF_DATABASE_USER=admin
			- GF_DATABASE_PASSWORD=password
```

Nous allons rajouter un petit script `dump.sh` nous permettant de faire un dump de la base dans ce dossier :

```bash
#!/bin/bash

docker-compose exec grafana-storage sh -c "pg_dump -U admin grafana > /var/export/dbexport.sql"
```

Maintenant, vous pouvez donc lancer votre application avec `./start.sh`, puis via l’interface web créer votre configuration (source de donnée, dashboards, etc.), et une fois terminé, exporter cette configuration avec le script `./dump.sh`.  
Le fichier généré est alors disponible dans le dossier `export/`.

## Etape 5 : Charger la configuration au démarrage

Voilà, nous avons sauvegardé la configuration, la dernière étape est de pouvoir charger cette configuration à la prochaine initialisation du projet.  
Pour cette partie, c’est la documentation du conteneur PostgreSQL qui va nous donner la solution. En effet, il possible de spécifier un montage de dossier supplémentaire (`/docker-entrypoint-initdb.d`) contenant un (ou plusieurs) script qui seront chargé lors du premier lancement du conteneur (à l’initialisation donc).  
Du coup, encore une petite modification de notre fichier `docker-compose.yml` :

```yaml
version: '2.1'

volumes:
	grafana-pgdata:

services:
	# Grafana dedicated storage
	#
	grafana-storage:
		image: postgres:10-alpine
		volumes:
			- grafana-pgdata:/var/lib/postgresql/data
			- ./export:/var/export
			- ./initdb:/docker-entrypoint-initdb.d
		environment:
			- POSTGRES_PASSWORD=password
			- POSTGRES_USER=admin
			- POSTGRES_DB=grafana
		healthcheck:
			test: ["CMD", "pg_isready"]
			interval: 30s
			timeout: 1s
			retries: 5

	# Grafana Server
	#
	grafana:
		image: grafana/grafana
		ports:
			- "3000:3000"
		environment:
			- GF_DATABASE_TYPE=postgres
			- GF_DATABASE_HOST=grafana-storage
			- GF_DATABASE_NAME=grafana
			- GF_DATABASE_USER=admin
			- GF_DATABASE_PASSWORD=password
```

Nous pouvons maintenant mettre notre fichier précédemment sauvegardé dans le dossier local `initdb/`, et de lancer notre script `./start.sh`.  
Attention de bien supprimer tous les conteneurs et volumes précédemment créé, sinon docker-compose réutilisera ce qui existe déjà et n’utilisera pas la nouvelle configuration. Vous pouvez faire ce nettoyage avec la commande `docker-compose down -v`.  
Et voilà, vous pouvez maintenant inclure ces fichiers dans votre projet pour avoir une instance de Grafana déjà configuré par rapport à vos besoins.
