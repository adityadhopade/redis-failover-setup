FROM redis:7.0-alpine

# Copy the sentinel configuration file
COPY sentinel.conf /etc/redis/sentinel.conf

# Expose the Sentinel port
EXPOSE 26379

# Set the entrypoint to the redis-sentinel command with the sentinel configuration
ENTRYPOINT ["redis-sentinel", "/etc/redis/sentinel.conf"]
