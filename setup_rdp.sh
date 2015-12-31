#!/bin/sh
#written by lutz schuelein

#check for root privileges
if [ "$(whoami)" != "root" ]; then echo "execution denied. no root privileges."; exit 1; fi

#define stuff
if ! [ -z $1 ]; then RDP_USER=$1; else echo "no user given. exiting."; exit 1; fi
#RDP_USER=win-rdp
RDP_USER_PASS=asdf
TTY=3


#handle user stuff
id -u $RDP_USER >/dev/null 2>&1
if [ $? -eq 0 ]
        then echo "The User $RDP_USER allready exists.\nskipping..."
        else 
                echo "User: $RDP_USER does not exist, further action required"
                useradd -m -p $RDP_USER_PASS -s /bin/bash $RDP_USER
                ! [ $? -eq 0 ] && echo "Something went terribly wront whilst setting up the new user!" && exit 1 
                echo "User: $RDP_USER added successfully"
fi

#mingetty
if [ -x "$(command -v mingetty)" ]
	then echo "mingetty allready installed\nskipping..."
	else
		echo "Installing mingetty"
		apt-get -y install mingetty
		if ! [ $? -eq 0 ]; then echo "Something went terribly wrong whilst installing mingetty"; exit 1; fi
		echo "mingetty installed successfully"
fi

#autologin
if ! [ -f /etc/init/tty$TTY.conf ]; then echo "/etc/init/tty$TTY.conf not found. Something is Wrong with the system."; exit 1; fi
echo "creating backup of /etc/init/tty$TTY.conf as /etc/init/tty$TTY.conf.backup \nif something breaks u know where to look."
cp /etc/init/tty$TTY.conf /etc/init/tty$TTY.conf.backup
sed '$d' /etc/init/tty$TTY.conf > /etc/init/tty$TTY.conf
echo "exec /sbin/mingetty --autologin $RDP_USER --noclear tty$TTY" >> /etc/init/tty$TTY.conf
echo "autologin configured."

#change tty on boot
if ! [ -e /etc/rc.local ]; then echo "/etc/rc.local not found."; exit 1; fi

if [ -x "$(command -v chvt)" ]
	then echo "chvt allready installed\nskipping..."
	else
		echo "Installing chvt"
		apt-get -y install chvt
		if ! [ $? -eq 0 ]; then echo "Something went terribly wrong whilst installing chvt"; exit 1; fi
		echo "chvt installed successfully"
fi

echo "chvt $TTY" >> /etc/rc.local
echo "change tty on boot configured."

#startx on TTY
echo "if [ $(tty) == "/dev/tty$TTY" ]; then startx -- -nocursor -depth 16; fi" >> /home/$RDP_USER/.bashrc

#setup x
cp .xsession /home/$RDP_USER/

echo "setup done."

exit 0
