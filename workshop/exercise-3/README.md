# Exercise 3 - Deploy the Guestbook app with Istio Proxy

The Guestbook app is a sample app for users to leave comments. It consists of a web front end, Redis master for storage, and replicated set of Redis slaves. We will also integrate the app with Watson Tone Analyzer that detects the sentiment in user's comments and replies with emoticons. Here are the steps to deploy the app on your Kubernetes cluster:

### Download the Guestbook app
1. Open your preferred terminal and download the Guestbook app from GitHub.
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
  redis-master-4sswq              2/2       Running   0          5d
  redis-slave-kj8jp               2/2       Running   0          5d
  redis-slave-nslps               2/2       Running   0          5d
  ```

## Sidecar injection

In Kubernetes, a sidecar is a utility container in the pod, and its purpose is to support the main container. For Istio to work, Envoy proxies must be deployed as sidecars to each pod of the deployment. There are two ways of injecting the Istio sidecar into a pod: manually using istioctl CLI tool or automatically using the Istio Initializer. In this exercise, we will use the automatic injection which is enabled when you installed Istio.

## Install the Guestbook app

1. Deploy the Guestbook app in the Kubernetes cluster with automatic Istio Envoy sidecar injection.
```sh
kubectl apply -f ../v1/guestbook-deployment.yaml
kubectl apply -f guestbook-deployment.yaml
```
Here we have two versions of deployments, a new version (`v2`) in the current directory, and a previous version (`v1`) in a sibling directory. They will be used in future sections to showcase the Istio traffic routing capabilities.

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
**Note: For Lite clusters, the external ip will not be avaiable. That is expected.**

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

Note that each guestbook pod has 2 containers in it. One is the guestbook container, and the other is the Envoy proxy sidecar.

### Add Watson Tone Analyzer
Watson Tone Analyzer detects the tone from the words that users enter into the Guestbook app. The tone is converted to the corresponding emoticons.

1. Create Watson Tone Analyzer in your account.
      ```console
      ibmcloud resource service-instance-create my-tone-analyzer-service tone-analyzer lite us-east
      ```

3. Create a service key for the service.
      ```console
      ibmcloud resource service-key-create myKey Editor --instance-name my-tone-analyzer-service
      ```

4. Show the service key that you created and note the **url** and **apikey**.
      ```console
      ibmcloud resource service-key myKey
      ```

5. Open the `analyzer-deployment.yaml` and delete the `#` from the `env var` section to un-comment the _url_ and _apikey_ fields.

6. Add the _url_ (if different from the default) and _apikey_ that you retrieved earlier and save your changes.

7. Deploy the analyzer pods and service. The analyzer service talks to Watson Tone Analyzer to help analyze the tone of a message.
   ```console
   kubectl apply -f analyzer-deployment.yaml
   kubectl apply -f analyzer-service.yaml
   ```
   Great! With your Guestbook up and running, you can now expose the service mesh with the Istio Ingress Gateway.


#### [Continue to Exercise 4 - Telemetry](../exercise-4/README.md)
