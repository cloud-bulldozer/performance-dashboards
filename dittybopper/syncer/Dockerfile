FROM registry.access.redhat.com/ubi8/ubi-minimal

WORKDIR /performance-dashboards
COPY dittybopper/syncer/entrypoint.sh /bin/entrypoint.sh
COPY rendered/*.json /performance-dashboards/
RUN chmod -R 775 /performance-dashboards
ENTRYPOINT ["entrypoint.sh"]
