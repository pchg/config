#! /bin/sh

# remote-login.sh - Version 1.0
# Let you do a remote (or local) login to any machine on your network
# By Raphaël HALIMI <raphaelh@easynet.fr>

# Hostnames of the machines you want to connect to. Change this to suit your
# needs, by entering the hostnames separated by spaces

MACHINES="pomme meste yanacocha bab-nas mardaub"

# Command to launch for login (ssh, rlogin, telnet...)

LOGIN_COMMAND=ssh

# Some variables you don't need to change

COUNT=1
NUMBER_OF_MACHINES=`echo $MACHINES | wc -w`

# Here we go... First we print the hostanmes list

clear ; echo "Which host do you want to login to ?"

echo

for I in $MACHINES ; do
    if [ $I = $HOSTNAME ] ; then		# Tests if the machine is
       echo "$COUNT) Login to $I (localhost)"	# the localhost, and if so,
       COUNT=$[ $COUNT + 1 ]			# we indicate it :-)
    else
       echo "$COUNT) Login to $I"
       COUNT=$[ $COUNT + 1 ]
    fi
done

echo ; echo -n "Please enter a number between 1 and $[ $COUNT - 1 ] to login, or ENTER to exit: "

# Now we wait for an answer

read MACHINE_NUMBER

# If that answer is empty (--> user pressed ENTER alone), terminate the script

if [ -z $MACHINE_NUMBER ] ; then
   exit
fi

# Check if the answer is in the correct range

while [ $MACHINE_NUMBER -lt 1 -o $MACHINE_NUMBER -gt $NUMBER_OF_MACHINES ] ; do
      echo ; echo "Sorry, this is not a valid number."
      echo -n "Please enter a number between 1 and $[ $COUNT - 1 ] (or Ctrl-C to exit): "
      read MACHINE_NUMBER
done


# Now we check which hostname the number entered matches to, and log to the
# matching host

COUNT=1

for I in $MACHINES ; do
    if [ $MACHINE_NUMBER = $COUNT ] ; then
       if [ $I = $HOSTNAME ] ; then	# If the machine is the local host,
          				# we start a simple shell instead
       					# of a remote login process
          echo -n "Login as user [$USER] : " ; read REMOTE_USER
	  if [ -z $REMOTE_USER ] ; then
	     sh --login
	  else
	     su - $REMOTE_USER
	  fi
       else				# of a remote login process
          echo -n "Login as user [$USER] : " ; read REMOTE_USER
	  if [ -z $REMOTE_USER ] ; then
	     $LOGIN_COMMAND $I
	  else
	     $LOGIN_COMMAND -l $REMOTE_USER $I
	  fi
       fi
    fi
    COUNT=$[ $COUNT + 1 ]
done
