FROM caddy:alpine

# Install git for cloning/pulling the public repo
RUN apk add --no-cache git

# Copy Caddy configuration
COPY Caddyfile /etc/caddy/Caddyfile

# Copy and configure the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
