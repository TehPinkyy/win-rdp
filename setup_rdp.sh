#!/bin/sh

#define stuff
RDP_USER=$1
RDP_USER_PASS=asdf
TTY=3


#handle user stuff
id -u $RDP_USER >/dev/null 2>&1
if [ $? -eq 0 ]
	then echo "The User <$RDP_USER> allready exists.\nskipping..."
	else 
		echo "User: $RDP_USER does not exist, further action required"
		adduser -m -p $RDP_USER_PASS -s /bin/bash $RDP_USER
		if [ $? -eq 1 ]; then echo "Something went terribly wront whilst setting up the new user!"; exit 1; fi 
		echo "User: $RDP_USER added successfully"
fi

#mingetty
if ! [ -x "$(command -v mingetty)" ]
	then echo "mingetty allready installed\nskipping..."
	else
		echo "Installing mingetty"
		apt-get -qq -y install mingetty
		if ! [ $? -eq 0 ]; then echo "Something went terribly wrong whilst installing mingetty"; exit 1; fi
		echo "mingetty installed successfully"
fi

exit 0
