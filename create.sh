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

# "pi" in user name must be converted to "1" 
# if uid is ok, check gid - must be the same

uid_convert(){

		new_uid=$(echo $1 | sed -e 's/pi/1/')
		new_uid=$(echo $1 | sed -e 's/mi/2/')
	
}

gid_convert(){
	
		new_gid=$(echo $1 | sed -e 's/pi/1/')
		new_gid=$(echo $1 | sed -e 's/mi/2/')
}


gid_change(){
	#check id of user's primary group 
	#if the same as id of group named as user
	#change group id
	if [[ $(id -g $1) -eq $(grep ^$1 /etc/group | cut -d: -f3) ]] && [[ $(id -g $1) != $new_gid ]]; then
		groupmod -g $new_gid $1
		echo "ok"

	#check id of user's primary group
	#if primary group id is different than group named as user
	#change primary group as secondary
	#set secondary( named as user) as primary
	#then change group id if needed
	elif [[ $(id -g $1) != $(grep ^$1 /etc/group | cut -d: -f3) ]]; then
		usermod -aG $(id -g $1) $1
		usermod -g $(grep ^$1 /etc/group | cut -d: -f3) $1
		echo "Switch primary group with supplementary"

		if [[ $(id -g $1) -eq $(grep ^$1 /etc/group | cut -d: -f3) ]] && [[ $(id -g $1) != $new_gid ]]; then
			groupmod -g $new_gid $1
		fi
	fi
}



### get user names - space as separator

echo -n -e "${RED}Enter username(s) here:${NC} "
read user_names

### exit if no users provided


if [[ -z $user_names ]]; then
	echo -e "${RED}Nothing to do here ${NC}"
else


	for i in $user_names; do
		getent passwd $i > /dev/null 2>&1
		if [[ "$?" -eq "0" ]]; then
		echo -e "${RED}User ${GREEN}$i${RED} exist. Changing password..${NC}"
		echo "$1" | /bin/passwd $i --stdin > /dev/null 2>&1

		uid_convert $i
		if [[ $(id -u $i != $new_uid) ]]; then
			usermod -u $new_uid $i
		fi

		gid_convert $i
		grep $new_gid /etc/group > /dev/null 2>&1
		if [[ "$?" -eq "0" ]]; then
			



		gid_change $1
		


		else

			gid_convert $i
			groupadd -g $new_gid $i

			uid_convert $i
			useradd -u $new_uid -g $new_gid $i

			echo -e "${RED}User${GREEN} $i ${RED}created ${NC}"
			echo $1 | /bin/passwd $i --stdin > /dev/null 2>&1

		fi
			#userdel -r $i




	done
fi
