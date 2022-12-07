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


```php
public function getFirstItemFromJson(string $jsonString): stdClass
{
    $result = json_decode($jsonString);
    
    /** @phpstan-ignore-next-line */
    return current($result);
}
```

