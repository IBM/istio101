# Exercise 5 - Expose the service mesh with the Istio Ingress Gateway

The components deployed on the service mesh by default are not exposed outside the cluster. External access to individual services so far has been provided by creating an external load balancer or node port on each service.

An Ingress Gateway resource can be created to allow external requests through the Istio Ingress Gateway to the backing services. 

### Expose the Guestbook app with Ingress Gateway if you have paid cluster

1. Configure the guestbook default route with the Istio Ingress Gateway. The `guestbook-gateway.yaml` file is in this repository (istio101) in the following directory: `workshop/plans/guestbook-gateway.yaml `

    ```sh
    kubectl create -f guestbook-gateway.yaml
    ```

2. Get the **EXTERNAL-IP** of the Istio Ingress Gateway.

    ```sh
    kubectl get service istio-ingressgateway -n istio-system

    NAME            TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
istio-ingressgateway       LoadBalancer   172.21.254.53    169.6.1.1   80:31380/TCP,443:31390/TCP,31400:31400/TCP                            2d
    ```

3. Make note of the external IP address that you retrieved in the previous step as it will be used to access the Guestbook app in later parts of the course.
   Example:
   ```
   http://169.61.37.141
   ```

### Expose the Guestbook app with Ingress Gateway if you have lite cluster
1. Configure the guestbook default route with the Istio Ingress Gateway.

    ```sh
    kubectl create -f guestbook-gateway.yaml
    ```

2. Now check the node port of the ingress.
    ```sh
    kubectl get svc istio-ingressgateway -n istio-system

    NAME            TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
    istio-ingress   LoadBalancer                    *              80:31702/TCP,443:32290/TCP   10d


    bx cs workers <cluster_name>

    ID             Public IP      Private IP      Machine Type        State    Status   Zone    Version   
    kube-xxx       169.60.87.20   10.188.80.69    u2c.2x4.encrypted   normal   Ready    wdc06   1.9.7_1510*   

    ```
 The node port in above sample output is `169.60.87.20:31702`.

 3. Make note of the IP and node port that you retrieved in the previous step as it will be used to access the Guestbook app in later parts of the course.
   Example:
   ```
   http://169.60.72.58:31702
   ```

## **DO NOT RUN THIS, please continue to [exercise-6](../exercise-6/README.md)** (Optional) Set up the Istio Ingress Gateway to work with IBM Cloud Kubernetes Service

**Note:** This task requires a standard cluster.

To have an IBM-provided DNS for the Guestbook app, you must set up the Istio Ingress Gateway to route traffic to the Kubernetes Ingress application load balancer (ALB).

The IBM Ingress service provides IBM Cloud users with a secure, reliable, and scalable network stack to distribute incoming network traffic to apps in IBM Cloud. You can enhance the IBM-provided Ingress application load balancer by adding annotions. Learn more about [Ingress for IBM Cloud Kubernetes Service](https://console.bluemix.net/docs/containers/cs_ingress.html#ingress).

1. Let's first check the IBM Ingress subdomain information.
```sh
bx cs cluster-get <cluster_name>

...
Ingress subdomain:	guestbook-242887.us-east.containers.mybluemix.net
```

2. Add the subdomain that you retrieved in the previous step as `host` in the `guestbook-frontdoor.yaml` file.

3. Create the Ingress with the IBM-provided subdomain.
   ```sh
   kubectl apply -f guestbook-frontdoor.yaml
   ```

4. List the details for your Ingress.
   ```sh
   kubectl get ingress guestbook-ingress  -o yaml
   ```
   Example output:
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

5. Make note of the IBM-provided subdomain as it will be used to access your Guestbook app in later parts of the course.
   Example:
   ```
   http://[guestbook].us-east.containers.mybluemix.net
   ```

Congratulations! You extended the base Ingress features by providing a DNS entry to the Istio service.

## References:
[Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)           
[Istio Ingress](https://istio.io/docs/tasks/traffic-management/ingress.html)

#### [Continue to Exercise 6 - Traffic Management](../exercise-6/README.md)
