# Alfresco Sync Service Deployment with Helm using Minikube

## Install ACS on Minikube

See this page for instructions to start the Minikube VM, install the Nginx ingress and ACS chart: [https://github.com/Alfresco/acs-deployment/blob/master/docs/helm-deployment-minikube.md](https://github.com/Alfresco/acs-deployment/blob/master/docs/helm-deployment-minikube.md)


##### Important notes:
1. You may need to add the following nginx annotation in the *ingress-repository.yaml* and *ingress-share.yaml* if you get automatically redirected to https
  

```
nginx.ingress.kubernetes.io/ssl-redirect: "false"
```

2. By default Sync Service expects an ACS release named 'acs'. Install the ACS chart with *--name acs*


```
helm install alfresco-content-services --set externalProtocol="http" --set externalHost="192.168.99.101" --set externalPort="31098" --name acs
```

3. Make sure that the property *repository.image.repository* in values.yaml points to an ACS image with the Sync Service AMP installed. 

   Instructions on how to build an ACS image with a custom AMP [HERE](https://github.com/Alfresco/acs-packaging/blob/master/docs/create-custom-image-using-existing-docker-image.md#applying-amps-that-dont-require-additional-configuration-easy)
  
   Make sure to use the following command in order to use the Minikube Docker engine. Please beware that the command is only valid in the terminal where it was executed.
   
```
eval $(minikube docker-env)
```
   
4. Specify the *dsync.service.uris* property in values.yaml property *repository.environment.JAVA_OPTS*.

   The IP:PORT combination is the *externalhost:externalPort* specified in the *helm install* command above.
e.g.

```
repository:  
  environment:
    JAVA_OPTS: "      
      -Ddsync.service.uris=http://192.168.99.101:31098/syncservice"
```



## Install the quay-registry-secret

Inside the cluster, Kubernetes needs the right credentials to download images from quay.io.
These are stored in a Secret.
See this page on instructions to create a secret named *quay-registry-secret*

[https://github.com/Alfresco/alfresco-dbp-deployment#docker-registry-pull-secrets](https://github.com/Alfresco/alfresco-dbp-deployment#docker-registry-pull-secrets)

## Install the Sync Service chart (from source code)

* Clone this repository

```
git clone git@git.alfresco.com:alfresco-services/alfresco-dsync-services-deployment.git
```

* Update the dependencies(brings the Postgresql Chart)

```
cd helm/alfresco-sync-service
helm dependency update
```

* Install the Sync service chart

```
cd ..
helm install alfresco-sync-service --name syncservice
```

* Test that Sync service is up and running


```
curl http://192.168.99.101:31098/syncservice/healthcheck
```

See the *Install ACS on Minikube* Step on how to obtain the *192.168.99.101:31098* (IP:PORT) combination.