#!/bin/bash

# Loop until user enters 'done'
while true; do
  # Prompt user to input username
  read -p "Enter a username (or 'done' to finish): " username

  # Exit loop if user enters 'done'
  if [ "$username" == "done" ]; then
    break
  fi

  # Create user account
  sudo dscl . -create /Users/$username
  sudo dscl . -create /Users/$username UserShell /bin/bash
  sudo dscl . -create /Users/$username RealName "$username"
  sudo dscl . -create /Users/$username UniqueID "$(($(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)+1))"
  sudo dscl . -create /Users/$username PrimaryGroupID 80
  sudo dscl . -create /Users/$username NFSHomeDirectory /Users/$username
  sudo dscl . -passwd /Users/$username changeme
  sudo dscl . -append /Groups/admin GroupMembership $username

  # Set profile picture
  picture_path="/Library/User Pictures/Animals/$(ls /Library/User\ Pictures/Animals | shuf -n 1)"
  sudo dscl . -create /Users/$username Picture "$picture_path"
done
