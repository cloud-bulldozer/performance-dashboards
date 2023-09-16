FROM ubuntu

WORKDIR /performance-dashboards
ARG DEBIAN_FRONTEND=noninteractive

# Install necessary libraries for subsequent commands
RUN apt-get update && apt-get install -y podman dumb-init python3.6 python3-distutils python3-pip python3-apt

COPY . .
RUN chmod -R 775 /performance-dashboards

# Install dependencies
RUN python3 -m pip install --upgrade pip
RUN pip install -r requirements.txt

# Cleanup the installation remainings
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Start the command
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["python3", "dittybopper/syncer/entrypoint.py"]