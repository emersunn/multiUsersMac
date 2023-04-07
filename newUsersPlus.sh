#!/bin/bash

# Initialize log file
LOG_FILE="$HOME/create_users.log"
echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: Starting script" >> $LOG_FILE

# Loop until user enters 'done'
while true; do
  # Prompt user to input username
  read -p "Enter a username (or 'done' to finish): " username

  # Exit loop if user enters 'done'
  if [ "$username" == "done" ]; then
    break
  fi

  # Check if user already exists
  if id "$username" &>/dev/null; then
    echo "$(date "+%Y-%m-%d %H:%M:%S") ERROR: User $username already exists" >> $LOG_FILE
    continue
  fi

  # Create user account
  sudo dscl . -create /Users/$username
  sudo dscl . -create /Users/$username UserShell /bin/bash
  sudo dscl . -create /Users/$username RealName "$username"
  sudo dscl . -create /Users/$username UniqueID "$(($(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)+1))"
  sudo dscl . -create /Users/$username PrimaryGroupID 80
  sudo dscl . -create /Users/$username NFSHomeDirectory /Users/$username

  # Generate random password
  password=$(openssl rand -base64 12)
  sudo dscl . -passwd /Users/$username "$password"

  # Add user to admin group
  sudo dscl . -append /Groups/admin GroupMembership $username

  # Set profile picture
  if [ -d "/Library/User Pictures/Flowers/" ]; then
    picture_path="/Library/User Pictures/Flowers/$(ls /Library/User\ Pictures/Flowers | shuf -n 1)"
    sudo dscl . -create /Users/$username Picture "$picture_path"
  else
    echo "$(date "+%Y-%m-%d %H:%M:%S") ERROR: Profile picture directory not found" >> $LOG_FILE
  fi

  # Log successful user creation
  echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: User $username created successfully" >> $LOG_FILE
done

# Log end of script
echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: Script completed" >> $LOG_FILE
