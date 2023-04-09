#!/bin/bash

# Initialize log file
LOG_FILE="/var/log/create_users.log"
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
  sudo dscl . -create /Users/$username PrimaryGroupID 20
  sudo dscl . -create /Users/$username NFSHomeDirectory /Users/$username

  # Generate random password
  password=$(openssl rand -base64 12)
  sudo dscl . -passwd /Users/$username "$password"

  # Set profile picture
  picture_dir="/Library/User Pictures"
  picture_files=$(find -L "$picture_dir" -type f | grep -Ei "\.(jpg|png|heic)" | xargs file | grep -i image | cut -d: -f1)
  if [ -n "$picture_files" ]; then
    picture_path=$(echo "$picture_files" | shuf -n1)
    sudo dscl . -create /Users/$username Picture "$picture_path"
    echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: Profile picture set for user $username: $picture_path" >> $LOG_FILE
  else
    echo "$(date "+%Y-%m-%d %H:%M:%S") ERROR: No profile pictures found for user $username in $picture_dir" >> $LOG_FILE
  fi

  # Log successful user creation
  echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: User $username created successfully" >> $LOG_FILE
done

# Log end of script
echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: Script completed" >> $LOG_FILE
