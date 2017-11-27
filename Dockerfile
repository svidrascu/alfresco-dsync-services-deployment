FROM quay.io/alfresco/alfresco-base-java:0.1

ENV LOCAL_ROOT=/usr/local/desktop-sync
ARG ALFSS_URL=https://nightlybuilds.alfresco.com/DesktopSync/LATEST/5.x-Distribution-Zip/AlfrescoSyncServer.zip
ARG POSTGRES_JDBC_VERSION=9.4.1212.jre6
COPY sync-start.sh config.yml ./

RUN yum -y -q -e 0 install unzip && \
    mkdir -p "${LOCAL_ROOT}" && \
    cp sync-start.sh config.yml ${LOCAL_ROOT} && \
    cd "${LOCAL_ROOT}" && \
    zipname="AlfrescoSyncServer.zip" && \
    curl --fail --retry 5 "${ALFSS_URL}" -o "${zipname}" && \
    unzip -qq "${zipname}" "sync/service-sync/*" "sync/licenses/*" -d . && \
    rm -f "${zipname}" && \
    curl -L -o $LOCAL_ROOT/sync/service-sync/postgresljdbc.jar http://jdbc.postgresql.org/download/postgresql-$POSTGRES_JDBC_VERSION.jar && \
    yum -y -q -e 0 remove unzip  && \
    chmod +x ${LOCAL_ROOT}/sync-start.sh

WORKDIR "${LOCAL_ROOT}"
ENTRYPOINT ["${LOCAL_ROOT}/sync-start.sh"]
