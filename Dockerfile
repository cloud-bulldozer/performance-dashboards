FROM registry.access.redhat.com/ubi8/ubi-minimal

# Set the working directory
WORKDIR /performance-dashboards

# Install necessary libraries for subsequent commands
RUN microdnf install -y podman python3 python3-pip && \
    microdnf clean all && \
    rm -rf /var/cache/yum

COPY . .

# Set permissions
RUN chmod -R 775 /performance-dashboards

# Install dependencies
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# Start the command
CMD ["python3", "dittybopper/syncer/entrypoint.py"]
