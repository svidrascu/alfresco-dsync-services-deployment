#!/bin/bash

# deletes the created pods in order to test that kubernetes creates a new valid pods

namespace=${bamboo_inject_namespace}
echo "delete sync service resources from $namespace namespace"

kubectl delete pod $(kubectl get pod --namespace=$namespace | grep alfresco-sync-service | awk '{print $1}') \
  --namespace=$namespace

kubectl delete pod $(kubectl get pod --namespace=$namespace | grep postgresql-syncservice | awk '{print $1}') \
  --namespace=$namespace

sleep 60
