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
	
}

gid_convert(){

	new_gid=$(echo $1 | sed -e 's/pi/1/')

}

group_switch(){
	
	if [[ $(id -g $1) -ne $(grep ^$1 /etc/group | cut -d: -f3) ]]; then
		usermod -g $new_gid $1
	fi
}

group_exist(){
	#check if group exist by gid 

	getent group $new_gid > /dev/null 2>&1
	if [[ $? -ne 0 ]]; then
	#if no check existence of group name
		getent group $1 > /dev/null 2>&1

		if [[ $? -ne 0 ]]; then
	#if no, add group
			groupadd -g $new_gid $1
			echo "Add new group"


		else
	#if named group exist - exit
			echo "Group exist"
			groupmod -g $new_gid $1
			
		fi

	else
	#if gid is occupied, change gid
		tmp_gid=$(grep ^$1 /etc/group | cut -d: -f3)
		#let tmp_gid+=1
		tmp_gid=$((tmp_gid+1))
		groupmod -g $tmp_gid $1

		echo "Change group id of $1 to $tmp_gid"
	##### jak istnieje uzytkownik pi i ma poprawna grupe, 
	#####to zmienia sie jej numer
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

		#create user
		uid_convert $i
		if [[ $(id -u $i) -ne $new_uid ]]; then
			usermod -u $new_uid $i
		fi

		#change group of user

		gid_convert $i
		group_switch $i
		group_exist $i




		else

		gid_convert $i
		group_exist $i

		uid_convert $i

		useradd -u $new_uid -g $new_gid $i

			echo -e "${RED}User${GREEN} $i ${RED}created ${NC}"
			echo $1 | /bin/passwd $i --stdin > /dev/null 2>&1

		fi
			#userdel -r $i




	done
fi

