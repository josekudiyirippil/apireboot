# Stage 1: Base stage with the ose-cli image
FROM registry.access.redhat.com/openshift3/ose-cli:v3.11 AS base

# Stage 2: Final stage combining ose-cli and your script
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

# Install necessary tools (if not present in base image)
RUN microdnf install -y cronie

# Copy the ose-cli binary from the base stage
COPY --from=base /usr/bin/oc /usr/bin/oc

# Add your script to the image
COPY delete-oldest-pod.sh /usr/local/bin/delete-oldest-pod.sh

# Set execute permissions for the script
RUN chmod +x /usr/local/bin/delete-oldest-pod.sh

# Set up cron scheduler
COPY cronjob.txt /etc/cron.d/delete-oldest-pod-cron
RUN chmod 0644 /etc/cron.d/delete-oldest-pod-cron && \
    crontab /etc/cron.d/delete-oldest-pod-cron && \
    touch /var/log/cron.log

# Run the cron scheduler in the foreground
CMD ["crond", "-f"]
