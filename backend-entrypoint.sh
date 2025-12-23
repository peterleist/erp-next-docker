#!/bin/bash
# Backend entrypoint script - ensures Python modules are installed

cd /home/frappe/frappe-bench

echo "Checking for custom apps to install..."

# Install Spektor Go if exists
if [ -d "/home/frappe/frappe-bench/apps/spektor_go" ]; then
    echo "Installing Spektor Go Python module..."
    ./env/bin/pip install -q -e ./apps/spektor_go
    echo "Spektor Go module installed."
fi

# Use the default Frappe start command
exec /home/frappe/frappe-bench/env/bin/python -m gunicorn \
    --bind=0.0.0.0:8000 \
    --threads=4 \
    --workers=2 \
    --worker-class=gthread \
    --worker-tmp-dir=/dev/shm \
    --timeout=120 \
    --graceful-timeout=30 \
    frappe.app:application --preload
