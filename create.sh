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
id_convert(){
	new_id=$(echo $1 | sed -e 's/pi/1/')
}

# function to prepare groups
group_create(){
	#if named group not exist
	getent group $1 > /dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		#check if gid is occupied
		getent group ${new_id} > /dev/null 2>&1
		if [[ $? -eq 0 ]]; then
		#if yes
		#get name of group which uses gid
			grp_name=$(getent group ${new_id} | awk -F: '{ print $1 }')
		#set new git for this group - higher than highest gid in system
			max_gid=$(awk -F: '{ print $3 }' /etc/group | sort -nr | head -n 1 )
			tmp_gid=$((max_gid+1))
		#modify group to use new gid
		
			groupmod -g ${tmp_gid} ${grp_name}
		#expected git is now not used
		#then create wanted group
			groupadd -g ${new_id} $1
			
		#if named group not exist and gid is free 
		#create group	
		else
			groupadd -g ${new_id} $1

		fi
		
	else
	#if named group exist
	#take her gid
		grp_id=$(getent group $1 | awk -F: '{ print $3 }')
	#check if wanted gid is free
		getent group ${new_id} > /dev/null 2>&1
		if [[ $? -ne 0 ]]; then
	#if free use it
		groupmod -g ${new_id} $1

		else
	#if not, get name of group which uses wanted gid
			grp_name=$(getent group ${new_id} | awk -F: '{ print $1 }')
	#set new git for this group - higher than highest gid in system
			max_gid=$(awk -F: '{ print $3 }' /etc/group | sort -nr | head -n 1 )
			tmp_gid=$((max_gid+1))
	#modify group to use new gid
			groupmod -g ${tmp_gid} ${grp_name}

	#expected git is now not used
	#then create wanted group
			groupmod -g ${new_id} $1
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
		if [[ $? -eq 0 ]]; then
			echo -e "${RED}User ${GREEN}$i${RED} exist. Changing password..${NC}"
			echo "$1" | /bin/passwd $i --stdin > /dev/null 2>&1

			id_convert $i
			group_create $i
		
		#check if user has good uid
			if [[ $(id -u $i) -ne ${new_id} ]]; then
		#if yes exit
				
			
		#if no, check if wanted uid is occupied
				getent passwd ${new_id} > /dev/null 2>&1
				if [[ $? -ne 0 ]]; then
			#if free use it
					usermod -u ${new_id} -g ${i} ${i}
					echo -e "${GREEN}Set proper uid ${NC}"
				else
			#if other user uses uid
			#get his name
					usr_name=$(getent passwd ${i} | awk -F: '{ print $1 }')
			#take max used uid in system
					max_uid=$(awk -F: '{ print $3 }' /etc/passwd | sort -nr | head -n 1 )
			#create new uid for this user
					tmp_uid=$((max_uid+1))
					usermod -u ${tmp_uid} ${usr_name}
			#wanted uid is free, so use it
					usermod -u ${new_id} -g ${i} ${i}
					echo -e "${GREEN}Set proper uid ${NC}"
				fi
			fi


		else
			id_convert $i
			group_create $i
		#user not exist
		#check if wanted uid is occupied
			getent passwd ${new_id} > /dev/null 2>&1
				if [[ $? -ne 0 ]]; then
			#if free use it
					useradd -u ${new_id} -g ${i} ${i}
					echo -e "${RED}User${GREEN} ${i} ${RED}created ${NC}"
					echo $1 | /bin/passwd $i --stdin > /dev/null 2>&1
				else
			#if other user uses uid
			#get his name
					usr_name=$(getent passwd ${i} | awk -F: '{ print $1 }')
			#take max used uid in system
					max_uid=$(awk -F: '{ print $3 }' /etc/passwd | sort -nr | head -n 1 )
			#create new uid for this user
					tmp_uid=$((max_uid+1))
					usermod -u ${tmp_uid} ${usr_name}
			#wanted uid is free, so use it
					useradd -u ${new_id} ${i}
					echo -e "${RED}User${GREEN} ${i} ${RED}created ${NC}"
					echo $1 | /bin/passwd $i --stdin > /dev/null 2>&1
				fi

		fi
			#userdel -r $i




	done
fi

