#!/bin/bash

# Check for OpenVPN folder
# If it exists, check for capicli
# If it exists, attempt to loop through profile files

loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )

if [ -d /Applications/OpenVPN/OpenVPN\ Connect.app ]
  then
    if [ -f /Library/Frameworks/OpenVPN.framework/Versions/Current/bin/capicli ]
      then
        for i in $(ls /tmp/*vpn.ovpn); do
          echo "Found $i!"
          echo "Importing $i..."
          sudo -u "$loggedInUser" /Library/Frameworks/OpenVPN.framework/Versions/Current/bin/capicli -f $i importprofilefromfile
          echo "Cleaning up $i..."
          rm $i
          done
      else
        echo "Unable to find capicli exiting..."
    fi
  else
    echo "Unable to find OpenVPN Connect.app exiting..."
fi
