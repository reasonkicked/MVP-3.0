#!/bin/bash

set -e

CSV_FILE="machines.csv"
SSH_KEY="/root/.ssh/id_rsa"
TEMP_HOSTS_FILE="/tmp/hosts.new"

# Ensure the CSV file exists
if [[ ! -f $CSV_FILE ]]; then
    echo "Error: $CSV_FILE not found."
    exit 1
fi

# Generate the new hosts file
echo "Generating new hosts file..."
echo "# Kubernetes The Hard Way" > $TEMP_HOSTS_FILE
while IFS=',' read -r IP FQDN HOST SUBNET; do
    # Skip header row
    [[ $IP == "IP" ]] && continue
    echo "$IP $FQDN $HOST" >> $TEMP_HOSTS_FILE
done < "$CSV_FILE"
echo "Generated hosts file:"
cat $TEMP_HOSTS_FILE

# Configure each machine
while IFS=',' read -r IP FQDN HOST SUBNET; do
    # Skip header row
    [[ $IP == "IP" ]] && continue

    echo "Configuring $HOST ($IP)..."

    # Redirect stdin explicitly to prevent ssh/scp from consuming the loop's input
    echo "  Copying hosts file to $IP"
    if scp -i "$SSH_KEY" "$TEMP_HOSTS_FILE" root@${IP}:/tmp/hosts.new < /dev/null; then
        echo "  Hosts file copied to $IP"
    else
        echo "  Failed to copy hosts file to $IP. Skipping."
        continue
    fi

    echo "  Updating /etc/hosts on $IP"
    if ssh -i "$SSH_KEY" root@${IP} "cat /tmp/hosts.new >> /etc/hosts && rm /tmp/hosts.new" < /dev/null; then
        echo "  /etc/hosts updated on $IP"
    else
        echo "  Failed to update /etc/hosts on $IP. Skipping."
        continue
    fi

    echo "  Setting hostname on $IP"
    if ssh -i "$SSH_KEY" root@${IP} "hostnamectl set-hostname ${FQDN}" < /dev/null; then
        echo "  Hostname set to ${FQDN} on $IP"
    else
        echo "  Failed to set hostname on $IP. Skipping."
        continue
    fi

    echo "$HOST ($IP) configured."
done < "$CSV_FILE"

# Cleanup
rm -f "$TEMP_HOSTS_FILE"
echo "All machines processed."
