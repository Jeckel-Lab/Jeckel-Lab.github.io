.PHONY: up up-prod

default: up

install:
	@bundle install
up:
	@jekyll serve --draft --future

up-prod:
	@jekyll serve
