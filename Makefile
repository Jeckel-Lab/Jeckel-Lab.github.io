.PHONY: up up-prod

# sudo pacaman -S rubygems
# gem install bundler jekyll

default: up

install:
	@bundle install

up:
	@jekyll serve --draft --future

up-prod:
	@jekyll serve
