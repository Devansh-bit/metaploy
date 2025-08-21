#!/bin/sh

EMAIL=${EMAIL:-your-email@example.com}

echo "Starting certbot with automatic certificate generation..."
echo "Email: $EMAIL"

# Wait a moment for nginx configs to be copied
sleep 5

# Extract domains from all nginx https-enabled configs
if [ -d "/etc/nginx/https-enabled" ] && [ "$(ls -A /etc/nginx/https-enabled 2>/dev/null)" ]; then
    echo "Scanning nginx configs for domains..."
    
    # Better domain extraction - only look at server_name lines, exclude comments
    DOMAINS=$(grep -h "^\s*server_name" /etc/nginx/https-enabled/*.conf 2>/dev/null | \
        sed 's/^\s*server_name\s*//g' | \
        sed 's/;//g' | \
        tr ' ' '\n' | \
        grep -v '^_$' | \
        grep -v '^$' | \
        grep -E '^[a-zA-Z0-9.-]+$' | \
        sort -u)
    
    if [ -z "$DOMAINS" ]; then
        echo "No valid domains found in nginx configurations"
    else
        echo "Found domains to check certificates for:"
        for domain in $DOMAINS; do
            echo "  - $domain"
        done
        echo ""
        
        for domain in $DOMAINS; do
            # Skip empty or invalid domains
            if [ -z "$domain" ] || [ "$domain" = "_" ]; then
                continue
            fi
            
            echo "Checking certificate for: $domain"
            
            if [ ! -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]; then
                echo "⏳ Generating certificate for $domain..."
                
                if certbot certonly \
                    --webroot \
                    -w /var/www/certbot \
                    --email "$EMAIL" \
                    -d "$domain" \
                    --agree-tos \
                    --no-eff-email \
                    --non-interactive \
                    --staging \
                    --rsa-key-size 2048; then
                    echo "✅ Certificate generated successfully for $domain"
                else
                    echo "❌ Failed to generate certificate for $domain"
                fi
            else
                echo "✅ Certificate for $domain already exists"
            fi
            echo ""
        done
    fi
else
    echo "No nginx https-enabled directory found or no configs present"
fi

echo "🔄 Starting certificate renewal daemon..."
echo "Certificates will be renewed every 12 hours"

# Set up signal handling for graceful shutdown
trap 'echo "Shutting down certbot daemon..."; exit 0' TERM

# Start renewal loop
while :; do
    echo "$(date): Checking for certificate renewals..."
    certbot renew --quiet
    sleep 12h & wait $!
done
