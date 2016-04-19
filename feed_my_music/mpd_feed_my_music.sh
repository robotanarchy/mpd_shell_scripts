#!/bin/bash
# Browse your locally hosted nginx server with ncurses, in bash.
# When you hit a file, it will get added to a remote mpd server.
# Comes with a cache for dialog-"rendered" websites :)
#
# ONLY BROWSE YOUR OWN WEBSERVER WITH THIS SCRIPT, THIS SCRIPT CAN
# EASILY GET EXPLOITED!
#
# License: Public Domain
# Part of: https://github.com/robotanarchy/robot_mpd_scripts
#

# external URL of your own nginx server; must end with a trailing slash!
initial_url="http://192.168.1.174/music/"

# target MPD server (password@hostname syntax works, too)
mpd="192.168.1.160"


url="$initial_url"
while true;
do
	path="$(echo "$url" | cut -d '/' -f 4-)"
	md5="$(echo "$url" | md5sum | cut -d ' ' -f 1)"
	cachedir="./cache/$md5"
	answer="$cachedir/answer"
	links="$cachedir/links"
	ask="$cachedir/ask"
	
	if [ ! -e "$ask" ]; then
		[ -d "$cachedir" ] && rm -r "$cachedir"
		mkdir -p "$cachedir"
		
		html="$(curl -s $url)"
		args=""
		i=1
		while IFS= read -r line; do
			title="$(echo "$line" | cut -d '>' -f 2 | \
				cut -d '<' -f 1 | tr ' \\"' '_')"
			link="$(echo "$line" | cut -d '"' -f 2)"
			args="$args $i \"$title\""
			echo "$link" >> $links
			let i=i+1
		done < <(echo "$html" | grep -E '<a href=".+<\/a>' --only-matching)
		echo 1 > "$answer"
		echo "dialog --default-item \"\$(cat $answer)\" --menu \"$path\" 90 90 100 $args 2> $answer" > "$ask"
	fi
	bash $ask
	ret="$(cat $answer)"
	[ "$ret" = "" ] && exit 0
	[[ "$ret" == *"Error:"* ]] && echo "$ret" && exit 1
	
	# parse the link
	link="$(head -n $ret $links | tail -n 1)"
	if [ "$link" = "../" ]; then
		if [ "$url" == "$initial_url" ]; then
			echo "Can't go up any further, quitting..."
			exit 0
		else
			url="${url%/*/}/"
		fi
	elif echo "$link" | grep -q '/$'; then
		url="$url$link"
	else
		mpc add -h $mpd "$url$link"
	fi

done
