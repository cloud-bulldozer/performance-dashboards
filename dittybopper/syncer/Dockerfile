FROM registry.access.redhat.com/ubi8/ubi-minimal

RUN microdnf install git make tar
WORKDIR /dittybopper-syncer
RUN chmod 775 /dittybopper-syncer
COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
