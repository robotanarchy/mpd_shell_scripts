#!/bin/bash
# Adds one or more ($1) random album(s) from your music collection.
# This works, as long as your collection follows a consistent scheme
# like collection/artist/album. If it does not, consider using beets or
# a similar tool to sort it.
# License: Public Domain
# Part of: https://github.com/robotanarchy/robot_mpd_scripts
#

LIBRARY=/mnt/data/music/
SCHEME='./collection/*/*'

TIMES=1
[ -z "$1" ] || TIMES=$1

echo "Adding $TIMES random album(s)..."

cd "$LIBRARY"
for i in `seq 1 $TIMES`; do
	find . -type d -wholename "${SCHEME}" \
		| sort -R \
		| head -n 1 \
		| cut -d '/' -f 2- \
		| mpc add
done

echo "Done!"
