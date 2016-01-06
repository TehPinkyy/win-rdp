#!/bin/sh
#written by lutz schuelein

#check for root privileges
if [ "$(whoami)" != "root" ]; then echo "[fail] execution denied. no root privileges."; exit 1; fi

#define stuff
if ! [ -z $1 ]; then RDP_USER=$1; else echo "[fail] no user given. exiting."; exit 1; fi
#RDP_USER=win-rdp
RDP_USER_PASS=asdf
TTY=1


#handle user stuff
id -u $RDP_USER >/dev/null 2>&1
if [ $? -eq 0 ]
        then echo "[pass] the user $RDP_USER allready exists.\nskipping..."
        else 
                echo "[fail] the user: $RDP_USER does not exist, further action required"
                useradd -m -p $RDP_USER_PASS -s /bin/bash $RDP_USER
                ! [ $? -eq 0 ] && echo "[fail] something went terribly wront whilst setting up the new user!" && exit 1 
                echo "[ok] User: $RDP_USER added successfully"
fi

#mingetty
if [ -x "$(command -v mingetty)" ]
	then echo "[pass] mingetty allready installed\nskipping..."
	else
		echo "Installing mingetty"
		apt-get -y install mingetty
		if ! [ $? -eq 0 ]; then echo "[fail] something went terribly wrong whilst installing mingetty"; exit 1; fi
		echo "[ok] mingetty installed successfully"
fi

#autologin
if [ -f ./setup.log ]
	then echo "[pass] autologin is allready set up.\nskipping..."
	else
		if ! [ -f /etc/init/tty$TTY.conf ]; then echo "[fail] /etc/init/tty$TTY.conf not found."; exit 1; fi
		echo "creating backup of /etc/init/tty$TTY.conf as /etc/init/tty$TTY.conf.backup \nif something breaks u know where to look."
		cp /etc/init/tty$TTY.conf /etc/init/tty$TTY.conf.backup
		sed -i '$ d' /etc/init/tty$TTY.conf
		echo "exec /sbin/mingetty --autologin $RDP_USER --noclear tty$TTY" | tee -a /etc/init/tty$TTY.conf
fi
echo "[ok] autologin configured."

#change tty on boot
if ! [ -e /etc/rc.local ]; then echo "[fail] /etc/rc.local not found."; exit 1; fi

if [ -x "$(command -v chvt)" ]
	then echo "[pass] chvt allready installed\nskipping..."
	else
		echo "Installing chvt"
		apt-get -y install chvt
		if ! [ $? -eq 0 ]; then echo "[fail] Something went terribly wrong whilst installing chvt"; exit 1; fi
		echo "[ok] chvt installed successfully"
fi

if [ -f ./setup.log ]
	then echo "[pass] change tty on boot is allready set up.\nskipping..."
	else
		echo "chvt $TTY" | tee -a /etc/rc.local
		echo "[ok] change tty on boot configured."
fi

#startx on TTY
if [ -f ./setup.log ]
	then echo "[pass] startx on tty$TTY is allready set up.\nskipping..."
	else
		if ! [ -e /home/$RDP_USER/.bashrc ]; then echo "[fail] /home/$RDP_USER/.bashrc not found."; exit 1; fi
		echo "if [ \$(tty) == "/dev/tty$TTY" ]; then startx -- -nocursor -depth 16; fi" | tee -a /home/$RDP_USER/.bashrc
		echo "[ok] startx on tty$TTY configured."
fi

#setup x
cp .xsession /home/$RDP_USER/
chmod 744 /home/$RDP_USER/.xsession
chown $RDP_USER:$RDP_USER /home/$RDP_USER/.xsession
echo "[ok] xsession set up"

echo "this file is just a rudimentary check if the setup has already been run. pls dont delete." > setup.log

echo "setup done."

exit 0
