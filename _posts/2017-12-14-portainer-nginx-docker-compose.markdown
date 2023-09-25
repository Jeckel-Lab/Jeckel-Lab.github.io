---
layout: post
title: Portainer, Nginx et docker-compose
tags: [portainer, docker, nginx, docker-compose, page-ci]
has_code: true
category: devops
complexity: 2
---
Lorsque l’on a besoin d’aller un peu plus loin (sur un serveur de test par exemple) on peut vouloir rajouter un minimum de sécurité : restreindre à certaines IP, restreindre à un domaine particulier, etc.  
C’est que je vais vous montrer ici en ajoutant un serveur NGinx en front avec docker-compose.  
  
Tout d’abord, nous allons devoir transcrire ce que nous avions fait dans le précédent article sous la forme d’un fichier de configuration `docker-compose.yml` :

```yaml
version: '2'

volumes:
	portainer_data:

services:
	portainer:
		image: portainer/portainer
		volumes:
			- /var/run/docker.sock:/var/run/docker.sock
			- portainer_data:/data
		command: -H unix:///var/run/docker.sock
		ports:
			- "9000:9000"
		restart: always
```

Et pour le lancer :

```bash
$> docker-compose up -d
Starting portainer_portainer_1 ...
Starting portainer_portainer_1 ... done
```

Comme avant, l’application reste accessible via http://localhost:9000  
Maintenant, nous allons rajouter un serveur NGinx en frontal, et nous allons donc le configurer en reverse proxy.  
Pour cette partie, nous allons devoir adapter l’image NGinx par défaut pour y include notre configuration spécifique.  
Premièrement, nous allons ajouter un fichier avec la configuration du reverse proxy NGinx `docker/portainer.conf` :

```conf
upstream portainer {
	server portainer:9000;
}

server {
	listen 80;
	location / {
		proxy_http_version 1.1;
		proxy_set_header Connection "";
		proxy_pass http://portainer/;
	}

	location /api/websocket/ {
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";
		proxy_http_version 1.1;
		proxy_pass http://portainer/api/websocket/;
	}
}
```

Dans notre fichier `docker-compose.yml` nous avions nommé le service portainer, c’est donc sous ce nom que, dans le réseau crée par docker-compose, notre container sera accessible ( `http://portainer:9000`)  
A ce fichier, nous allons rajouter un fichier `docker/Dockerfile` qui va nous permettre de charger l’image NGinx par défaut et d’y inclure notre configuration à la place de la configuration d’origine :

```Dockerfile
FROM nginx:alpine

# Remove existing configuration

RUN rm -v /etc/nginx/conf.d/*

# Insert our portainer conf

COPY portainer.conf /etc/nginx/conf.d/portainer.conf
```

Et maintenant, il nous reste à mettre à jour notre fichier `docker-compose.yml` pour y ajouter les instruction pour construire notre container NGinx et le lier à notre Portainer :

```yaml
version: '2'

# Configure a dedicated volume for storing Portainer's configuration
#

volumes:
	portainer_data:

services:
	# Configure Portainer service
	#
	portainer:
		image: portainer/portainer
		volumes:
			- /var/run/docker.sock:/var/run/docker.sock
			- portainer_data:/data
		command: -H unix:///var/run/docker.sock
		restart: always

		networks:
			- local

	# Configure NGinx proxy service
	#
	nginx:
		build: docker/
		ports:
			- "80:80"
		depends_on:
			- portainer
		restart: always
		networks:
			- local

# Link network to the docker bridge driver
#
networks:
	local:
		driver: bridge
```

Et voilà, maintenant, en lançant votre docker-compose, votre instance de portainer est accessible directement vi l’url `http://localhost/`.  
En réalité, le traffic passe maintenant à travers NGinx avant d’atteindre Portainer, on peut donc ajouter toute la configuration que l’on souhaite sur NGinx (paramétrer la route pour ne matcher que sur un sous-domaine particulier, ajouter un filtre par IP, etc…).
