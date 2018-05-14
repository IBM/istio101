# Exercise 3 - Deploy guestbook with Istio Proxy

The Guestbook application is a sample application for users to leave comments. It consists of a web front end, Redis master for storage, and replicated set of Redis slaves. We will also integrate the application with Watson tone analyzer service that detects the sentiment in user's comments and reply with emoticons. Here are the steps to deploy the application on your Kubernets cluster:

### Download the guestbook app
1. Open your preferred terminal and download the guestbook app from GitHub.
  ```sh
  git clone https://github.com/IBM/guestbook.git
  ```
2. Navigate into the app directory.
  ```sh
  cd guestbook/v2
  ```

### Create a Redis database
The Redis database is a service that you can use to persist the data of your app. The Redis database comes with a master and slave modules.

1. Create the Redis controllers and services for both the master and the slave.
  ``` sh
  kubectl create -f redis-master-deployment.yaml
  kubectl create -f redis-master-service.yaml
  kubectl create -f redis-slave-deployment.yaml
  kubectl create -f redis-slave-service.yaml
  ```
2. Verify that the Redis controllers for the master and the slave are created.
  ```sh
  kubectl get deployment
  NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  redis-master   1         1         1            1           5d
  redis-slave    2         2         2            2           5d
  ```
3. Verify that the Redis services for the master and the slave are created.
  ```sh
  kubectl get svc
  NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
  redis-master   ClusterIP      172.21.85.39    <none>          6379/TCP       5d
  redis-slave    ClusterIP      172.21.205.35   <none>          6379/TCP       5d
  ```
4. Verify that the Redis pods for the master and the slave are up and running.
  ```sh
  kubectl get pods
  NAME                            READY     STATUS    RESTARTS   AGE
  redis-master-4sswq              1/1       Running   0          5d
  redis-slave-kj8jp               1/1       Running   0          5d
  redis-slave-nslps               1/1       Running   0          5d
  ```
## Sidecar injection

In Kubernets, a sidecar is a utility container in the Pod and its purpose is to support the main container. For Istio to work, Envoy proxies must be deployed as sidecars to each pod of the deployment. There are two ways of injecting the Istio sidecar into a pod: manually using istioctl CLI tool or automatically using the Istio Initializer. In this exercise, we will use the manual injection. Manual injection modifies the controller configuration, e.g. deployment. It does this by modifying the pod template spec such that all pods for that deployment are created with the injected sidecar. 

## Install the guestbook app with Manual sidecar injection

  ```sh
 kubectl apply -f <(istioctl kube-inject -f ../v1/guestbook-deployment.yaml --debug)
 kubectl apply -f <(istioctl kube-inject -f guestbook-deployment.yaml --debug)
  ```
These commands will inject the Istio envoy sidecar into the guestbook pods, as well as deploy the guestbook app on to the K8s cluster. Here we have two versions of deployments, a new version (`v2`) in the current directory, and a previous version (`v1`) in a sibling directory. They will be used in future sections to showcase the Istio traffic routing capabilities.
  
Next, we'll create the guestbook service.

1. Inject the Istio envoy sidecar into the guestbook pods and deploy the guestbook app on to the Kubernetes cluster.
```sh
kubectl apply -f <(istioctl kube-inject -f ../v1/guestbook-deployment.yaml --debug)
kubectl apply -f <(istioctl kube-inject -f guestbook-deployment.yaml --debug)
```
These commands create two versions of deployments: a new version (`v2`) in the current directory, and a previous version (`v1`) in a sibling directory. They will be used in future exercises to showcase the Istio traffic routing capabilities.

2. Create the guestbook service.
```sh
kubectl create -f guestbook-service.yaml
```

3. Verify that the service was created.
```sh
kubectl get svc
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
guestbook      LoadBalancer   172.21.36.181   169.61.37.140   80:32149/TCP   5d
```

4. Verify that the pods are up and running.
```sh
kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
guestbook-v1-89cd4b7c7-frscs    2/2       Running   0          5d
guestbook-v1-89cd4b7c7-jn224    2/2       Running   0          5d
guestbook-v1-89cd4b7c7-m7hmd    2/2       Running   0          5d
guestbook-v2-56d98b558c-7fvd5   2/2       Running   0          5d
guestbook-v2-56d98b558c-dshkh   2/2       Running   0          5d
guestbook-v2-56d98b558c-mzbxk   2/2       Running   0          5d
```

Note that each guestbook pod has 2 containers in it. One is the guestbook container, and the other is the envoy proxy sidecar.

### Add the analyzer service
The Watson Tone analyzer service detects the tone from the words that users enter into the guestbook app. The tone is converted to the corresponding emoticons. 

Before you begin: 
- Use `bx target --cf` or `bx target -o ORG -s SPACE` to set the Cloud Foundry org and space where you want to provision the service. 

    > Note that you should use `bx target --cf` or `bx target -o ORG -s SPACE` to set the Cloud Foundry Org and Space before calling `bx service create...`. 

   1. Create the Watson Tone analyzer service in your space. 
      ```console
      bx service create tone_analyzer lite my-tone-analyzer-service
      ```
      
   2. Create a service key for the service. 
      ```console
      bx service key-create my-tone-analyzer-service myKey
      ```
   
   3. Show the service key that you created and note the **password** and **username**. 
      ```console
      bx service key-show my-tone-analyzer-service myKey
      ```

2. Open the `analyzer-deployment.yaml` and delete the `#` from the `env var` section to un-comment the username and password fields.

3. Add the username and password that you retrieved earlier and save your changes.

4. Deploy the analyzer pods and service. The analyzer service talks to the Watson Tone analyzer to help analyze the tone of a message.
   ```console
   kubectl apply -f analyzer-deployment.yaml --debug
   kubectl apply -f analyzer-service.yaml
   ```
   
5. Create an egress rule to allow the analyzer service to access the Watson service. The rule is defined in [istio101/workshop/plans](https://github.com/IBM/istio101/tree/master/workshop/plans) and is not part of the guestbook app files:
    ```console
      kubectl apply -f analyzer-egress.yaml
    ```
Great! With you guestbook up and running, you can now expose the service mesh with the Istio Ingress controller. 

#### [Continue to Exercise 4 - Expose the service mesh with the Istio Ingress controller](../exercise-4/README.md)
