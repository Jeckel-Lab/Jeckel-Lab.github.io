.PHONY: up up-prod

up:
	@jekyll serve --draft --future

up-prod:
	@jekyll serve
