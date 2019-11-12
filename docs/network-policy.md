## Sync Service network policy

In order to have the network policy applied, the `networkpolicysetting` parameter must be set to true, in [values.yaml](../helm/alfresco-sync-service/values.yaml).
If you run locally, with Minikube, the cluster should be started, with parameter  `--network-plugin=cni`.

The following diagram describes the communication between pods. The arrow indicates that a pod can communicate with another one in a direction, that means that communication in reverse order is not possible, unless an arrow is shown in the opposite direction.

![diagram](network_policy.png)

Sync service defines a set of 4 policies, a policy for each of the following pod:
* [syncservice](../helm/alfresco-sync-service/templates/Rule_04-sync-network-policy-syncservice.yaml)
* [repository](../helm/alfresco-sync-service/templates/Rule_03-sync-network-policy-repository.yaml)
* [database](../helm/alfresco-sync-service/templates/Rule_01-sync-network-policy-database.yaml)
* [activemq](../helm/alfresco-sync-service/templates/Rule_02-sync-network-policy-activemq.yaml)
