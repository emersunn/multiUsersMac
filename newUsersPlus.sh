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

  # Create user account, change PrimaryGroupID 20 to PrimaryGroupID 80 If you want to make admin accounts
  sudo dscl . -create /Users/$username
  sudo dscl . -create /Users/$username UserShell /bin/bash
  sudo dscl . -create /Users/$username RealName "$username"
  sudo dscl . -create /Users/$username UniqueID "$(($(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)+1))"
  sudo dscl . -create /Users/$username PrimaryGroupID 20
  sudo dscl . -create /Users/$username NFSHomeDirectory /Users/$username

  # Generate random password
  password=$(openssl rand -base64 12)
  sudo dscl . -passwd /Users/$username "$password"

  # Add user to admin group
  sudo dscl . -append /Groups/admin GroupMembership $username

  # Set profile picture
  picture_dirs=("/Library/User Pictures/")
  picture_path=""
  for dir in "${picture_dirs[@]}"; do
    if [ -d "$dir" ]; then
      picture_files=($(find "$dir" -type f -iname "*.jpg" -or -iname "*.png"))
      if [ ${#picture_files[@]} -gt 0 ]; then
        picture_path=${picture_files[$RANDOM % ${#picture_files[@]}]}
        break
      fi
    fi
  done
  # Log successful user creation
  echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: User $username created successfully" >> $LOG_FILE
done

# Log end of script
echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: Script completed" >> $LOG_FILE
