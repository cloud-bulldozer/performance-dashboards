FROM registry.access.redhat.com/ubi8/ubi-minimal

RUN microdnf install git make tar
WORKDIR /dittybopper-syncer
RUN chmod 775 /dittybopper-syncer
COPY dittybopper/syncer/entrypoint.sh /bin/entrypoint.sh
COPY . /dittybopper-syncer/dashboards
ENTRYPOINT ["entrypoint.sh"]
