# Exercise 3 - Deploy Guestbook with Istio Proxy

The Guestbook application consists of a web front end, Redis master for storage, and replicated set of Redis slaves. We will deploy that application on Kubernetes with Istio manual injection.

### Clone the repo
In your terminal, run
  ```sh
  git clone https://github.com/IBM/guestbook.git
  ```
Then go to the example:
  ```sh
  cd v2
  ```

### Create Redis backend
The Redis backend provides the persistence service to the application. It consists of the master and slave modules.

1. Create the controllers and service for both master and slave.
  ``` sh
  kubectl create -f redis-master-deployment.yaml
  kubectl create -f redis-master-service.yaml
  kubectl create -f redis-slave-deployment.yaml
  kubectl create -f redis-slave-service.yaml
  ```
2. Check the controllers.
  ```sh
  kubectl get deployment
  NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  redis-master   1         1         1            1           5d
  redis-slave    2         2         2            2           5d
  ```
3. Check the service.
  ```sh
  kubectl get svc
  NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
  redis-master   ClusterIP      172.21.85.39    <none>          6379/TCP       5d
  redis-slave    ClusterIP      172.21.205.35   <none>          6379/TCP       5d
  ```
4. Check the pods.
  ```sh
  kubectl get pods
  NAME                            READY     STATUS    RESTARTS   AGE
  redis-master-4sswq              1/1       Running   0          5d
  redis-slave-kj8jp               1/1       Running   0          5d
  redis-slave-nslps               1/1       Running   0          5d
  ```
### Install guestbook app with Istio

1. Inject the Istio envoy sidecar into the guestbook pods and deploy the guestbook app on to the Kubernetes cluster.
```sh
kubectl apply -f ../v1/guestbook-deployment.yaml --debug
kubectl apply -f guestbook-deployment.yaml --debug
```
These commands create two versions of deployments: a new version (`v2`) in the current directory, and a previous version (`v1`) in a sibling directory. They will be used in future exercises to showcase the Istio traffic routing capabilities.

2. Create the guestbook service.
```sh
kubectl create -f guestbook-service.yaml
```

3. Verify the service.
```sh
kubectl get svc
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
guestbook      LoadBalancer   172.21.36.181   169.61.37.140   80:32149/TCP   5d
```

4. Verify the pods.
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

### Add the analyzer service
The Watson Tone analyzer service will detect the tone in the words and convert them to corresponding emoticons.

1. Deploy Watson Tone analyzer service.

    > Note that you should use `bx target --cf` or `bx target -o ORG -s SPACE` to set the Cloud Foundry Org and Space before calling `bx service create...`

    ```console
    bx service create tone_analyzer lite my-tone-analyzer-service
    bx service key-create my-tone-analyzer-service myKey
    bx service key-show my-tone-analyzer-service myKey
    ```

2. In the output, note the "password" and "username".

3. Open analyzer-deployment.yaml. In the `env var` section, delete the `#` to un-comment the username and password fields.

4. Add the username and password values and save the file.

5. Deploy the analyzer pods and service. The analyzer service talks to Watson Tone analyzer to help analyze the tone of a message.

    ```console
      kubectl apply -f analyzer-deployment.yaml --debug
      kubectl apply -f analyzer-service.yaml
    ```
6. Apply an egress rule to allow the analyzer service to access the Watson service. The rule definition is defined in [istio101/workshop/plans](https://github.com/IBM/istio101/tree/master/workshop/plans) and is not part of the guestbook application files:
    ```console
      kubectl apply -f analyzer-egress.yaml
    ```
And that concludes the installation of the guestbook application.

#### [Continue to Exercise 4 - Expose the service mesh with the Istio Ingress controller](../exercise-4/README.md)
