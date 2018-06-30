#!/bin/bash

# USAGE
# ./smloadr-wrapper SMLOADR_BINARY URLS_LIST QUALITY
# Example: ./smloadr-wrapper SMLoadr links.txt FLAC
# Supported values for quality: MP3_128/MP3_320/FLAC
# Less than 320 isnt even an option, forget about it, asshole.

# COLOR VARIABLES
green='\033[0;32m'
red='\033[0;31m'
cyan='\033[0;36m'
black='\033[0;30m'

# CHECK NUMBER OF ARGUMENTS PASSED TO THE WRAPPER
if [[ $# -ne 3 ]] ; then
	echo "You need to specify 3 arguments. Exiting.."
	echo "Example: ./smloadr-wrapper SMLoadr links.txt FLAC"
	exit 1
fi

# PROGRAM VARIABLES
smloadr=$1
file=$2
quality=$3
initial_lines="$(cat $file | wc -l)"
lines=$initial_lines

echo -e ${cyan}"#########################################################"
echo -e ${cyan}"# ${green}There are ${cyan}$lines${green} different links in the file you provided. #"
echo -e ${cyan}"#########################################################"
# CHECK IF FILE CONTAIN AT LEAST 1 LINE
if [[ $initial_lines -eq 0 ]] ; then
	echo "Your file need to contain at least 1 link to process. Exiting.."
	exit 1
fi

# PROCESSING THE LIST
while read url; do
    read -ra result <<< $(curl -Is --connect-timeout 5 "${url}" || echo "timeout 500")
    status=${result[1]}
    if [ $status -ne 404 ]
	then
		echo -e "${red}--> ${green}Processing ${cyan}${url}${cyan} - ${green}Links remaining [${lines}/${initial_lines}]"
		./$smloadr -q "${quality}" -u $url
		lines=$((lines - 1))
	else
        echo -e "${red}${url} isn't a valid url. Skipping."
		lines=$((lines - 1))
	fi
done < $file

