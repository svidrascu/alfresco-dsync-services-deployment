# Sync service deployment using Kubernetes and Helm.

This project contains the code for starting the Sync service product with Kubernetes.

### Deployment options

* [Deploy in Minikube](./docs/deployment_minikube.md)

* [Deploy in AWS EKS](https://github.com/Alfresco/acs-deployment/blob/master/docs/helm-deployment-aws_eks.md)

* [Customising your deployment](./docs/customising-deployment.md)

* [Autoscaling using HPA(Horizontal Pod Autoscaling)](./docs/autoscaling_with_hpa.md)

### Uninstalling Sync Service chart

```
helm del syncservice --purge
```

### Configuration

The following table lists the configurable parameters of the Sync Service chart and their default values.

Parameter | Description | Default
--- | --- | ---
`syncservice.image.repository`|location of the sync service image|`quay.io/alfresco/service-sync`
`syncservice.image.tag`|the tag of the sync service image [TAGS](https://quay.io/repository/alfresco/service-sync?tag=latest&tab=tags)|`latest`
`syncservice.image.internalPort`|internal port for communication with sync service|`9090`
`syncservice.environment.EXTRA_JAVA_OPTS`|allows to be added properties dynamically. This variable is used in the config map objects|``
`syncservice.service`|defines the name, type, external port for sync service|
`livenessProbe` and `readinessProbe`| defines when sync service pod is started, for the first time and when sync service pod is restarted|livenessProbe:<br/>&nbsp;initialDelaySeconds: 150<br/>&nbsp;periodSeconds: 30<br/>&nbsp;timeoutSeconds: 10<br/>readinessProbe:<br/> &nbsp;initialDelaySeconds: 20<br/>&nbsp;periodSeconds: 10<br/>&nbsp;failureThreshold: 12<br/>&nbsp;timeoutSeconds: 10
`syncservice.horizontalPodAutoscaling`|[explaned here](./docs/autoscaling_with_hpa.md)|horizontalPodAutoscaling:<br/>&nbsp;enabled: true<br/>&nbsp;minReplicas: 1<br/>&nbsp;maxReplicas: 3<br/>&nbsp;CPU:<br/>&nbsp;&nbsp;enabled: true<br/>&nbsp;&nbsp;targetAverageUtilization: 80<br/>&nbsp;memory:<br/>&nbsp;&nbsp;enabled: true
`activemq.external`|Enable the use of an externally provisioned database|`false`
`repository.host`|repository host|`alfresco-cs-repository`
`postgresql.enabled`|If true, install the postgresql chart alongside Alfresco Sync service|`true`
`networkpolicysetting`|[explaned here](./docs/network-policy.md)|`true`

### Sync Service Helm Chart versioning guide

Based on [Semantic Versioning](https://semver.org)

As an addition to Semantic Versioning the following list describes Sync Service specific extensions:
* Once a chart has been released, the contents of that version MUST NOT be modified. Any modifications MUST be released as a new version. Stable chart version starts with 1.0.0
* The major version of a chart is defined by major or minor Sync Service release version. For instance: chart 1.0.0 (Sync Service 3.1.2), chart 2.0.0 (Sync Service 3.2.0), chart 3.0.0 (Sync Service 3.3.0), chart 4.0.0 (Sync Service 3.4.0), chart 5.0.0 (Sync Service 3.5.0).
* The minor version must be incremented if Sync Service version is incremented within a Service Pack. For instance: chart 1.0.0 (Sync Service 3.1.2), chart 1.1.0 (Sync Service 3.1.3), chart 2.0.0 (Sync Service 3.2.0), chart 2.1.0 (Sync Service 3.2.1)
* The patch version of the chart must be incremented if Sync Service version is incremented within a HotFix or the chart was modified. For instance: chart 1.0.0 (Sync Service 3.1.2), chart 1.0.1 (Sync Service 3.1.2, chart modifications), chart 1.0.2 (Sync Service 3.1.2.1), chart 1.0.3 (Sync Service 3.1.2.2 and chart modifications), chart 1.0.4 (Sync Service 3.1.2.3, chart modifications).
* The "appVersion" label must always specify the exact Sync Service release version, like 3.1.2, 3.2.0, 3.1.2.1, 3.1.2.2. If the "appVersion" was incremented between charts, downgrading to a previous chart is not possible.


### Stable Helm Chart Releases

|Chart version|Sync Service version|
|:---:|:---:|
|0.2.0    |3.1.1|
|1.0.0-RC1|3.1.2-RC2|
|1.0.0-RC3|3.1.2-RC4|
|1.0.0|3.1.2|
|2.0.0|3.2.0|
|2.0.1|3.2.0|
