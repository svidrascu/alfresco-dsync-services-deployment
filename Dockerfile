FROM quay.io/alfresco/alfresco-base-java:0.1


ENV LOCAL_ROOT=/usr/local/desktop-sync
ARG ALFSS_URL=https://nightlybuilds.alfresco.com/DesktopSync/LATEST/5.x-Distribution-Zip/AlfrescoSyncServer.zip
ARG POSTGRES_JDBC_VERSION=9.4.1212.jre6

RUN yum -y -q -e 0 install unzip
RUN mkdir -p $LOCAL_ROOT && \
    cd "${LOCAL_ROOT}" && \
    zipname="AlfrescoSyncServer.zip" && \
    curl --fail --retry 5 "${ALFSS_URL}" -o "${zipname}" && \
    unzip -qq "${zipname}" "sync/service-sync/*" "sync/licenses/*" -d . && \
    rm -f "${zipname}"
RUN curl -L -o $LOCAL_ROOT/sync/service-sync/postgresljdbc.jar http://jdbc.postgresql.org/download/postgresql-$POSTGRES_JDBC_VERSION.jar
COPY sync-start.sh /usr/local/desktop-sync
COPY config.yml /usr/local/desktop-sync
RUN chmod +x /usr/local/desktop-sync/sync-start.sh
RUN yum -y -q -e 0 remove unzip

WORKDIR "${LOCAL_ROOT}"
ENTRYPOINT ["/usr/local/desktop-sync/sync-start.sh"]
