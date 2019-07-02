#!/bin/bash

# temporary script
# rewrites the acs image with the one which contains the sync service amp

declare library_path

library_path="acs-k8s-cluster/scripts"

source "${library_path}/common.func.sh"

EDITION="enterprise"

namespace=$(get_namespace)

log_info "Change ACS installed image"

kubectl set image deployment "${bamboo_inject_release_name_acs}-alfresco-cs-repository" \
  alfresco-content-services=quay.io/alfresco/alfresco-content-repository:feature-APPSREPO-656_include_sync-6.2.0-SNAPSHOT \
  --namespace=$namespace
