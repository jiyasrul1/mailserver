echo "
█████ █   █ █   █ █████ █    
  ██  █   █ █   █ █     █    
  ██  █   █ █   █ ████  █    
  ██  █   █ █   █ █     █    
███   █████  █ █  █████ █████
"


source install-postfix.sh

echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"
echo "CONFIGURING POSTFIX"

echo "INSTALLED POSTFIX"
echo "INSTALLED POSTFIX"
echo "INSTALLED POSTFIX"
echo "INSTALLED POSTFIX"
echo "INSTALLED POSTFIX"
echo "INSTALLED POSTFIX"
echo "INSTALLED POSTFIX"
echo "INSTALLED POSTFIX"
echo "INSTALLED POSTFIX"


source ./config.sh


# Create mail directory for the domain
sudo mkdir -p /var/mail/vhosts/"$mydomain"

# Change ownership and permissions for postfix user
sudo chown -R postfix:postfix /var/mail/vhosts
sudo chmod -R 770 /var/mail/vhosts

# Create group 'vmail' with GID 5000 if it doesn't exist
if ! getent group vmail >/dev/null; then
    sudo groupadd -g 5000 vmail
else
    echo "Group 'vmail' already exists"
fi

# Create user 'vmail' with UID 5000 if it doesn't exist
if ! id -u vmail >/dev/null 2>&1; then
    sudo useradd -g vmail -u 5000 vmail -d /var/mail/vhosts -m
else
    echo "User 'vmail' already exists"
fi

# Change ownership to vmail user/group
sudo chown -R vmail:vmail /var/mail/vhosts

echo "Updating package list..."
sudo apt update


echo "Installing ufw..."
sudo apt install -y ufw

echo "Enabling ufw..."
sudo ufw enable

echo "Setting default policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "Allowing essential ports for mail server..."

# SSH
sudo ufw allow 22

# SMTP (outgoing mail)
sudo ufw allow 25
sudo ufw allow 587
sudo ufw allow 465

# IMAP (incoming mail)
sudo ufw allow 143
sudo ufw allow 993

# POP3 (optional)
sudo ufw allow 110
sudo ufw allow 995

# HTTP/HTTPS (webmail, Let's Encrypt)
sudo ufw allow 80
sudo ufw allow 443

echo "Current UFW status:"
sudo ufw status verbose


# Check if mydomain is set
if [[ -z "$mydomain" ]]; then
  echo "Error: mydomain variable not set in config.sh"
  exit 1
fi

# Create the virtual_mailboxes file with correct content
cat <<EOF > /etc/postfix/virtual_mailboxes
user1@$mydomain $mydomain/user1/
user2@$mydomain $mydomain/user2/
EOF

echo "File /etc/postfix/virtual_mailboxes created successfully with domain $mydomain."


sudo postmap /etc/postfix/virtual_mailboxes
