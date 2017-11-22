#!/bin/bash
set -x
      ### Fill in these bits:
      LOCAL_ROOT="${LOCAL_ROOT:-/usr/local/desktop-sync}"
      JAR_LOCATION=$LOCAL_ROOT/sync/service-sync
      SYNC_JAR_FILE="service-sync-*.jar"
      SYNC_TMP_DIR=$JAR_LOCATION
      MAX_JAVA_HEAP_SIZE="${MAX_JAVA_HEAP_SIZE:-2G}"
      NAME="alfresco-syncservice"
      PID_FILE=$JAR_LOCATION/syncservice.pid
      ### Start of JMX config ###
      ### true | false
      ENABLE_JMX_REMOTE="${ENABLE_JMX_REMOTE:-false}"
      JMX_REMOTE_PORT="${JMX_REMOTE_PORT:-0800}"
      JMX_RMI_HOSTNAME="${JMX_RMI_HOSTNAME:-localhost}"
      JMX_REMOTE_RMI_PORT="${JMX_REMOTE_RMI_PORT:-50801}"
      ### true | false
      ENABLE_JMX_REMOTE_AUTHENTICATION="${ENABLE_JMX_REMOTE_AUTHENTICATION:-true}"
      ### If you enable JMX_REMOTE_AUTHENTICATION, then, set the next two properties (ie.PASSWORD_FILE, ACCESS_FILE)
      ### Make sure to restict (e.g. sudo chmode 600 jmx.password) the JMX_PASSWORD_FILE to the specified USER.
      JMX_PASSWORD_FILE=$JAR_LOCATION/jmx/jmx.password.properties
      JMX_ACCESS_FILE=$JAR_LOCATION/jmx/jmx.access.properties
      ### true | false
      ### Caution - if you set 'ENABLE_JMX_REMOTE_AUTHENTICATION' and 'ENABLE_JMX_REMOTE_SSL' to false, any remote user who knows
      ### (or guesses) your port number and host name will be able to monitor and control your applications and platform.
      # ENABLE_JMX_REMOTE_SSL="${ENABLE_JMX_REMOTE_SSL:-true}"
      ### If you enable JMX_REMOTE_AUTHENTICATION, then, set the next six properties
      ### Make sure to restict (e.g. sudo chmode 600 jmx.password) the JMX_PASSWORD_FILE to the specified USER.
      ### Keystore details
      # JMX_KEYSTORE=/$JAR_LOCATION/sync.keystore
      # JMX_KEYSTORE_PASSWORD="${JMX_KEYSTORE_PASSWORD:-alfresco}"
      # JMX_KEYSTORE_TYPE="${JMX_KEYSTORE_TYPE:-JCEKS}"
      ### Truststore details
      # JMX_TRUSTSTORE=$JAR_LOCATION/sync.truststore
      # JMX_TRUSTSTORE_PASSWORD="${JMX_TRUSTSTORE_PASSWORD:-alfresco}"
      # JMX_TRUSTSTORE_TYPE=JCEKS
      ### End of JMX config ###
      DB_HOST="${DB_HOST:-localhost}"
      OVERRIDE_CONFIG="${OVERRIDE_CONFIG:-true}"

      sed -i "s~@@HOST@@~$DB_HOST~g" $LOCAL_ROOT/config.yml

      if [ "${OVERRIDE_CONFIG}" == "true" ]; then
          cp -rf $LOCAL_ROOT/config.yml $JAR_LOCATION
      fi

      JMX_CONF="-Dcom.sun.management.jmxremote=$ENABLE_JMX_REMOTE"
      # JMX_SECURITY_CONF=""
      # if [ $ENABLE_JMX_REMOTE = true ]; then
      # 	JMX_CONF="$JMX_CONF -Djava.rmi.server.hostname=$JMX_RMI_HOSTNAME -Dcom.sun.management.jmxremote.port=$JMX_REMOTE_PORT -Dcom.sun.management.jmxremote.rmi.port=$JMX_REMOTE_RMI_PORT -Dcom.sun.management.jmxremote.authenticate=$ENABLE_JMX_REMOTE_AUTHENTICATION -Dcom.sun.management.jmxremote.ssl=$ENABLE_JMX_REMOTE_SSL"
      # 	if [ $ENABLE_JMX_REMOTE_AUTHENTICATION = true ]; then
      # 		JMX_SECURITY_CONF="-Dcom.sun.management.jmxremote.access.file=$JMX_ACCESS_FILE -Dcom.sun.management.jmxremote.password.file=$JMX_PASSWORD_FILE"
      # 	fi
      # 	if [ $ENABLE_JMX_REMOTE_SSL = true ]; then
      # 		JMX_SECURITY_CONF="$JMX_SECURITY_CONF -Djavax.net.ssl.keyStore=$JMX_KEYSTORE -Djavax.net.ssl.keyStorePassword=$JMX_KEYSTORE_PASSWORD -Djavax.net.ssl.keyStoreType=$JMX_KEYSTORE_TYPE -Djavax.net.ssl.trustStore=$JMX_TRUSTSTORE -Djavax.net.ssl.trustStoreType=$JMX_TRUSTSTORE_TYPE -Djavax.net.ssl.trustStorePassword=$JMX_TRUSTSTORE_PASSWORD"
      # 	fi
      # 	JMX_CONF="$JMX_CONF $JMX_SECURITY_CONF"
      # fi

      PGREP_STRING="$SYNC_JAR_FILE"
      JARS=$(find $JAR_LOCATION -name "*.jar" | paste -sd ":" -)
      START_CMD="\"cd $JAR_LOCATION;java -Xmx$MAX_JAVA_HEAP_SIZE $JMX_CONF -Djava.io.tmpdir=$SYNC_TMP_DIR -cp $JARS org.alfresco.service.sync.dropwizard.SyncService server config.yml > $JAR_LOCATION/sync.log 2>&1 &\""

      log_success_msg() {
      	echo "$*"
      	logger "$_"
      }

      log_failure_msg() {
      	echo "$*"
      	logger "$_"
      }

      check_proc() {
      	RET="$(pgrep -f ${PGREP_STRING})"
      	if [ -n "$RET" ]; then
      		return 0
      	else
      		return 1
      	fi
      }

      start_script() {

      	check_proc
      	if [ $? -eq 0 ]; then
      		PID="$(pgrep -f ${PGREP_STRING})"
      		log_success_msg "$NAME with pid '$PID' is already running."
      		exit 0
      	fi
      	  eval "sh -c  $START_CMD"
      	# Sleep for a while to see if anything cries
      	sleep 5

      	check_proc
      	if [ $? -eq 0 ]; then
      		PID="$(pgrep -f ${PGREP_STRING})"
      		log_success_msg "Started $NAME with pid $PID."
      		echo $PID >"${PID_FILE}"
      	else
      		log_failure_msg "Error starting $NAME."
      		# exit 1
      	fi
      }
      start_script
      exit 0
