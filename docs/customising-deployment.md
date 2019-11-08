# Customising your deployment

Sync Service image location: `quay.io/repository/alfresco/service-sync`

Sync Service [tags](https://quay.io/repository/alfresco/service-sync?tag=latest&tab=tags)

For Helm charts usage, edit the image tags in the  [values.yaml](../helm/alfresco-sync-service/values.yaml) file.  

```
project
│
└───helm
    │  
    └───alfresco-sync-service
        |
        └───templates
        |
        └───Chart.yaml
        |
        └───requirements.yaml
        │
        └───values.yaml
```

**Note:**
* Use the recommended image tags, as not all combinations work together.
* You can modify the values provided in [values.yaml](../helm/alfresco-sync-service/values.yaml) when deploying the Helm chart. For example, you can run:
```bash
helm install alfresco-incubator/alfresco-sync-service --set syncservice.image.tag="yourTag"
```
[values.yaml - Configuration explaned](../README.md#configuration)
    

* You can run ```eval $(minikube docker-env)``` to switch to your Minikube Docker environment on Mac OS X.

### K8s deployment customization guidelines

 All the customizations (including major configuration changes) should be done inside the Docker image, resulting in the creation of a new image with a new tag. This approach allows changes to be tracked in the source code (Dockerfile) and rolling updates to the deployment in the K8s cluster.

 The helm chart configuration customization should only include environment-specific changes (for example DB server connection properties) or altered Docker image names and tags. The configuration changes applied via "--set" will only be reflected in the configuration stored in k8s cluster, a better approach would be to have those in VCS.
