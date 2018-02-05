#!/bin/bash

### Script to create users with default password 
### provided as an argument

GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

### run as root and use only one argument

if [[ $(id -u) != "0" ]] || [[ $# != "1" ]]; then
	echo -e "${RED}Run as ${GREEN}root${RED} with ${GREEN}one${RED} argument${NC} \a"
	echo -e "${GREEN}sudo $0 <argument>${NC} \a"
	exit 1;
fi

### get user names - space as separator

echo -n -e "${RED}Enter username(s) here:${NC} "
read user_names

### exit if no users provided

# if [[ $user_names == pi* ]]; then
# 	$pi_name=$user_names
# 	echo $pi_name
# fi

uid_convert(){

# "pi" in user name must be converted to "1" 
# if uid is ok, check gid - must be the same
# then use new uid and gid to create or modify user

	if [[ $(id -u $1) != $(echo $1 | sed -e 's/pi/1/') ]]; then
		new_uid=$(echo $1 | sed -e 's/pi/1/')
	fi

	if [[ $(id -g $1) != $(echo $1 | sed -e 's/pi/1/') ]]; then
		new_gid=$new_uid
	fi
	
}





if [[ -z $user_names ]]; then
	echo -e "${RED}Nothing to do here ${NC}"
else


	for i in $user_names; do
		getent passwd $i > /dev/null 2>&1
		if [[ "$?" -eq "0" ]]; then
		echo -e "${RED}User ${GREEN}$i${RED} exist. Changing password..${NC}"
		echo "$1" | /bin/passwd $i --stdin > /dev/null 2>&1

		uid_convert $user_names

		#usermod -u $new_uid $user_names
		echo $new_gid


		else
			useradd $i
			echo -e "${RED}User${GREEN} $i ${RED}created ${NC}"
			echo $1 | /bin/passwd $i --stdin > /dev/null 2>&1
		fi
			userdel -r $i




	done
fi
