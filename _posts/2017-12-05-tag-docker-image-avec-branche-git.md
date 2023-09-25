---
layout: post
title: Tagger une image docker avec le nom de la branche git
tags: [docker, git, page-ci]
has_code: true
category: devops
complexity: 1
---
Un petit tips en passant, il est souvent bien utile de pouvoir utiliser le nom de la branche git en cours pour builder une image docker.  
Personnellement, je l’utilise dans deux cas :

-   Lorsque j’ai plusieurs développements en cours (et j’ai donc besoin d’une image correspondant à chaque branches)
-   Lorsque j’ai différentes branches correspondant à différentes versions de l’image (version différente de PHP ou de NodeJS par exemple)

Du coup, la première étape est de récupérer le nom de la branche en cours :

```bash
git rev-parse --abbrev-ref HEAD
```

Et il ne reste plus qu’à le stocker le résultat dans une variable.  
Autre petit truc, si la branche est `master`, dans ce cas je rajoute un tag `latest` à mon image.  
Et le tout dans un Makefile :

```Makefile
.PHONY build

IMAGE:=jeckel/image
TAG:=$(shell git rev-parse --abbrev-ref HEAD)

build:
	@docker build -t ${IMAGE}:${TAG} .
	@if [ ${TAG} = "master" ]; then \
		docker tag ${IMAGE}:${TAG} ${IMAGE}:latest; \
	fi
```

Il ne reste plus qu’à builder l’image :

```bash
make build
```

**Note :** si vous voulez utiliser plutôt le hash du dernier commit, il suffit d’utiliser la commande suivante :

```bash
git rev-parse HEAD
```
