#!/bin/bash

### Script to create users with default password 
### provided as an argument

GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

### check to run as root
if [[ "$(id -u)" != "0" ]]; then
	echo -e ""${RED}"Run as root"${NC}" \a" 1>&2
	exit 1
fi

### get user names - space as separator

printf "Enter username(s) here: "
IFS=' ' read -a user_names

### exit if no users provided
### or change password

if [ -z "${user_names[*]}" ]; then
	echo -e ""${RED}"Nothing to do here"${NC}""
else
	for i in "${user_names[*]}"; do
		echo "$i"
	done
fi

	


