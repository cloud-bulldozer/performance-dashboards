FROM registry.access.redhat.com/ubi8/ubi-minimal

RUN microdnf install git make tar
WORKDIR /dittybopper-syncer
COPY . /dittybopper-syncer/dashboards
COPY dittybopper/syncer/entrypoint.sh /bin/entrypoint.sh
RUN make -C dashboards deps
RUN chmod -R 775 /dittybopper-syncer
ENTRYPOINT ["entrypoint.sh"]
