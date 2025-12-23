#!/bin/bash
# ERPNext v16 Site Initialization Script

SITE_NAME="${SITE_NAME:-erp.local}"

echo "Configuring Frappe Bench for v16..."

# Set global configuration
bench set-config -g db_host mariadb
bench set-config -g redis_cache redis://redis-cache:6379
bench set-config -g redis_queue redis://redis-queue:6379
bench set-config -g redis_socketio redis://redis-queue:6379

echo "Installing Spektor Go app..."

# Get Spektor Go app from GitHub
bench get-app https://github.com/peterleist/spektor-go

echo "Creating new site: ${SITE_NAME}"

# Create the site
bench new-site "${SITE_NAME}" \
  --mariadb-root-password "${MYSQL_ROOT_PASSWORD}" \
  --admin-password "${ADMIN_PASSWORD}" \
  --no-mariadb-socket \
  --install-app erpnext

echo "Installing Spektor Go on site..."

# Install Spektor Go app on the site
bench --site "${SITE_NAME}" install-app spektor_go

echo "Site created successfully!"

# Enable scheduler
bench --site "${SITE_NAME}" scheduler enable

echo "Scheduler enabled!"

# Set site as default
echo "${SITE_NAME}" > sites/currentsite.txt

echo "Ensuring Spektor Go Python module is installed..."

# Install Spektor Go Python module in the virtual environment
/home/frappe/frappe-bench/env/bin/pip install -q -e /home/frappe/frappe-bench/apps/spektor_go

echo "Configuration complete!"
