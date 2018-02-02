#!/bin/bash

### Script to create users with default password 
### provided as an argument

GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

### check to run as root
if [[ "$(id -u)" != "0" ]]; then
	echo -e ""${RED}"Run as root"${NC}" \a" 1>&2
	exit 1;
fi

### get user names - space as separator

printf "Enter username(s) here: "
read user_names

### exit if no users provided

if [[ -z $user_names ]]; then
	echo -e "${RED}Nothing to do here ${NC}"
else
	for i in $user_names; do
		getent passwd $i > /dev/null 2>&1
		if [[ "$?" -eq "0" ]]; then
		# if no create and set passwd
		else
			useradd $i
			echo -e "${RED}User${GREEN} $i ${RED}created ${NC}"
		fi
		#userdel -r "${user_names[$user_no]}"
	done
fi
exit 0;



















# total_users="${#user_names[@]}"

# if [[ -z "${#user_names[@]}" ]]; then
# 	echo -e ""${RED}"Nothing to do here"${NC}""

# else
# 	for (( user_no = 0; user_no <= $(( $total_users -1 )); user_no++ )); do
# 		echo "$user_no"

# 		# check if user exist if yes - change passwd
# 		getent passwd "${user_names[$user_no]}" > /dev/null 2>&1
# 		if [[ "$?" -eq "0" ]]; then
# 			echo "${user_names[$user_no]}"

# 		# if no create and set passwd
# 		else
# 			useradd "${user_names[$user_no]}"
# 			echo -e ""${RED}"User "${GREEN}""${user_names[$user_no]}""${RED}" created "${NC}""
# 		fi
# 		userdel -r "${user_names[$user_no]}"
# 	done

	
# fi