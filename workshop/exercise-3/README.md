# Exercise 3 - Deploy Guestbook with Istio Proxy 

The Guestbook application consists of a web front end, Redis master for storage, and replicated set of Redis slaves. We will deploy that application on Kubernetes with Istio manual injection.

## Clone the repo
In your terminal, run
  ```sh
  git clone https://github.com/IBM/guestbook.git
  ```
Then go to the example:
  ```sh
  cd v2
  ```
  
## Create Redis backend
The Redis backend provides the persistance service to the application. It consists of the master and slave modules. We will create the controllers and service for both master and slave.
  ``` sh
  kubectl create -f redis-master-deployment.yaml
  kubectl create -f redis-master-service.yaml
  kubectl create -f redis-slave-deployment.yaml
  kubectl create -f redis-slave-service.yaml
  ```
To verify the installation, first we check the controllers:
  ```sh
  kubectl get deployment
  NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  redis-master   1         1         1            1           5d
  redis-slave    2         2         2            2           5d
  ```
Then we check the service:
  ```sh
  kubectl get svc
  NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
  redis-master   ClusterIP      172.21.85.39    <none>          6379/TCP       5d
  redis-slave    ClusterIP      172.21.205.35   <none>          6379/TCP       5d
  ```
Lastly we check the pods:
  ```sh
  kubectl get pods
  NAME                            READY     STATUS    RESTARTS   AGE
  redis-master-4sswq              1/1       Running   0          5d
  redis-slave-kj8jp               1/1       Running   0          5d
  redis-slave-nslps               1/1       Running   0          5d
  ```
## Install guestbook app with Istio

  ```sh
 kubectl apply -f <(istioctl kube-inject -f ../v1/guestbook-deployment.yaml --debug)
 kubectl apply -f <(istioctl kube-inject -f guestbook-deployment.yaml --debug)
  ```
These commands will inject the Istio envoy sidecar into the guestbook pods, as well as deploying the guestbook app on to the K8s cluster. Here we have two versions of deployments, a new version (`v2`) in the current directory, and a previous version (`v1`) in a sibling directory. They will be used by future sections to showcase the Istio traffic routing capabilities.
  
Next, we'll create the guestbook service.

    kubectl create -f guestbook-service.yaml

To verify the service is up:

    kubectl get svc
    NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
    guestbook      LoadBalancer   172.21.36.181   169.61.37.140   80:32149/TCP   5d

To verify the pods are up:

    kubectl get pods
    NAME                            READY     STATUS    RESTARTS   AGE
    guestbook-v1-89cd4b7c7-frscs    2/2       Running   0          5d
    guestbook-v1-89cd4b7c7-jn224    2/2       Running   0          5d
    guestbook-v1-89cd4b7c7-m7hmd    2/2       Running   0          5d
    guestbook-v2-56d98b558c-7fvd5   2/2       Running   0          5d
    guestbook-v2-56d98b558c-dshkh   2/2       Running   0          5d
    guestbook-v2-56d98b558c-mzbxk   2/2       Running   0          5d
    
Notice that each guestbook pods have 2 containers in it. One is the guestbook container, the other is the Envoy proxy sidecar.

## Add the analyzer service
The Watson Tone analyzer service will detect the tone in the words and convert them to corresponding emoticons. 

1. Deploy Watson Tone analyzer service.

    ```console
      bx service create tone_analyzer lite my-tone-analyzer-service
      bx service key-create my-tone-analyzer-service myKey
      bx service key-show my-tone-analyzer-service myKey
    ```

2. Find our the username and password from the prior step and update analyzer-deployment.yaml with the username and password in the env var section.  

3. Deploy the analyzer service.  The analyzer service talks to Watson Tone analyzer to help analyze the tone of a message. 

    ```console
      kubectl apply -f <(istioctl kube-inject -f analyzer-deployment.yaml --debug)
    ```
4. Apply the egress:

    ```console
      kubectl apply -f analyzer-egress.yaml
    ```
And that concludes the installation of the guestbook application.
