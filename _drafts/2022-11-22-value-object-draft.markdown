---
layout: post
title: Value object en PHP
tags: [value object, ddd, php]
has_code: true
---

Les dernières versions de php (8.0, 8.1 et maintenant 8.2) ont apporté pas mal d'amélioration qui nous permettent de faire des Values Object de plus simplement et plus pertinent.

Deux évolutions en particulier vont nous être utile :
- property promotion
- readonly property (8.1)
- readonly class (8.2)

## Qu'est-ce qu'un Value Object

Pour commencer, rappelons rapidement qu'est-ce qu'un Value Object, et à quoi cela va nous servir.

> @Todo : trouver une définition un peu officielle... Blue Book Arthur C Martin ?

- final
- constructeur privé ==> privilégier les méthodes factory
- validation interne
- règle métier simple (conversion)
- interface pour "typer" l'objet
- propriété en readonly
- méthode de modification retourne une nouvelle instance
- null object

Donner des exemples + contre-exemples pour justifier chaque règle


```PHP

final class Speed implements ValueObject
{
	private const OVERSPEED_THRESHOLD = 130;
	private const METER_PER_SECOND_TO_KM_PER_HOUR_RATIO = 3.6;

	/**
	 * @param positive-float $speedInKmH
	 */
	private function __construct(
		private readonly float $speedInKmH
	) {
	}

	/**
	 * @param positive-float $speedInKmH
	 */
	public static function byKmPerH(float $speedInKmH): self
	{
		return new self($speedInKmH);
	}

	/**
	 * @param positive-float $speedInMS
	 */
	public static function byMPerS(float $speedInMS): self
	{
		return new self($speedInMS * self::METER_PER_SECOND_TO_KM_PER_HOUR_RATIO);
	}

	public function isOverSpeed(): bool
	{
		return $this->speedInKmH > self::OVERSPEED_THRESHOLD;
	}

	public function add(self $speed): self
	{
		return new self($this->speedInKmH + $speed->speedInKmH)
	}
}
```

## Distance


## Fraction

```php
/**
 * @link https://en.wikipedia.org/wiki/Fraction
 */

final class Fraction {
	public function __constructor(
		private int $numerator,
		private int $denominator
	) {
		if (0 === $denominator) {
			throw new \LogicException('Denominator can not be 0');
		}
	}

	public function add(self $fraction): self
	{
		if ($this->denominator === $fraction->denominator) {
			return new self($this->numerator + $fraction->numerator, $this->denominator);
		}
		// @todo When denominator not equals
	}

	public function sub(self $fraction): self
	{
		return $this->add(new self(-$fraction->numerator, $fraction->denominator));
	}

	public function equals(self $other): bool
	{
		// @todo Simplify function before comparing
		return $this->numerator === $other->numerator &&
			$this->denominator === $other->denominator;
	}

	public function __toString(): string
	{
		return sprintf('%d/%d', $this->numerator, $this->denominator);
	}
}

```
