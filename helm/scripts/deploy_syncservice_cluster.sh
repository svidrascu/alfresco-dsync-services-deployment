#!/bin/bash

# deploy the sync service app

declare library_path

library_path="acs-k8s-cluster/scripts"
source "${library_path}/common.func.sh"
EDITION="enterprise"

printVarSummary

# returns "sync" followed by a random 3 character sequesnce
# it's used for naming the sync service release
get_new_release_name_sync(){
  random_string=$(openssl rand 200 | LC_CTYPE=C tr -dc "[:lower:]" | head -c 3)
  echo "sync-${random_string}"
}

log_info "Sync service helm dependency update"
pushd ${bamboo_build_working_directory}/deployment/helm/alfresco-sync-service
helm dependency update
popd

namespace=$(get_namespace)

log_info "Sync Service helm install"
log_info "The namespace is $namespace"
log_info "The ACS prefix installation is ${bamboo_inject_release_name_acs}"

echo "namespace=$namespace" >> ${library_path}/namespace.properties
log_info "Writing the namespace $namespace to namespace.properties"

# Get the sync service release name
release_name_sync_service=$(get_new_release_name_sync)

base_url=$namespace.dev.alfresco.me
echo "url=$base_url" >> deployment/url.properties
log_info "base url: $base_url"

helm install ${bamboo_build_working_directory}/deployment/helm/alfresco-sync-service \
  --name $release_name_sync_service \
  --namespace=$namespace \
  --set contentServices.installationName=${bamboo_inject_release_name_acs} \
  --set postgresql.persistence.subPath="$namespace/alfresco-sync-services/database-data" \
  --set replicaCount=2

log_info "Installed sync service pods"
kubectl --namespace=$namespace get pods | grep "$release_name_sync_service-"
