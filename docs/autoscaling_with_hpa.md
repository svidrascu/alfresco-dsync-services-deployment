## Autoscaling Sync service via Horizontal Pod Autoscaling(HPA). More details about HPA in the [Kubernetes docs.](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale)


* ### Autoscaling based on CPU and memory usage

Kubernetes autoscales Sync service by comparing the current resources usage against a predefined target average usage, for both CPU and memory. These settings can be changed in values.yaml:
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


* ### Cluster setup to enable HPA

Before using HPA one needs to configure the Kubernetes cluster to:
* Create new physical nodes when there are unscheduled pods. 
* Enable collecting resource usage metrics from all the pods via a metrics-server.
All the prerequisites above are documented nicely [https://caylent.com/kubernetes-autoscaling/](https://caylent.com/kubernetes-autoscaling/).

**Beware!**. If using KOPS, the metrics-server doesn't work out of the box. Some additional flags need to specified. More details here: https://github.com/kubernetes-incubator/metrics-server/issues/212
The above settings have already been done for our development kops cluster. See [REPO-4489](https://issues.alfresco.com/jira/browse/REPO-4489).


* ### Kubernetes flags to configure up and downscaling behaviour

The are a couple of flags that configure the HPA for the entire cluster.


 **--horizontal-pod-autoscaler-sync-period** - defaults to 15 seconds. The interval that has to pass between resource usage is checked by the HPA.

For this reason, for the **memory** we had to specify a lower threshold(60) for the **targetAverageUtilization**. We need to allow the metrics to be queried, before the pod is killed by Kubernetes due to reaching memory limits(the infamous message you might see in the dashboard. Terminated: OOMKilled).


 **--horizontal-pod-autoscaler-downscale-stabilization** - defaults to 5 minutes. The time it takes before downscaling occurs. This is useful to prevent thrashing, when metrics vary very fast. Again more details in the [Kubernetes official docs](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).

* ### Quick way to test HPA using Apache bench

Quickest way,so far, to test that autoscaling works is by using [Apache bench](https://httpd.apache.org/docs/2.4/programs/ab.html). 
Sample usage of Apache Bench on the /POST sync api exposed by Sync service.

```
 abs -k -n 1000000 -c 100 -p post.data -T application/json -H "Authorization: Basic YWRtaW46YWRtaW4="  https://ent-featureappsrepo656-68.dev.alfresco.me/syncservice/api/-default-/private/alfresco/versions/1/subscribers/9a7d97a4-afb2-4059-b498-071458358a2d/subscriptions/9a91fef7-518b-4b6a-9651-55a3f57cd564/sync

```
where *post.data* has the follwing content:

```
  {"changes":[],"clientVersion":"1.1"}
```

**Important nodes**:
- Use **abs** instead of **ab** when testing against https endpoints.
- Make sure that the subscription is created with some pending events to be consumed.
