---
layout: post
title: phpstan-ignore-next-line is evil
has_code: true
complexity: 2
---
PHPStan est un outil d'analyse static de code.

Il peut arriver que ce type d'outils remonte des faux-positifs, c'est-à-dire qu'il remonte une potentielle erreur là où il ne peut pas y en avoir. Ces outils proposent donc des options pour désactiver ces alertes.

Pour PHPStan, l'option la plus utilisée est `php-ignore-next-line` qui va indiquer à l'analyseur de ne pas lever d'alerte sur la ligne suivante.

Hélas, c'est bien souvent une option très facile pour ignorer une alerte, pensant que cette erreur n'arrivera jamais.

Prenons l'exemple du code suivant :
```php
public function getFirstItemFromJson(string $jsonString): stdClass
{
    $result = json_decode($jsonString);
    return current($result);
}
```

Cette fonction prend une chaine de caractère supposée contenir un json, va décoder cette chaine sous la forme d'un tableau et retourner le premier élément du tableau.

La signature de la méthode indique que l'objet retourné sera une instance de `stdClass`.

Dans le cas où le contexte d'exécution de cette méthode est totalement maitrisé, on peut se dire que la chaine de caractère envoyé sera :
1. toujours un json
2. contenant toujours un tableau au premier niveau
3. le premier élément sera toujours un objet

La méthode étant publique, pour un analyseur statique, ce contexte "maitrisé" n'existe pas.

L'analyseur statique va donc nous remonter une erreur de type:
```
Error PHPStan
Error Psalm
```

En gros, la signature de la méthode doit retourner une instance de `stdClass`, mais en réalité elle retourne `mixed` (autrement dit, n'importe quoi).

En effet, la méthode `json_decode` va retourner un type différent en fonction de la chaine :
```php
echo get_type(json_decode('[]'));        // array
echo get_type(json_decode('{}'));        // object
echo get_type(json_decode('""'));        // string
echo get_type(json_decode('true'));      // boolean
```

Lorsque l'on maitrise le contexte, le premier réflexe est de dire : "T'y connais rien, moi je te dis que ce sera toujours un objet, je te le jure, la vie de ma mère."

Ce qui se traduit par :
```php
public function getFirstItemFromJson(string $jsonString): stdClass
{
    $result = json_decode($jsonString);
  
    /** @phpstan-ignore-next-line */
    return current($result);
}
```

Ok, PHPStan ne gueule plus, tout est OK.

Seulement voilà, que se passe-t-il réellement si le json vient par exemple d'un retour d'appel API et qu'une erreur se produit, le retour n'a pas le format attendu ?

