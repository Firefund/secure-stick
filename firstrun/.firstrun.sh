#!/bin/bash
#
# Initial setup of the passphrase
# Called by .xsessionrc on first boot of the Tails-stick
#

OLDPP="1234" # standard passphrase given to the persistent container on the original image we'll flash onto the sticks
PP1="x" #
PP2="y" # This probably isn't necessary but let's set the variables where we compare the passwords to something that definitely doesn't match, just to be safe

# Let's find out which is the actual partition with the LUKS container, picking /dev/sdb may on occasion end in tears, shouting
CRYPTPART=$(lsblk -i | grep -B1 TailsData | head -n1 | awk '{print $1}' | sed 's/^`-//')

# User is prompted for a new passphrase, which is then set in the following block
if [ -e /home/amnesia/.firstrun ] ; then
  while [[ $PP1 != $PP2 ]] ; do
		echo -e "Looks like this is your first time booting Tails"
		echo -e "This script will help you set up a new passphrase for your encrypted storage"
		echo -e "Please try to set a long, secure passphrase THAT YOU WON'T FORGET. Please note that it won't be displayed on screen."
		echo -e "If you were to forget it, you would have no way of recalling the documents you've saved!\n"
    echo -e "Enter new passphrase for $CRYPTPART\n"
    read -s PP1
    echo -e "Verify passphrase:\n"
    read -s PP2
    if ! [ $PP1 == $PP2 ] ; then
      echo -e "Passphrases do not match, please try again!\n"
    fi
  done
  printf '%s\n' "$OLDPP" "$PP1" "$PP1" | sudo cryptsetup luksChangeKey /dev/$CRYPTPART
fi

echo "Passphrase successfully changed! "

exit 0
# Once the script is through, the files necessary for the inital setup are deleted by .xsessionrc
