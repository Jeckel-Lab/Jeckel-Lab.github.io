---
layout: post
title: Configurer NGinx en "reverse-proxy" devant NodeJS
tags: [nginx, nodejs]
has_code: true
category: devops
complexity: 2
---
Dans de nombreux projets en NodeJS, on utilise un server web (comme express par exemple) qui permet de servir les pages html/javascript/css etc… aussi bien qu’un Apache ou un NGinx.  
Aussi bien ? pas tout à fait, en réalité NodeJS sera très bien pour tout ce qui est dynamique, mais ne sera jamais aussi performant pour distribuer des fichiers statiques. D’autre part, de nombreuses fonctionnalités disponible nativement sur un serveur web dédié ne seront pas a re-développer sur une application NodeJS.  
  
## Mais c’est quoi un reverse proxy ?
Le principe du reverse proxy est assez simple. On va installer un serveur web classique de type NGinx qui va répondre à toutes les requêtes sur le port 80. Puis on va lui dire que toutes les requêtes qui correspondent à un format particulier (un nom de domaine par exemple) vont être redirigées vers une autre application (notre application NodeJS).  

## Pourquoi utiliser un reverse proxy devant votre application NodeJS ?
1.  Pour laisser au serveur web le soin de s’occuper des fichiers statiques et se concentrer sur le dynamique
2.  Pour utiliser les fonctionnalités « build-in » du serveur web (load-balancing, cache, rate-limiting, error page, access control, etc.)
3.  Meilleure protection contre les attaques (type DoS)
4.  Avoir plusieurs applications NodeJS qui répondent « virtuellement » sur le même port (mais sur des routes différentes)

## Et comment on fait ?
Dans notre exemple, nous allons donc utiliser NGinx, et supposer que nous voulons mettre application en NodeJS sur un autre sous-domaine.  
- Etape 1 : installer nginx… pour cette étape, je vous invite à lire [les innombrables tutoriels déjà présent sur le web](https://duckduckgo.com/?q=installation+de+nginx).  
- Etape 2 : ajouter un fichier de configuration à NGinx dans `/etc/nginx/sites-available/api-exemple`

```
server {
	listen 80;
	server_name api.exemple.coom;

	location / {
		proxy_pass http://127.0.0.1:3000;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host $host;
		proxy_cache_bypass $http_upgrade;
	}
}
```

Ce fichier indique à NGinx que toutes les requêtes entrante sur le port 80 et sur le nom de domaine « api.exemple.com » seront redirigées vers l’adresse 127.0.0.1 et sur le port 3000 (là où se trouve notre application NodeJS).  
- Etape 3 : activer la configuration
Il ne reste plus qu’à activer cette configuration :

```bash
cd /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/api-exemple
sudo /etc/init.d/nginx reload
```

Et voilà, vous pouvez maintenant accéder à votre application directement depuis http://api.exemple.com  
## Pour aller plus loin..
Vous avez maintenant un fichier de configuration NGinx en front de votre application Node, c’est dans ce fichier de configuration que vous allez pouvoir rajouter des options supplémentaires comme :

-   du rate-limiting (limite du nombre de requêtes par intervalles de temps)
-   des routes custom pour que NGinx charge directement les fichiers *.js *.html… ou par dossiers
-   etc.
