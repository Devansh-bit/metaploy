FROM nginx:mainline

# Configure IST Timezone
ENV TZ="Asia/Kolkata"

# Install required packages
RUN apt-get update -y && \
    apt-get install -y inotify-tools certbot && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Create necessary directories including https-enabled
RUN mkdir -p /var/www/certbot /etc/nginx/ssl /etc/nginx/https-enabled

# Copy configuration files
COPY nginx.conf /etc/nginx/
COPY cloudflare.metaploy.conf /etc/nginx/sites-enabled/

# Copy HTTPS config file (will be conditionally moved later)
COPY https.conf ./

# Copy the enhanced watch script
COPY watch_reload.sh ./
RUN chmod +x ./watch_reload.sh

# Generate a default self-signed certificate for fallback
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/default.key \
    -out /etc/nginx/ssl/default.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Create the entrypoint script
COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
