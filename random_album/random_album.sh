#!/bin/bash
# Adds exactly one random album from your music collection.
# This works, as long as your collection follows a consistent scheme like
# collection/artist/album. If it does not, consider using beets or a similar
# tool to sort it.
# License: Public Domain
# Part of: https://github.com/robotanarchy/robot_mpd_scripts
#

LIBRARY=/mnt/data/music/
SCHEME='./collection/*/*'

cd "$LIBRARY"
find . -type d -wholename "${SCHEME}" \
	| sort -R \
	| head -n 1 \
	| cut -d '/' -f 2- \
	| mpc add
