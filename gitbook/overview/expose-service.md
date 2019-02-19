# Exercise 5 - Expose the service mesh with the Istio Ingress Gateway

The components deployed on the service mesh by default are not exposed outside the cluster. External access to individual services so far has been provided by creating an external load balancer or node port on each service.

An Ingress Gateway resource can be created to allow external requests through the Istio Ingress Gateway to the backing services.

### Expose the Guestbook app with Ingress Gateway

1. Configure the guestbook default route with the Istio Ingress Gateway. The `guestbook-gateway.yaml` file is in this repository (istio101) in the `workshop/plans` directory.

    ```shell
    kubectl create -f guestbook-gateway.yaml
    ```

2. Get the **EXTERNAL-IP** of the Istio Ingress Gateway.

    ```shell
    kubectl get service istio-ingressgateway -n istio-system
    ```
    Output:
    ```shell
    NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                       AGE
    istio-ingressgateway   LoadBalancer   172.21.254.53    169.6.1.1       80:31380/TCP,443:31390/TCP,31400:31400/TCP    1m
    2d
    ```

3. Make note of the external IP address that you retrieved in the previous step, as it will be used to access the Guestbook app in later parts of the course. You can create an environment variable called $INGRESS_IP with your IP address.

    Example:
    ```
    export INGRESS_IP=169.6.1.1
    ```

## (Optional) Connect Istio Ingress Gateway to the IBM Cloud Kubernetes Service Provided Domain Name

**Note:** This task requires a standard cluster.

Standard IBM Cloud Kubernetes Clusters can expose applications deployed within your cluster using a Kubernetes Ingress application load balancer (ALB). IBM Cloud Kubernetes Service automatically creates a highly available ALB for your cluster and assigns a unique public route to it in the format: <cluster_name>.<region_or_zone>.containers.appdomain.cloud.

The Ingress resource provides IBM Cloud users with a secure, reliable, and scalable network stack to distribute incoming network traffic to apps in IBM Cloud. You can enhance the IBM-provided Ingress application load balancer by adding annotations. Learn more about [Ingress for IBM Cloud Kubernetes Service](https://console.bluemix.net/docs/containers/cs_ingress.html#ingress).

To use this IBM provided DNS for the Guestbook app, you must set the Kubernetes Ingress application load balancer (ALB) to route traffic to the Istio Ingress Gateway.

1. Let's first check the IBM Ingress subdomain information.

    ```shell
    ibmcloud cs cluster-get <cluster_name>
    ```
    Output:
    ```shell
    Ingress subdomain:	mycluster.us-east.containers.appdomain.cloud
    ```

2. Prepend `guestbook.` to the subdomain that you retrieved in the previous step. This new url will serve as `host` in the `guestbook-frontdoor.yaml` file, which you can find and edit in the `istio101/workshop/plans` directory.

    The file should now look something like this:

    ```yaml
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: guestbook-ingress
      namespace: istio-system
    spec:
      rules:
        - host: guestbook.mycluster.us-east.containers.appdomain.cloud
          http:
            paths:
              - path: /
                backend:
                  serviceName: istio-ingressgateway
                  servicePort: 80
    ```

3. Create the Ingress with the IBM-provided subdomain.

    ```shell
    kubectl apply -f guestbook-frontdoor.yaml
    ```

4. List the details for your Ingress.

    ```shell
    kubectl get ingress guestbook-ingress -n istio-system -o yaml
    ```

    Example output:
    ```yaml
      apiVersion: extensions/v1beta1
      kind: Ingress
      metadata:
        annotations:
          kubectl.kubernetes.io/last-applied-configuration: |
            {"apiVersion":"extensions/v1beta1","kind":"Ingress","metadata":{"annotations":{},"name":"guestbook-ingress","namespace":"istio-system"},"spec":{"rules":[{"host":"guestbook.mycluster.us-east.containers.appdomain.cloud","http":{"paths":[{"backend":{"serviceName":"istio-ingressgateway","servicePort":80},"path":"/"}]}}]}}
        creationTimestamp: 2018-11-28T19:02:59Z
        generation: 6
        name: guestbook-ingress
        namespace: istio-system
        resourceVersion: "1438905"
        selfLink: /apis/extensions/v1beta1/namespaces/istio-system/ingresses/guestbook-ingress
        uid: 38f0c0bd-f340-11e8-b97a-4ef94ed74105
      spec:
        rules:
        - host: guestbook.mycluster.us-east.containers.appdomain.cloud
          http:
            paths:
            - backend:
                serviceName: istio-ingressgateway
                servicePort: 80
              path: /
    ```

5. Make note of the IBM-provided subdomain as it will be used to access your Guestbook app in later parts of the course.

    Example:
    ```
    http://guestbook.mycluster.us-east.containers.appdomain.cloud
    ```

Congratulations! You extended the base Ingress features by providing a DNS entry to the Istio service.

## References:
[Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
[Istio Ingress](https://istio.io/docs/tasks/traffic-management/ingress.html)