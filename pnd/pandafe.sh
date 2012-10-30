#!/bin/bash

# show README, if not yet shown
if [[ ! -f ".readme_shown" ]]; then
	/usr/bin/links -g -mode 800x480 README
	touch .readme_shown
fi

# update Program definitions, if appropriate
if [[ -d "Program" ]]; then
	source="share/pandafe/Program"
	for sourceprogram in $source/*; do
		name=$(basename $sourceprogram)
		targetprogram="Program/$name"
		if [[ -f $targetprogram && $sourceprogram -nt $targetprogram ]]; then
			cp $sourceprogram $targetprogram
		fi
	done
fi


bin/pandafe
