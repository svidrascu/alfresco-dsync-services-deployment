FROM quay.io/alfresco/alfresco-base-java:0.1

WORKDIR /usr/local/desktop-sync

RUN mkdir -p /usr/local/desktop-sync
COPY sync-start.sh /usr/local/desktop-sync
COPY config.yml /usr/local/desktop-sync
RUN chmod +x /usr/local/desktop-sync/sync-start.sh

ENTRYPOINT ["/usr/local/desktop-sync/sync-start.sh", "true"]
