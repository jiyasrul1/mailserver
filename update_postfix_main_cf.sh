#!/bin/bash
# Load variables from config.sh
source ./config.sh

# Check if required variables are set
if [[ -z "$myhostname" || -z "$mydomain" ]]; then
  echo "Error: myhostname or mydomain variable not set in config.sh"
  exit 1
fi

# Remove old main.cf if it exists
if [ -f /etc/postfix/main.cf ]; then
  sudo rm /etc/postfix/main.cf
fi

# Create new main.cf with substituted variables
sudo tee /etc/postfix/main.cf > /dev/null <<EOF
# Basic info
myhostname = $myhostname
mydomain = $mydomain

# Listen on all interfaces, IPv4 + IPv6
inet_interfaces = all
inet_protocols = all

# Disable local delivery to system users by excluding mydestination entries
mydestination = localhost, localhost.\$mydomain

# Virtual mailbox setup
virtual_mailbox_domains = $mydomain
virtual_mailbox_base = /var/mail/vhosts
virtual_mailbox_maps = hash:/etc/postfix/virtual_mailboxes
virtual_minimum_uid = 100

virtual_uid_maps = static:999
virtual_gid_maps = static:989

virtual_transport = virtual

# Mailbox size unlimited
mailbox_size_limit = 0

# Recipient delimiter (optional)
recipient_delimiter = +

# TLS parameters (optional, but good to keep)
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_tls_security_level=may

smtp_tls_CApath=/etc/ssl/certs
smtp_tls_security_level=may
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache

# SMTP restrictions (allow mynetworks, SASL auth, block others for relaying)
smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, defer_unauth_destination

# Networks allowed to relay
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128

# Local mail delivery disabled, no home mailboxes
home_mailbox =

# Alias files (optional)
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
EOF
