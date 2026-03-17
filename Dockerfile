#TODO needs to specify which golang
FROM rhel8/go-toolset AS builder
WORKDIR /opt/app-root/src
COPY go/go.mod go/go.sum ./
RUN go mod download
COPY go/ ./
RUN CGO_ENABLED=0 go build -o /opt/app-root/src/deployer .

# Also needs better non-root user management.
# Getting permission denied trying to run on openshift
FROM registry.access.redhat.com/ubi8/ubi-minimal
RUN mkdir /rendered && \
    chgrp -R 0 /rendered && \
    chmod -R g=u /rendered
COPY --from=builder /opt/app-root/src/deployer /deployer
ENTRYPOINT ["/deployer"]
USER 1001
