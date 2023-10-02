---
layout: post
title: Petite histoire de l'immutabilité en PHP
tags: [php, page_expert_php]
category: php
has_code: true
description: "Découvrez l'évolution de l'immutabilité en PHP, de ses débuts jusqu'aux dernières versions. Apprenez pourquoi et comment utiliser l'immutabilité dans vos projets PHP."
keywords: "PHP, Immutabilité, Programmation, POO, PHP 8.1, PHP 8.2, PHP 7, PHP 5.5, DateTimeImmutable, readonly, Programmation Orientée Objet, Final, Classes, Méthodes, Types, PHPStan, Psalm, Développement Web, Sécurité, Performance, Typage, Constructeur, Propriétés, Héritage, Abstraction, Polymorphisme, Architecture, Conception, Bonnes Pratiques, Intégration Continue, Déploiement"
complexity: 2
---
L'immutabilité est un concept qui a gagné en popularité via la croissance de la programmation fonctionnelle, cependant PHP étant un langage initialement principalement utilisé pour le développement d'application Web, l'immutabilité n'a été intégré que tardivement et progressivement.

## Comprendre l'immutabilité

L'immutabilité en programmation signifie que quelque chose ne peut être modifié une fois qu'il a été créé, il ne peut pas **muter**.

Dans le code, cela se traduit par l'utilisation de variables ou d'objets qui ne peuvent pas être modifiés une fois qu'ils ont été initialisés ou instanciés. Si l'on doit faire une modification, on créera plutôt une autre objet à partir du premier avec les nouvelles propriétés.

### Pourquoi utiliser l'immutabilité&nbsp;?

1. **Sécurité**&nbsp;: Cela garantit que l’objet ne peut pas être modifié par une autre fonction ou un autre service par erreur
2. **Facilité de débugging**&nbsp;: Il n'est pas nécessaire de suivre les modifications de cet objet
3. **Prévisibilité**&nbsp;: Cela rend le comportement du programme plus prévisible
4. **Performance**&nbsp;: Si le langage le permet, savoir qu'un objet est immutable va permettre au compilateur/interpréteur d'en optimiser le fonctionnement.

### Quand utiliser des objets immutables&nbsp;?

On utilisera des objets immutable à chaque fois que l'on a besoin de garantir que les données ne sont pas modifiables, que la nature de cet objet et son utilisation en font un objet dont la modification a posteriori serait le signe d'un bug ou d'une erreur de conception.

Par exemple&nbsp;:
- **Événement**&nbsp;: Un objet décrivant un événement décris quelque chose qui est dans le passé, et comme on ne réécrit pas l'histoire, le passé est immutable, ce type d'objet devrait être immutable
- **Commande**&nbsp;: Il s'agit d'un objet décrivant une instruction. Une fois l'instruction émise, elle devient immuable
- **DTO**&nbsp;: ou Data Transfert Object, l'objectif d'un DTO est d'encapsuler des données complexes lors de leur transfert d'une fonction à une autre, d'un contexte à un autre. Ce n'est pas obligatoire, mais il peut être intéressant de faire de ces DTO des objets immutables afin de garantir qu'aucune modification ne peut avoir lieu dans les échanges suivants.


## PHP et immutabilité

Bien que l'immutabilité ne soit pas un élément clé de PHP, le langage a évolué pour donner, version après version les éléments nécessaires à une implémentation fiable.

### PHP 4 et antérieur

Dans les premières versions de PHP, l'immutabilité n'était pas vraiment un sujet de discussion. Le langage était principalement procédural et orienté vers la facilité d'utilisation plutôt que vers des concepts avancés comme l'immutabilité.

### Juillet 2004, PHP 5.0 et la POO

La version 5.0 sortie en juillet 2004 introduit la programmation orienté objet au langage, pas encore de notion d'immutabilité, mais cette version inclue déjà le mot clé `final` qui peut être utilisé pour une classe, rendant impossible la surcharge de celle-ci.

Il est alors déjà possible de créer un objet `final` avec toutes les propriétés privées.

Il est donc déjà possible pour les développeurs de concevoir des objets immutables, la seule garantie étant la qualité du code.
```php
/**
 * Immutable Event object in php 5.0
 */
final class Event
{
    private $name;
    private $date;
    
    public function __construct($name, $date)
    {
        $this->name = $name;
        $this->date = $date;
    }
    
    public function getName()
    {
        return $this->name;
    }
    
    public function getDate()
    {
        return $this->date;
    }
    
    public function changeName($newName)
    {
        // On ne modifie pas l'objet, on retourne un nouvel objet avec 
        // les nouvelles valeurs
        return new Event($newName, $this->date);
    }
}
```

### Juin 2013, PHP 5.5 et l'objet DateTimeImmutable

En juin 2013, PHP sort en version 5.5 et avec cette version apparait la première notion d'immutabilité sous la forme d'un objet interne du langage&nbsp;: `DateTimeImmutable`.

Cet objet dispose de la même signature que l'objet `DateTime` dont il partage l'interface `DateTimeInterface`.

![Diagramme de classe montrant les objets DateTime et DateTimeImmutable qui implémentent DateTimeInterface](/images/DateTimeInterface.png){: .center-image}

Avec cette nouvelle implémentation, l'objet `DateTimeImmutable` peut remplacer l'objet `DateTime` historique par son équivalent immutable.

Cette première implémentation résout de nombreux problèmes courants, tels que le calcul d'une date de fin en fonction d'une date de début par exemple.

Avec l'objet `DateTime` :

```php
$start = new DateTime("now");
echo $start->format('d/m/Y'); // ==> 01/10/2023

$end = $start->modify('+1 day);

echo $end->format('d/m/Y);    // ==> 02/10/2023
echo $start->format('d/m/Y);  // ==> 02/10/2023 !!
```
L'appel à la fonction `modify` a modifié l'objet date en même temps qu'il en a retourné l'instance, `$end` et `$start` sont deux références vers le même objet.

Avec l'objet `DateTimeImmutable` :
```php
$start = new DateTimeImmutable("now");
echo $start->format('d/m/Y'); // ==> 01/10/2023

$end = $start->modify('+1 day);

echo $end->format('d/m/Y);    // ==> 02/10/2023
echo $start->format('d/m/Y);  // ==> 01/10/2023
```
L'appel à la méthode `modify` a fait un clone de l'objet `$start` avant de le modifier. Ainsi, `$start` et `$end` sont bien deux variables différentes.


### Décembre 2015, php 7, l'objet devient sérieux

L'arrivée de php 7.0 en décembre 2015 et les versions suivantes ont apporté beaucoup d'amélioration au support de la programmation objet. 

On notera en particulier :
- la déclaration du typage scalaire des paramètres de méthode
- la déclaration du type de retour des méthodes
- les types nullables
- les classes anonymes
- et de nombreuses améliorations de performance

Le support de la programmation objet devient une préoccupation essentielle du langage, ces évolutions apportent de nouveaux outils à la création d'objet immutable, mais concrètement, toujours aucune réelle implémentation concrète.

### Novembre 2020, php 8.0 : rien de concrêt

PHP 8.0 arrive en novembre 2020, il apporte de grands changements dans le langage, dans son cœur principalement, mais dans le langage aussi.

Bien que cette version n'apporte rien de concret, elle définit les bases nécessaires.

### Novembre 2021, php 8.1 : propriété readonly

Personnellement, je considère cette version comme la véritable version 8 de php, car elle apporte beaucoup plus de choses utiles au langage.

Tout d'abord, on trouve la possibilité de déclarer des propriétés comme `readonly` dans une classe. Une propriété `readonly` ne peut être définie qu'une seule fois lors de la création de l'objet, elle devient ensuite non modifiable.

Si on reprend notre objet `Event` de la version `5.0` de PHP, on obtient une version plus simple, plus facile à utiliser et plus sécurisée (le côté immutable étant inscrit dans le code)
```php
final class Event
{
    public function __construct(
        public readonly string $name, 
        public readonly \DateTimeImmutable $date
    ) {
    }
    
    public function changeName($newName)
    {
        // On ne modifie pas l'objet, on retourne un nouvel objet avec 
        // les nouvelles valeurs
        return new Event($newName, $this->date);
    }
}
```

Attention, dans cette version de php, la déclaration dynamique de propriété est toujours possible, la classe n'est pas encore totalement immutable, mais on s'en approche.

### Décembre 2022, php 8.2 : la classe readonly

La voilà, enfin, la classe immutable. La version 8.2 (la dernière lorsque j'écris ce post, la 8.3 doit arriver dans quelques mois) apporte enfin un support digne de ce nom de l'immutabilité.

En effet, cette version de PHP permet de définir directement au niveau de la déclaration de la classe que celle-ci sera entièrement `readonly`, c'est-à-dire immutable. De plus, sur cette classe, la création dynamique de propriété est interdite.

```php
final readonly class Event
{
    public function __construct(
        public string $name, 
        public \DateTimeImmutable $date
    ) {
    }
    
    public function changeName($newName)
    {
        // On ne modifie pas l'objet, on retourne un nouvel objet avec 
        // les nouvelles valeurs
        return new Event($newName, $this->date);
    }
}
```

## PHPStan et Psalm

[PHPStan](https://phpstan.org/) et [Psalm](https://psalm.dev/) sont deux outils d'analyse statique de code qui permettent de rajouter une passe de contrôle et qualité sur le code d'une application.

Ces outils vont analyser le code de l'application et vérifier comment les différentes variables et objets sont construits et utilisés afin de détecter toute sorte de violation.

Il est alors possible de préciser à l'outil qu'une classe doit être immutable, l'analyseur va vérifier dans l'application que cette règle est bien respectée, c'est dire que l'objet, une fois instancié n'est jamais modifié, ou que toute modification passe par l'instanciation d'un nouvel objet.

L'avantage de ces outils est qu'ils vont tous deux permettre de rajouter un support de l'immutabilité aux versions de PHP qui en sont dépourvue.

```php
/**
 * @immutable
 */
final class Event
{
    public function __construct(
        public string $name, 
        public \DateTimeImmutable $date
    ) {
    }
    
    public function changeName($newName)
    {
        // On ne modifie pas l'objet, on retourne un nouvel objet avec 
        // les nouvelles valeurs
        return new Event($newName, $this->date);
    }
}
```

Ici, même en version 7.4 de php, l'immutabilité bien que n'étant pas prévue par le langage sera garantie par les outils d'analyse pour lesquels on a défini dans le Docblock que cette classe doit être immutable.

## Dans la pratique

L'immutabilité, jusqu'à la dernière version de PHP, relève davantage de la discipline et de bonnes pratiques qu'une caractéristique intégrée au langage. Cependant, avec l’évolution du langage et des écosystèmes qui l’entourent, il est probable que l’immutabilité devienne de plus en plus courante dans le développement PHP.

Au final, quelques conseils pour faire des objets immutables en PHP
1. Passer en PHP 8.2 (Ok, pas toujours possible)
2. Utiliser un outil d'analyse statique comme [PHPStan](https://phpstan.org/) ou [Psalm](https://psalm.dev/), et surtout, ajouter les dans votre pipeline d'intégration continue (sinon, ça ne sert à rien)
3. Utiliser les `readonly` (php 8.1 et 8.2)
4. Utiliser le `final`
5. Penser au "copy on write", c'est-à-dire de retourner une nouvelle instance de l'objet à chaque modification.

Et voilà, vous êtes prêt.
