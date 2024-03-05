#!/bin/bash

if [ "$1" == "--help" ]; then
	echo "Enter info in the format: <group1>:<list_of_users>, where <list_of_users> - logins separated by comma. After that users were added into the system. If the program will start with '-d' flag, all noticed groups and their user will be deleted."
	exit 0
fi
while IFS=':' read -r group users; do
	if [ "$group" == "stop" ]; then
		exit 0 #end of the program
	fi

	if [ "$1" == "-d" ]; then
		if grep -q "^$group:" /etc/group; then #check groups in a system (-q - quet)
			sudo groupdel $group
			for user in $(echo $users | tr ',' ' '); do 
				sudo userdel $user
			done
			echo "Group $group deleted"
		fi
	else
		if ! grep -q "^$group:" /etc/group; then
			sudo groupadd $group
		fi
		for user in $(echo $users | tr ',' ' '); do
			if ! id -u $user > /dev/null 2>&1; then
				sudo useradd -N $user
				sudo usermod -aG $group $user
				echo "User $user added to the group $group"
			fi
		done
	fi
done
