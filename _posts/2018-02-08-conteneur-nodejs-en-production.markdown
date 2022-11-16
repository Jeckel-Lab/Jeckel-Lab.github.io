---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: jeckel-lab
title: 8 Conseils pour faire votre conteneur docker NodeJs de production
tags: [nodejs, docker]
---
Entre le développement et la production, on oublie trop souvent qu’il y a un gap à franchir. L’application sur laquelle on développe, même si l’on développe directement dans un conteneur docker ne peut être livrée telle quelle en production. Voici donc quelques conseils pour réussir un conteneur « production ready » en NodeJS.  

## 1. Pas de variable unique pour l’environnement

C’est une mauvaise pratique hélas assez courante en développement, avoir une variable d’environnement ou de configuration « `Environnement` » et tester ensuite dans le code si `Environnement = "PROD"` alors…  
Il faut au contraire multiplier les options de configuration pour ajuster chacun des cas en fonction de l’environnement. Cela vous permet d’une part d’avoir un code plus proche de la production et d’autre part de pouvoir activer / désactiver les fonctionnalités. Vous pouvez aussi multiplier les environnements à l’infini (pas de liste fini d’environnement, mais une liste infinie de combinaison de configuration possible).

### 2. Injecter des variables d’environnement pour rendre la configuration plus dynamique

Ok, maintenant que vous avez pleins d’options de configurations, il s’agit maintenant de pouvoir ajuster ces options sans avoir à reconstruire votre image à chaque fois. Docker permet d’injecter des variables d’environnement au moment d’instancier un nouveau conteneur depuis une image. Cela vous permet donc d’ajuster la configuration par rapport à chacun de vos besoins.  
Pour ma part, j’utilise dans chacun de mes projets un fichier `settings.js` qui ressemble à ça :

```javascript
/**
 * Settings
 */

module.exports = {
	express: {
		port: process.env.EXPRESS_PORT || 3000,
	},
	postgres: {
		user: process.env.POSTGRES_USER || 'admin',
		host: process.env.POSTGRES_HOST || 'storage',
		database: process.env.POSTGRES_DATABASE || 'database',
		password: process.env.POSTGRES_PASSWORD || 'admin',
		port: process.env.POSTGRES_PORT || 5432,
	},
};
```

Pour chaque option de configuration, il y a une variable d’environnement correspondante avec une valeur par défaut si cette variable n’a pas été définie.

## 3. Baser l’image sur Alpine

Lorsque l’on construit un image Docker il est préférable de ne pas s’encombrer de choses inutiles qui pourraient alourdir ou ralentir le conteneur, voir y insérer des failles de sécurité.  
Dans cette optique, je vous conseille, **dans la mesure du possible**, de baser votre image sur Alpine (_une version de linux extrêmement légère et réduite au minimum_) plutôt que sur Debian, cela permet d’éviter d’embarquer des applications/librairies inutiles et d’obtenir une image beaucoup inutilement alourdie.

## 4. Babel, Webpack, Grunt… importer le code final et non le code source

Si vous utilisez une librairie pour compiler/transpiler/packager votre code, il faut alors prévoir une étape de **build** du code lors de la création de l’image et ensuite supprimer le code source pour ne garder que le code de sortie du build.  
De même, si vous utilisez des watchers qui recompile votre code à chaque modification (de type `nodemon`)**,** ceux-ci doivent être exclu de votre image. En effet ce type d’outils n’a d’utilité qu’en développement.

### 5. Utiliser le fichier .dockerignore

Lors de la création de l’image, le fichier `.dockerignore` permet d’exclure automatiquement des fichiers des images Docker, c’est à dire que lors de l’utilisation d’instruction `ADD` ou `COPY` dans le `Dockerfile`, les fichiers spécifiés dans le fichier `.dockerignore` seront exclus de la copie.  
On peut déjà y mettre systématiquement le dossier `node_modules` ainsi que tous les fichiers de tests, linter, etc..

### 6. Supprimer les tests et les sources

Si vous utiliser une librairie pour packager votre application, supprimer les fichiers source une fois le code compilé, ça allègera votre image en évitant encore d’embarquer du code inutile.  
Idem pour les fichiers de tests, surtout quand dans de nombreux cas (celons comment sont fait vos tests), on ne souhaite pas du tout que ceux-ci s’exécutent en production.

### 7. Supprimer les packages systèmes obsolètes

Certaines librairies nodejs nécessitent d’installer des packages systèmes supplémentaires, dans certains cas, ces packages ne servent qu’à l’installation (compilation) de la librairie, ou au build de votre application. Vérifiez si vous en avez encore besoin ou pas une fois votre application fonctionnelle. S’ils ne sont plus requis, on supprime.

### 8. Pas d’image pour le front (React / Angular / Etc.)

Enfin, ça peut sembler une évidence, mais même si en développement, il est souvent pratique d’avoir un nodejs qui tourne en continue avec un watcher qui va mettre à jour le script en front à chaque update du code… En production, vous ne devriez avoir que des fichiers statiques. Et dans ce cas, vous n’avez pas besoin de Node du tout pour les servir au navigateur.  
Préférer une application plus adaptée pour servir des fichiers statiques comme NGinx ou Apache, ce sera plus performant, et bien plus adapté.

### Conclusion et bonus

Pour conclure, il nous faut donc :

-   Un `.dockerignore` pour exclure les fichiers inutile
-   Une étape build pour compiler notre image
-   Une étape de construction de l’image de Run (celle qui va réellement partir en production)

On peut le faire avec deux `Dockerfile` (un pour le build, et un pour le run qui se basera sur le résultat du premier), ou alors utiliser le double « `FROM` » disponible depuis quelques temps dans le `Dockerfile`.  
En **bonus** donc, Je vous partage un sample `Dockerfile` (et son fichier `.dockerignore`) que j’utilise comme base pour mes projets en NodeJS.  
[Vous pourrez retrouver la dernière version sur github.](https://github.com/jeckel/dockerfiles/tree/master/nodejs)

-   Le fichier `Dockerfile` à adapter :

```dockerfile
###############################################################################
# Step 1 : Builder image
#

FROM node:9-alpine AS builder
LABEL maintainer="Julien MERCIER <devci@j3ck3l.me>"

# Define working directory and copy source

WORKDIR /home/node/app
COPY . .

# Install dependencies and build whatever you have to build
# (babel, grunt, webpack, etc.)

RUN npm install && \
	npm run build

###############################################################################
# Step 2 : Run image
#

FROM node:9-alpine
ENV NODE_ENV=production
WORKDIR /home/node/app

# Install deps for production only

COPY ./package* ./
RUN npm install && \
	npm cache clean --force

# Copy builded source from the upper builder stage

COPY --from=builder /home/node/app/dist ./dist

# Expose whatever port you need to expose
# And start
CMD npm start
```

-   Le fichier `.dockeringore` :

```c
# Ignore all .* files except the ones required for build

.*
!.babelrc

# Ignore build directories and dependencies
# everything that will be re-generated by the install/build steps

lib
dist
node_modules

# Ignore dev configuration files

docker-compose.yml
Dockerfile
Makefile
nodemon.json

# Ignore documentation

*.md

# Ignore tests files

src/**/*.test.js
test
jest.config.json
```
