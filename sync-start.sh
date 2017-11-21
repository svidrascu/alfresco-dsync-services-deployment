#!/bin/bash
set -x
      ### Fill in these bits:
      DESKTOPSYNC_URL=https://nightlybuilds.alfresco.com/DesktopSync/LATEST/5.x-Distribution-Zip/AlfrescoSyncServer.zip
      POSTGRES_JDBC_URL=https://jdbc.postgresql.org/download/postgresql-9.4.1212.jre6.jar
      LOCAL_ROOT=/usr/local/desktop-sync
       mkdir -p $LOCAL_ROOT
      JAR_LOCATION=$LOCAL_ROOT/sync/service-sync
      SYNC_JAR_VERSION=2.2-SNAPSHOT
      SYNC_JAR_FILE=service-sync-$SYNC_JAR_VERSION.jar
      DB_CONNECTOR_JAR_FILE=$JAR_LOCATION/postgresql.jar
      SYNC_TMP_DIR=$JAR_LOCATION
      MAX_JAVA_HEAP_SIZE=2G
      NAME="alfresco-syncservice"
      PID_FILE=$JAR_LOCATION/syncservice.pid
      ### Start of JMX config ###
      ### true | false
      ENABLE_JMX_REMOTE=false
      JMX_REMOTE_PORT=50800
      JMX_RMI_HOSTNAME=localhost
      JMX_REMOTE_RMI_PORT=50801
      ### true | false
      ENABLE_JMX_REMOTE_AUTHENTICATION=true
      ### If you enable JMX_REMOTE_AUTHENTICATION, then, set the next two properties (ie.PASSWORD_FILE, ACCESS_FILE)
      ### Make sure to restict (e.g. sudo chmode 600 jmx.password) the JMX_PASSWORD_FILE to the specified USER.
      JMX_PASSWORD_FILE=$JAR_LOCATION/jmx/jmx.password.properties
      JMX_ACCESS_FILE=$JAR_LOCATION/jmx/jmx.access.properties
      ### true | false
      ### Caution - if you set 'ENABLE_JMX_REMOTE_AUTHENTICATION' and 'ENABLE_JMX_REMOTE_SSL' to false, any remote user who knows
      ### (or guesses) your port number and host name will be able to monitor and control your applications and platform.
      ENABLE_JMX_REMOTE_SSL=true
      ### If you enable JMX_REMOTE_AUTHENTICATION, then, set the next six properties
      ### Make sure to restict (e.g. sudo chmode 600 jmx.password) the JMX_PASSWORD_FILE to the specified USER.
      ### Keystore details
      JMX_KEYSTORE=/$JAR_LOCATION/sync.keystore
      JMX_KEYSTORE_PASSWORD=alfresco
      JMX_KEYSTORE_TYPE=JCEKS
      ### Truststore details
      JMX_TRUSTSTORE=$JAR_LOCATION/sync.truststore
      JMX_TRUSTSTORE_PASSWORD=alfresco
      JMX_TRUSTSTORE_TYPE=JCEKS
      ### End of JMX config ###

      ### downloading sync distribution zip
      if [ -f AlfrescoSyncServer.zip ]; then
        echo "found: sync-dist-5.x-1.1.zip"
      else
        echo "downloading: sync-dist-5.x-1.1.zip ... $desksync_url"
        curl --fail --retry 5 $DESKTOPSYNC_URL -o AlfrescoSyncServer.zip
      fi
      if [ ! -d sync-dist ]; then
            unzip AlfrescoSyncServer.zip -d $LOCAL_ROOT
            echo $LOCAL_ROOT
      fi
      if [ -f $JAR_LOCATION/postgres.jar ]; then
        echo "found: Postgres JDBC driver"
      else
        echo "downloading: Postgres JDBC driver ... $postgres_jdbc_url"
        curl --fail --retry 5 $POSTGRES_JDBC_URL -o $JAR_LOCATION/postgresql.jar
      fi

      if [ "$1" == "true" ]; then
        echo "IS IT $1 "
           cp -rf $LOCAL_ROOT/config.yml $JAR_LOCATION
      fi

      JMX_CONF="-Dcom.sun.management.jmxremote=$ENABLE_JMX_REMOTE"
      JMX_SECURITY_CONF=""
      if [ $ENABLE_JMX_REMOTE = true ]; then
      	JMX_CONF="$JMX_CONF -Djava.rmi.server.hostname=$JMX_RMI_HOSTNAME -Dcom.sun.management.jmxremote.port=$JMX_REMOTE_PORT -Dcom.sun.management.jmxremote.rmi.port=$JMX_REMOTE_RMI_PORT -Dcom.sun.management.jmxremote.authenticate=$ENABLE_JMX_REMOTE_AUTHENTICATION -Dcom.sun.management.jmxremote.ssl=$ENABLE_JMX_REMOTE_SSL"
      	if [ $ENABLE_JMX_REMOTE_AUTHENTICATION = true ]; then
      		JMX_SECURITY_CONF="-Dcom.sun.management.jmxremote.access.file=$JMX_ACCESS_FILE -Dcom.sun.management.jmxremote.password.file=$JMX_PASSWORD_FILE"
      	fi
      	if [ $ENABLE_JMX_REMOTE_SSL = true ]; then
      		JMX_SECURITY_CONF="$JMX_SECURITY_CONF -Djavax.net.ssl.keyStore=$JMX_KEYSTORE -Djavax.net.ssl.keyStorePassword=$JMX_KEYSTORE_PASSWORD -Djavax.net.ssl.keyStoreType=$JMX_KEYSTORE_TYPE -Djavax.net.ssl.trustStore=$JMX_TRUSTSTORE -Djavax.net.ssl.trustStoreType=$JMX_TRUSTSTORE_TYPE -Djavax.net.ssl.trustStorePassword=$JMX_TRUSTSTORE_PASSWORD"
      	fi
      	JMX_CONF="$JMX_CONF $JMX_SECURITY_CONF"
      fi

      PGREP_STRING="$SYNC_JAR_FILE"
      START_CMD="\"cd $JAR_LOCATION;java -Xmx$MAX_JAVA_HEAP_SIZE $JMX_CONF -Djava.io.tmpdir=$SYNC_TMP_DIR -cp $DB_CONNECTOR_JAR_FILE:$SYNC_JAR_FILE org.alfresco.service.sync.dropwizard.SyncService server config.yml > $JAR_LOCATION/sync.log 2>&1 &\""

      log_success_msg() {
      	echo "$*"
      	logger "$_"
      }

      log_failure_msg() {
      	echo "$*"
      	logger "$_"
      }

      check_proc() {
      	RET="$(pgrep -u $USER -f ${PGREP_STRING})"
      	if [ -n "$RET" ]; then
      		return 0
      	else
      		return 1
      	fi
      }

      start_script() {

      	check_proc
      	if [ $? -eq 0 ]; then
      		PID="$(pgrep -u $USER -f ${PGREP_STRING})"
      		log_success_msg "$NAME with pid '$PID' is already running."
      		exit 0
      	fi
      	  eval "sh -c  $START_CMD"
      	# Sleep for a while to see if anything cries
      	sleep 5

      	check_proc
      	if [ $? -eq 0 ]; then
      		PID="$(pgrep -u $USER -f ${PGREP_STRING})"
      		log_success_msg "Started $NAME with pid $PID."
      		echo $PID >"${PID_FILE}"
      	else
      		log_failure_msg "Error starting $NAME."
      		# exit 1
      	fi
      }
      start_script
      exit 0
