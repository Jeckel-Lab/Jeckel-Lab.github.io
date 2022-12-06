---
layout: post
title: Les différents opérateurs ternaires en php
tags: [php]
categories: [php]
complexity: 1
has_code: true
resources:
    - https://www.geeksforgeeks.org/php-ternary-operator/

---
Les opérateurs conditionnels de type `if / else` ou `switch` permettent d'évaluer des conditions et de définir des comportements correspondants.

L'opérateur ternaire est un raccourci qui permet de rendre moins verbeux des opérations conditionnelles simple.

En plus de l'opérateur original, le langage PHP s'est équipé au fil du temps de nouveaux opérateurs pouvant s'avéré utile ou confusant selon la situation.

Voici donc une petite revue de ce que propose le langage, ainsi que des préconisations sur quand et comment les utiliser.

## L'opérateur original

```
<Condition> ? <Valeur si vrai> : <valeur si faux>
```

- Condition : test à effectuer
- Valeur si vrai : valeur retournée si la condition est évaluée à Vrai
- Valeur si faux : valeur retournée si la condition est évaluée à Faux

Exemple d'utilisation :

```php
$age = 15;
$generation = $age > 60 ? 'Boomer' : 'Not boomer';
```

Ici l'opérateur ternaire permet de remplacer simplement le couple `if / else` suivant :

```php
if ($a > $15) {
    $result = 'plus grand';
} else {
    $result = 'plus petit';
} 
```

## condition ?: résultat

> "Elvis operator"

## condition ?? résultat

Si null

## condition ? si vrai : throw Exception

php > 8.1 ?

## condition ?: throw Exception

php > 8.1 ?

## condition ?? throw Exception

php > 8.1 ?
