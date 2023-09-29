# General command runner utilsing make

## Usage examples: 
##    make gh-pages
##    make git-link-template

## ADD rules to run common project related tasks

## QUARTO RULES
# Render Quarto book to gh-pages branch
gh-pages: 
	cd docs/gh-pages && quarto publish gh-pages --no-browser --no-prompt

preview:
	cd docs/gh-pages && quarto preview

## GIT RULES
# Link template 
git-link-template:
	git remote add template https://github.com/NBISweden/assembly-project-template

# Merge changes from template to current branch
git-merge-template:
	git fetch template
	git merge template/main --allow-unrelated-histories

## PHONY TARGETS
.PHONY: gh-pages preview
.PHONY: git-link-template git-merge-template
