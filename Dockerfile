FROM quay.io/alfresco/alfresco-base-java:0.1

WORKDIR /usr/local/desktop-sync

ENV LOCAL_ROOT=/usr/local/desktop-sync
ARG ALFSS_URL=https://nightlybuilds.alfresco.com/DesktopSync/LATEST/5.x-Distribution-Zip/AlfrescoSyncServer.zip
ARG POSTGRES_JDBC_VERSION=9.4.1212.jre6

RUN yum -y install unzip
RUN mkdir -p $LOCAL_ROOT && \
    curl --fail --retry 5 $ALFSS_URL -o $LOCAL_ROOT/AlfrescoSyncServer.zip && \
    unzip AlfrescoSyncServer.zip -d $LOCAL_ROOT && \
    curl -L -o $LOCAL_ROOT/sync/service-sync/postgresljdbc.jar http://jdbc.postgresql.org/download/postgresql-$POSTGRES_JDBC_VERSION.jar
COPY sync-start.sh /usr/local/desktop-sync
COPY config.yml /usr/local/desktop-sync
RUN chmod +x /usr/local/desktop-sync/sync-start.sh

ENTRYPOINT ["/usr/local/desktop-sync/sync-start.sh"]
