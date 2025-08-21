#!/bin/bash

# Check if HTTPS is enabled and copy https.conf if needed
if [ "$METAPLOY_HTTPS_ENABLED" = "true" ]; then
    echo "HTTPS enabled - copying https.conf to sites-enabled directory"
    cp ./https.conf /etc/nginx/sites-enabled/
else
    echo "HTTPS disabled - skipping https.conf setup"
fi

# Start the watch reload script
exec ./watch_reload.sh
