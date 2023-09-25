---
layout: post
title: Variables d'environnements et Nginx avec Docker
tags: [docker, nginx, env, page-expert-php]
has_code: true
category: devops
complexity: 3
---
Il existe une image docker Nginx officielle pour docker que l’on peut trouver sur [le docker hub](https://hub.docker.com/_/nginx/). C’est cool. Mais l’un des besoins courant avec docker est de pouvoir adapter légèrement la configuration de l’image par rapport à son environnement d’exécution (comment dialoguer avec les conteneurs voisins par exemple) en injectant des variables d’environnement.  
Mais voilà, pour des raisons de performances (et aussi un peu de sécurité), les variables d’environnement ne sont pas accessible dans les fichiers de configurations nginx.

Voici donc quelques petits tips pour s’en sortir.

## Utiliser le script `envsubst` fourni avec l’image officielle.

Dans la documentation de l’image officielle, on trouve quelques petites lignes sur l’utilisation d’un script qui va venir faire un remplacement de variables dans un fichier "template" afin de générer le fichier final qui sera lui, chargé au démarrage du serveur.  
Grosso modo, ça ressemble à ça, dans le fichier de configuration vous entrez le nom de votre variable.

```config
listen ${NGINX_PORT};
```

Puis, lors du lancement du conteneur, il faut ajouter votre variable d’environnement, et modifier la commande par défaut du conteneur pour faire la substitution en amont du lancement d’Nginx  
En ligne de commande, ça donne ça :

```bash
docker run \
	-v `pwd`/mysite.template:/etc/nginx/conf.d/mysite.template:ro \
	-e NGINX_PORT=80 \
	nginx \
	shell -c "envsubst < /etc/nginx/conf.d/mysite.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
```

Ok, c’est pas l’idéal, mais ça fonctionne (pour la version avec docker-compose, il suffit d’aller voir sur la page sur docker hub).  
Seulement voilà, ce joli script est mal foutu, en effet, au lieu de boucler sur les variables d’environnements et de ne remplacer que celles-ci, cet idiot remplace tout ce qui commence par un $ dans votre fichier de configuration… C’est d’autant plus idiot que NGinx propose [une jolie collection de variables](https://nginx.org/en/docs/varindex.html) (accessibles, elles, dans le fichier de configuration) et qui commencent toutes par un $.  
Par conséquent, si dans votre fichier, vous avez une ligne de ce type :

```config
set $my_hostname=${ENV_HOSTNAME}
```

Après le passage du script de substitution, votre fichier de configuration risque bien de ressembler à ça:

```
set =my.host.com
```

Ne cherchez pas, j’ai testé pour vous, nginx n’aime pas du tout 🙁

## Contourner le problème avec `docker-compose`

Docker-compose permet déjà de modifier pas mal de chose qui peut nous permettre de nous passer tout simplement de variables d’environnements dans le conteneur au profit du fichier de configuration `docker-compose.yml`.

### Rendre dynamique le nom de domaine d’une cible

Il est possible d’injecter de nouvelles lignes dans le fichier `/etc/hosts` d’un conteneur avec simplement des options de configurations de docker-compose. On peut alors, dans notre fichier de configuration, utiliser un nom de « host » fixe, qui pointera sur une IP définie dans le fichier `/etc/hosts` configuré via docker-compose :

```yaml
version: '3'
services:
	nginx:
		image: nginx:1.13
		volumes:
			- ./nginx/default.dev.conf:/etc/nginx/conf.d/default.conf:ro
		extra_hosts:
			- "target-host:my.host.com"
```

Et comme il est possible d’[injecter des variables d’environnement](https://docs.docker.com/compose/environment-variables/) dans la configuration de docker-compose :

```yaml
version: '3'
services:
	nginx:
		image: nginx:1.13
		volumes:
			- ./nginx/default.dev.conf:/etc/nginx/conf.d/default.conf:ro
		extra_hosts:
			- "target-host:${ENV_HOSTNAME}"
```

### Surcharger le fichier de configuration de Nginx

L’autre solution est de surcharger complètement le fichier de configuration, soit le fichier complet, soit un fichier annexe qui sera inclus dans le fichier principal.  
Le chemin (local) de ce fichier pouvant être rendu dynamique grâce à la prise en charge des variables d’environnement de docker-compose.

```yaml
version: '3'
services:
	nginx:
		image: nginx:1.13
		volumes:
			- ./nginx/default.dev.conf:/etc/nginx/conf.d/default.conf:ro
			- ./nginx/${EXTRA_FILE}:/etc/nginx/conf.d/extra.conf:ro
```

## Hacker le script de substitution

En recherchant ce problème, certains ont trouvé le moyen de hacker le script de substitution, je vous laisse le lien vers le post en question, et vous laisse juger vous-même :  
[How can I use environment variables in Nginx.conf](https://serverfault.com/questions/577370/how-can-i-use-environment-variables-in-nginx-conf)

## Créer votre propre image

La dernière solution reste toujours de surcharger l’image officielle et de créer votre propre image, avec les scripts et configurations répondant à vos besoins spécifiques.  
   
Il existe sans doute de nombreuses autres solutions, et c’est une combinaison de celles-ci qui répondra sans doute à vos besoins. N’hésitez pas à partager les votre en commentaires.
