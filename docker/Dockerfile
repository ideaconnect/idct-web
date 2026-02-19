FROM caddy:alpine

# Install git for cloning/pulling the public repo
RUN apk add --no-cache git

# Copy Caddy configuration
COPY Caddyfile /etc/caddy/Caddyfile

# Copy and configure the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Mount as persistent volumes in QNAP Container Station:
#   /data   → stores TLS certificates (CRITICAL: keep this persistent)
#   /config → stores last-active Caddy config
VOLUME ["/data", "/config"]

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

ENTRYPOINT ["/entrypoint.sh"]
