#!/bin/bash

# Exit on any error
set -e

# Define the mail name
MAILNAME="mail.richbio.online"

echo "Setting mail name to $MAILNAME..."

# Pre-seed Postfix installation with the mail name and configuration type
echo "postfix postfix/mailname string $MAILNAME" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections

# Install Postfix (non-interactive)
echo "Installing Postfix..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix

# Ensure the mail name is set
echo "$MAILNAME" | sudo tee /etc/mailname

# Restart Postfix to apply the changes
sudo systemctl restart postfix

echo "Postfix installation and configuration complete."


