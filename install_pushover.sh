#!/bin/bash

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Create the update check script
cat > /usr/local/bin/check_updates.sh <<'EOF'
#!/bin/bash

# Update the package lists
sudo apt update -qq

# Get the hostname
hostname=$(hostname)

# Get the list of upgradable packages
upgradable_packages=$(apt list --upgradable 2>/dev/null | grep 'upgradable' | awk -F/ '{print $1}')

if [ -n "$upgradable_packages" ]; then
    # Send notification using Pushover
    curl -s \
  --form-string "token=ayikap9cka7vda9d7vmz81gu8gqvvv" \
  --form-string "user=uj2d5p4b6dh5a7sx18rtqcv8chw4gu" \
  --form-string "title=Updates found on $hostname" \
  --form-string "message=These new package updates are available on $hostname: $upgradable_packages" \
  https://api.pushover.net/1/messages.json > /dev/null
fi
EOF

# Make the script executable
chmod +x /usr/local/bin/check_updates.sh

# Add a cron job to run the script every 24 hours (at 03:00 AM)
echo "0 3 * * * root /usr/local/bin/check_updates.sh" > /etc/cron.d/update_notifier
chmod 644 /etc/cron.d/update_notifier

echo "Installation complete. The update checker will run every 24 hours at 03:00 AM."
