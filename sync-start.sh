#!/bin/bash
set -e

readonly LOCAL_ROOT="${LOCAL_ROOT:-/usr/local/desktop-sync}"
readonly JAR_LOCATION=$LOCAL_ROOT/sync/service-sync
readonly MAX_JAVA_HEAP_SIZE="${MAX_JAVA_HEAP_SIZE:-2G}"
readonly ENABLE_JMX_REMOTE="${ENABLE_JMX_REMOTE:-false}"
readonly JMX_REMOTE_PORT="${JMX_REMOTE_PORT:-0800}"
readonly JMX_RMI_HOSTNAME="${JMX_RMI_HOSTNAME:-localhost}"
readonly JMX_REMOTE_RMI_PORT="${JMX_REMOTE_RMI_PORT:-50801}"
readonly ENABLE_JMX_REMOTE_AUTHENTICATION="${ENABLE_JMX_REMOTE_AUTHENTICATION:-true}"
readonly DB_HOST="${DB_HOST:-localhost}"
readonly ACTIVEMQ_HOST="${ACTIVEMQ_HOST:-activemq}"
readonly ACTIVEMQ_PORT="${ACTIVEMQ_PORT:-61616}"
readonly REPO_HOST="${REPO_HOST:-localhost}"
readonly REPO_PORT="${REPO_PORT:-8080}"
readonly OVERRIDE_CONFIG="${OVERRIDE_CONFIG:-true}"
readonly JMX_CONF="-Dcom.sun.management.jmxremote=$ENABLE_JMX_REMOTE"
readonly JARS=$(find "$JAR_LOCATION" -name "*.jar" | paste -sd ":" -)

if [ "${OVERRIDE_CONFIG}" == "true" ]; then
    sed_string="s~@@DB_HOST@@~$DB_HOST~g;"
    sed_string+="s~@@REPO_HOST@@~$REPO_HOST~g;"
    sed_string+="s~@@REPO_PORT@@~$REPO_PORT~g;"
    sed_string+="s~@@ACTIVEMQ_HOST@@~$ACTIVEMQ_HOST~g;"
    sed_string+="s~@@ACTIVEMQ_PORT@@~$ACTIVEMQ_PORT~g"

    sed -i "${sed_string}" "$LOCAL_ROOT"/config.yml
    mv -f "$LOCAL_ROOT"/config.yml "$JAR_LOCATION"/config.yml
fi

cd "$JAR_LOCATION" || exit

java -Xmx"$MAX_JAVA_HEAP_SIZE" "$JMX_CONF" -Djava.io.tmpdir="$JAR_LOCATION" -cp "$JARS" org.alfresco.service.sync.dropwizard.SyncService server config.yml
