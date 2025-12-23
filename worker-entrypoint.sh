#!/bin/bash
# Worker entrypoint script - ensures Python modules are installed

echo "Checking for custom apps to install..."

# Install Spektor Go if exists
if [ -d "/home/frappe/frappe-bench/apps/spektor_go" ]; then
    echo "Installing Spektor Go Python module..."
    /home/frappe/frappe-bench/env/bin/pip install -q -e /home/frappe/frappe-bench/apps/spektor_go
    echo "Spektor Go module installed."
fi

# Change to bench directory
cd /home/frappe/frappe-bench

# Execute the passed command (bench worker or bench schedule)
exec "$@"
