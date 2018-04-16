## Istio Ingress controller 

The components deployed on the service mesh by default are not exposed outside the cluster. External access to individual services so far has been provided by creating an external load balancer on each service.

A Kubernetes Ingress rule can be created that routes external requests through the Istio Ingress controller to the backing services. In a Kubernetes environment, Istio uses Kubernetes Ingress Resources to configure ingress behavior.

### Configure Guestbook Ingress routes with the Istio Ingress controller

1. Configure the guestbook default route with the Istio Ingress controller.

    ```sh
    kubectl apply -f guestbook-ingress.yaml
    ```
    You can see how this works by having Kubernetes describe the Ingress resource:

    ```sh
    kubectl describe ingress

    Name:             guestbook-ingress
    Namespace:        default
    Address:          169.61.37.141
    Default backend:  default-http-backend:80 (<none>)
    Rules:
    Host  Path  Backends
    ----  ----  --------
    *     
        /.*   guestbook:80 (<none>)
    Annotations:
    Events:  <none>

    ```

2. Get the external IP of the Istio Ingress controller. Here is another common command to get the IP address of the ingress.

    ```sh
    kubectl get service istio-ingress -n istio-system

    NAME            TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
    istio-ingress   LoadBalancer   172.21.126.221   169.61.37.141   80:31432/TCP,443:31753/TCP   3h
    ```

Now you can access the guestbook via http://169.61.37.141(change it to your EXTERNAL-IP).

## IBM Frontdoor
**This feature only works for paid accounts.**  

IBM Front Door is IBM container service Ingress controller which is an enhancement of the Kubernetes Ingress Controller. The Front Door provides IBM Cloud users with a secure, reliable and scalable high performance network stack to distribute incoming traffic to their applications running on the IBM Cloud Platform. The additional features are simply configured as additional annotations in the yaml file and are deployed when configured. Some features supported by the Front Door Ingress Controller are:
* Unique subdomain with a free certificate
* DNS resolution for the Subdomain
* SSL (TLS) termination
* Layer 7 routing
* Load Balance to an application running on IBM container service
* Load Balance to an external application (specifying external endpoints)
* Highly Available Ingress Controller

In this exercise we'll create an Front Door Ingress. 

### Deploy the Front Door Ingress

Let's first check the IBM Ingress secret and subdomain information.
```sh
bx cs cluster-get guestbook

...
Ingress subdomain:	guestbook-242887.us-east.containers.mybluemix.net
```
Please modify the `guestbook-frontdoor.yaml` `host` attribute with the url accordingly.
After that, run
```sh
kubectl apply -f guestbook-frontdoor.yaml
```

To examine the Ingress, run
```sh
kubectl get ingress guestbook-ingress  -o yaml
```
```sh
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
#  annotations:
#    kubernetes.io/ingress.class: istio
  name: guestbook-ingress
spec:
  rules:
    - host: guestbook.us-south.containers.mybluemix.net
      http:
        paths:
          - path: /
            backend:
              serviceName: guestbook
              servicePort: 3000
```
The difference is IBM Front door ingress extended the Kubernetes ingress features by providing DNS entry to the service! Now you can now access the app via http://[guestbook].us-east.containers.mybluemix.net

## References: 
[Kubenetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)           
[Istio Ingress](https://istio.io/docs/tasks/traffic-management/ingress.html)
