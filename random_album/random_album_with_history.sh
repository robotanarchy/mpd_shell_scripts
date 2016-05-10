#!/bin/bash
# Adds one or more ($1) random album(s) from your music collection.
# This works, as long as your collection follows a consistent scheme
# like collection/artist/album. If it does not, consider using beets or
# a similar tool to sort it. This version also keeps a history file and
# - with a simple algorithm - only adds albums, which are not in the
# history file yet. You can define a maximum length of the history file.
# License: Public Domain
# Part of: https://github.com/robotanarchy/robot_mpd_scripts
#

# config
LIBRARY=/mnt/data/music/
SCHEME='./collection/*/*'
HISTORY=~/.config/random_album_history
HISTORY_MAX_LENGTH=1000
OLD_PWD="$PWD"

# argument: album count
TIMES=1
[ -z "$1" ] || TIMES=$1

# shorten history
touch $HISTORY
tail --lines ${HISTORY_MAX_LENGTH} $HISTORY > ${HISTORY}_
mv ${HISTORY}_ $HISTORY

# add the albums
echo "Adding $TIMES random album(s)..."
cd "$LIBRARY"
for i in `seq 1 $TIMES`; do
	album="$(find . -type d -wholename "${SCHEME}" \
		| sort -R \
		| head -n 1 \
		| cut -d '/' -f 2-)"
	
	if grep -q "$album" "$HISTORY"; then
		echo "Hit a duplicate, recursing..."
		(cd "${OLD_PWD}"; $0)
	else
		echo "$album" | mpc add
		echo "$(date) $album" >> "${HISTORY}"
	fi
done

# print statistics
echo "Done."
echo "Total albums: $(find . -type d -wholename "${SCHEME}" | wc -l)"
echo "Maximum history length: ${HISTORY_MAX_LENGTH}"
echo "Current history length: $(cat $HISTORY | wc -l)"
