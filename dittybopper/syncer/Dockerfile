FROM registry.access.redhat.com/ubi8/ubi-minimal AS builder
RUN microdnf install make git tar
WORKDIR /performance-dashboards
COPY . /performance-dashboards
RUN make

FROM registry.access.redhat.com/ubi8/ubi-minimal
WORKDIR /performance-dashboards
COPY dittybopper/syncer/entrypoint.sh /bin/entrypoint.sh
COPY --from=builder /performance-dashboards /performance-dashboards
RUN chmod -R 775 /performance-dashboards
ENTRYPOINT ["entrypoint.sh"]
