# New Users Plus

This script creates standard local user accounts on a macOS system, prompts the user to input each username one at a time, generates a random password for each user, sets a random profile picture, and logs successful user creations and any errors encountered. 

## Usage

1. Download newUsersPlus.sh

2. Make the script executable:
chmod +x create_users.sh

3. Run the script with sudo privileges:
sudo ./create_users.sh

The script will prompt you to input each username one at a time. When you are done, enter "done" to finish.

4. View the log file:
cat /var/log/create_users.log

The log file will contain information about successful user creations and any errors encountered.

## Configuration

You can make admin accounts instead of standard accounts if you like. See the comments in the script for details.

## License

This script is released under the 





