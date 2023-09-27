---
layout: post
title: Lire la saisie utilisateur sur un terminal en PHP
tags: [php, console, terminal, cli, page-expert-php]
has_code: true
category: php
complexity: 2
redirect_from:
  - /2018/01/04/demotools-une-librairie-php-pour-linteraction-utilisateur-en-terminal/
  - /2018/01/03/lire-la-saisie-utilisateur-sur-un-terminal-en-php/
  - /2018/01/demotools-une-librairie-php-pour-linteraction-utilisateur-en-terminal/
  - /2018/01/lire-la-saisie-utilisateur-sur-un-terminal-en-php/
---
Dans de nombreux languages, demander à l’utilisateur, pendant l’execution du programme de saisir des informations est chose aisée. Le PHP étant un langage de script initialement développer exclusivement pour un usage Web, il n’est pas prévu de commande permettant de mettre en pause le programme le temps que l’utilisateur fournisse l’information qui nous manques.  
Heureusement, si cette fonction n’existe pas, PHP fournis tous les outils pour le faire.

La première chose à savoir c’est que PHP fourni des "ressources" correspondant aux entrées et sorties du système linux :

-   `php://stdin` correspondant à l’entré[2017-12-20-grafana-docker-compose.markdown](2017-12-20-grafana-docker-compose.markdown)e standard
-   `php://stdout` correspondant à la sortie standard
-   `php://stderr` correspondant à la sortie d’erreur

Ces ressources peuvent être utilisées via de nombreuses commandes PHP comme s’il s’agissait de fichiers.  
Ainsi, on peut écrire sur la sortie d’erreur avec le code suivant :

```php
$stderr = fopen("php://stderr", "w");
fwrite("An error occured\n", $stderr);
fclose($stderr);
```

Par conséquent, on peut donc lire sur l’entrée standard de la même manière.  
Pour rappel, l’entrée standard se comporte ici comme un fichier, il nous faut donc quand même rajouter un moyen pour que le programme ne lise pas l’entrée indéfiniment pour pouvoir reprendre sa course.  
La fonction [`fgets`](http://php.net/fgets) permet de lire « une ligne » dans un fichier, c'est-à-dire qu’il va retourner tous les caractères jusqu’au premier saut de ligne. Ce qui est idéal pour nous puisque l’utilisateur va pouvoir ainsi valider sa saisie avec la toucher [ENTER] de son clavier.

```php
function readUserEntry(): string {
	$stdin = fopen("php://stdin","r");
	$input = fgets($stdin);
	fclose ($stdin);
	return $input;
}
```

Voilà qui est pas mal pour une première version.  
Pour nous faciliter le travail, PHP a ajouté [des constantes](http://php.net/manual/en/features.commandline.io-streams.php) permettant d’accéder directement aux flux d’entrée sortie, plus besoin de les ouvrir et de les fermer, ce sont des ressources toujours accessible.  
Ainsi, le même code se résume maintenant à une ligne :

```php
function readUserEntry(): string {
	return fgets(STDIN);
}
```

On va maintenant rendre notre fonction un peu plus sexy et plus propre en ajoutant une invite et en nettoyant la réponse reçue :

```php
function readUserEntry(?string $invite = null): string {
	if (! empty($invite)) {
		printf($invite);
	}
	return trim(fgets(STDIN));
}
```
