# General command runner utilsing make

## Usage: make gh-pages

## ADD rules to run common project related tasks

# Render Quarto book to gh-pages branch
gh-pages: 
	cd docs/gh-pages && quarto publish gh-pages --no-browser --no-prompt

.PHONY: gh-pages
