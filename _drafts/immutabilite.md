---
layout: post
title: Petite histoire de l'immutabilité en PHP
tags: [php, page_expert_php]
has_code: true

---
L'immutabilité est un concept qui a gagné en popularité via la croissance de la programmation fonctionnelle. Cependant PHP étant un language initialement principalement utilisé pour le développement d'application Web, l'immutabilité n'a été intégré que tardivement et progressivement.

## Comprendre l'immutabilité

L'immutabilité en programmation signifie que quelque chose ne peut être modifiés une fois qu'il a été créé, il ne peut pas **muter**.

Dans le code, cela se traduit par l'utilisation de variables ou d'objets qui ne peuvent pas être modifié un fois qu'ils ont été initialisés ou instanciés. Si l'on doit faire une modification, un créera plutôt une autre objet à partir du premier avec les nouvelles propriétés.

### Pourquoi utiliser l'immutabilité&nbsp;?

1. **Sécurité**&nbsp;: Cela apporte la garanti que l'objet ne peut être modifié par une autre fonction/service par erreur
2. **Facilité de débugging**&nbp;: Il n'est pas nécessaire de suivre les modifications de cet objet
3. **Prévisibilité**&nbsp;: Cela rend le comportement du programme plus prévisible
4. **Performance**&nbsp;: Si le langage le permet, savoir qu'un objet est immutable va permettre au compilateur/interpréteur d'en optimiser le fonctionnement.

### Quand utiliser des objets immutables&nbsp;?

On utilisera des objets immutable à chaque fois que l'on a besoin de garantir que les données ne sont pas modifiables, que la nature de cet objet et son utilisation en font un objet dont la modification a posteriori serait le signe d'un bug ou d'une erreur de conception.

Par esxemple:
- **Evénement**&nbsp;: un objet décrivant un événement décris quelque chose qui est dans le passé, et comme on ne réécrit pas l'histoir, le passé estimmutable, ce type d'objet devrait être immutable
- **Commade**&nbsp;: il s'agit d'un objet décrivant un ordre, un fois l'ordre émis il devient immutable, en changer le contenu serait équivalent à modifier les instructions donnés par l'émetteur de cet ordre.
- **DTO**&nbsp;: ou Data Transfert Object, l'objetif d'un DTO est d'encapsuler des données complexe lors de leur transfert d'une fonction à une autre, d'un contexte à un autre. Ce n'est pas obligatoire, mais il peut être intéressant de faire de ces DTO des objets immutables afin de garantir qu'aucune modification peut avoir lieu dans les échanges suivants.


## PHP et immutabilité

Bien que l'immutabilité ne soit pas un élément clé de PHP, le langage a évolué pour donner, version après version les éléments nécessaires à une implémentation fiable.

### PHP 4 et antérieur

Dans les premières versions de PHP, l'immutabilité n'était pas vraiment un sujet de discussion. Le langage était principalement procédural et orienté vers la facilité d'utilisation plutôt que vers des concepts avancés comme l'immutabilité.

### Juillet 2004, PHP 5.0 et la POO

La version 5.0 sortie en juillet 2004 introduit la programmation orienté objet au language, pas encore de notion d'immutabilité, mais cette version inclus déjà le mot clé `final` qui peut-être utilisé pour une classe, rendant impossible la surcharge de celle-ci.

Il est alors déjà possible de créer un objet `final` avec toutes les propriétées privées.

Il est donc déjà possible pour le développeur de concevoir des objets immutables, sans garantie autre que la qualité du développement.
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
}
```

### Juin 2013, PHP 5.5 et l'objet DateTimeImmutable

En juin 2013, PHP sort en version 5.5 et avec cette version apparait la première notion d'immutabilité sous la forme d'un objet interne du language&nbsp;: `DateTimeImmutable`.

Cet objet dispose de la même signature que l'objet `DateTime` dont il parage l'interface `DateTimeInterface`.


---



Clone

Copy on write

Comment l'utiliser / instancier

Sources :
- https://www.easytechjunkie.com/what-is-an-immutable-object.htm
- https://hackernoon.com/5-benefits-of-immutable-objects-worth-considering-for-your-next-project-f98e7e85b6ac
- https://octoperf.com/blog/2016/04/07/why-objects-must-be-immutable/#no-initialization-hell

L'immutabilité est un concept qui a gagné en popularité dans le monde du développement logiciel, surtout avec l'adoption croissante de la programmation fonctionnelle et des architectures distribuées. Cependant, PHP, étant un langage principalement utilisé pour le développement web côté serveur, n'a pas été conçu avec l'immutabilité comme une de ses caractéristiques fondamentales.

### PHP et l'Immutabilité : Un Aperçu Historique

1. **PHP 4 et antérieurs** : Dans les premières versions de PHP, l'immutabilité n'était pas vraiment un sujet de discussion. Le langage était principalement procédural et orienté vers la facilité d'utilisation plutôt que vers des concepts avancés comme l'immutabilité.

2. **PHP 5** : Avec l'introduction de la programmation orientée objet dans PHP 5, les développeurs ont commencé à explorer des concepts plus avancés, mais l'immutabilité n'était toujours pas une priorité.

3. **PHP 7** : PHP 7 a apporté des améliorations significatives en termes de performances et de fonctionnalités, y compris des types déclaratifs. Cela a rendu plus facile pour les développeurs d'adopter des pratiques plus sûres, y compris des approches vers l'immutabilité.

4. **Bibliothèques et Frameworks** : Des frameworks comme Symfony et Laravel ont introduit des concepts avancés, y compris des façons de gérer l'immutabilité, bien que ce ne soit pas natif au langage.

5. **PHP 8 et au-delà** : Avec des fonctionnalités comme les "named arguments", "match expression" et autres améliorations, PHP 8 facilite encore plus l'adoption de bonnes pratiques, y compris l'immutabilité.

### Immutabilité dans la Pratique

Même si PHP n'a pas de support natif pour l'immutabilité, il est possible de l'implémenter en suivant certaines pratiques :

- Utilisation de `final` pour empêcher la surcharge de classes et de méthodes.
- Utilisation de propriétés privées ou protégées.
- Ne pas exposer de méthodes qui modifient l'état interne d'un objet.
- Utilisation de méthodes qui retournent de nouvelles instances au lieu de modifier l'état existant.

### Réflexions

L'immutabilité dans PHP est plus une question de discipline et de bonnes pratiques qu'une caractéristique intégrée au langage. Cependant, avec l'évolution du langage et des écosystèmes qui l'entourent, il est probable que l'immutabilité devienne de plus en plus courante dans le développement PHP.

Étant donné votre expertise en industrialisation de projets Web et en architecture, l'adoption de l'immutabilité pourrait être un ajout intéressant à vos pratiques, surtout si vous travaillez sur des systèmes complexes où la gestion de l'état est critique.


## Définition

Bien sûr ! L'immutabilité, dans le contexte de la programmation, signifie que quelque chose ne peut pas être modifié une fois qu'il a été créé. Imagine que tu as une boîte (un objet ou une variable) et que tu y mets quelque chose dedans, comme une pomme. Si la boîte est "immuable", cela signifie que tu ne peux pas changer la pomme qui est à l'intérieur. Tu ne peux pas la couper, la manger ou la remplacer par une orange.

Dans le code, cela se traduit souvent par l'utilisation de variables ou d'objets qui ne sont pas modifiés une fois qu'ils ont été initialisés. Au lieu de cela, si tu veux faire une modification, tu crées une nouvelle boîte (un nouvel objet ou une nouvelle variable) qui contient les changements.

### Pourquoi c'est important ?

1. **Sécurité** : Cela rend le code plus sûr, car tu sais que personne d'autre ne va changer ta "boîte" sans que tu le saches.

2. **Facilité de débogage** : C'est plus facile à déboguer, car tu n'as pas à suivre les changements apportés à une variable ou à un objet au fil du temps.

3. **Prévisibilité** : Cela rend le comportement du programme plus prévisible.

Donc, même si le concept peut sembler un peu complexe au début, il est en fait assez simple et très utile pour écrire du code propre et efficace.