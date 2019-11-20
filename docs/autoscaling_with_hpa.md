## Autoscaling Sync service via Horizontal Pod Autoscaling (HPA).
When deciding on an approach to autoscaling the Alfresco Sync Service with Kubernetes, the main consideration is to increase and decrease the service capacity the without disrupting users.

HPA allows new pods to be created without restarting the existing ones and HPA is a mature autoscaling method and has comprehensive documentation available. 

See the [Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale) for more details.
 
### Autoscaling based on CPU and memory usage

Kubernetes autoscales Sync service by comparing the current resources usage against a predefined target average usage, for both CPU and memory. These  settings can be changed in values.yaml:
```
  horizontalPodAutoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 3
    CPU:
      enabled: true
      targetUtilization: 80
    memory:
      enabled: true
      targetUtilization: 60  


```

The settings above allow Sync autoscaling to be triggered based on either CPU or memory or both. Default is both.

In order for HPA to work the resource **requests** must be specified upfront . These can be configured via values.yaml:
```
  resources:
    requests:
      memory: "2000Mi"
      cpu: 2
    limits:
      memory: "2000Mi"
      cpu: 2

```


### Cluster setup to enable HPA

Before using HPA the Kubernetes cluster must be configured to:
* Create new physical nodes when there are unscheduled pods. 
* Enable collecting resource usage metrics from all the pods via a metrics-server.
If using Minikube the metrics-server can be enabled with the following command:
```
minikube addons enable metrics-server
minikube addons open heapster

```
All the prerequisites above are documented  [https://caylent.com/kubernetes-autoscaling/](https://caylent.com/kubernetes-autoscaling/).

**Important!** When using KOPS additional properties need to specified in order to use the metrics-server.  Please refer to: [Kubernetes Reference materials](https://github.com/kubernetes-incubator/metrics-server/issues/212) for more information.

### Kubernetes flags to configure up and downscaling behaviour
The are two properties that configure the HPA for the entire cluster.

Parameter | Description | Default
--- | --- | ---
`horizontal-pod-autoscaler-sync-period` | The interval that has to pass between resource usage is checked by the HPA | 15 seconds
`horizontal-pod-autoscaler-downscale-stabilization` | The time it takes before downscaling occurs. This is useful to prevent thrashing, when metrics vary quickly. See [Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) for details |  5 minutes

For **memory** we need to specify a lower threshold(60) in **targetUtilization**, which allows metrics to be queried, before the pod is killed by Kubernetes when it reaches memory limits (Terminated: OOMKilled).


### Verify your HPA configuration using Apache bench

One method for testing that your auto-scaling configuration works is by using [Apache bench](https://httpd.apache.org/docs/2.4/programs/ab.html). 
Sample usage of Apache Bench on the /POST sync api exposed by Sync service.

```
 abs -k -n 1000000 -c 100 -p post.data -T application/json -H "Authorization: Basic YWRtaW46YWRtaW4="  https://ent-featureappsrepo656-68.dev.alfresco.me/syncservice/api/-default-/private/alfresco/versions/1/subscribers/9a7d97a4-afb2-4059-b498-071458358a2d/subscriptions/9a91fef7-518b-4b6a-9651-55a3f57cd564/sync

```
where *post.data* has the following content:

```
  {"changes":[],"clientVersion":"1.1"}
```

**Important notes**:
- Use **abs** instead of **ab** when testing against https endpoints.
- Make sure that the subscription is created with some pending events to be consumed.
