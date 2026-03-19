FROM golang:1.23 AS builder
WORKDIR /build
COPY go/go.mod go/go.sum ./
RUN go mod download
COPY go/ ./
RUN CGO_ENABLED=0 go build -o /deployer .

FROM registry.access.redhat.com/ubi8/ubi-minimal
COPY --from=builder /deployer /usr/local/bin/deployer
COPY rendered/ /dashboards/rendered/
CMD ["deployer", "--deploy", "--input-dir", "/dashboards/rendered"]
