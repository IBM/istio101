# Exercise 5 - Expose the service mesh with the Istio Ingress Gateway

The components deployed on the service mesh by default are not exposed outside the cluster. External access to individual services so far has been provided by creating an external load balancer or node port on each service.

An Ingress Gateway resource can be created to allow external requests through the Istio Ingress Gateway to the backing services.

### Expose the Guestbook app with Ingress Gateway

1. If you have a paid cluster:

    a. Configure the guestbook default route with the Istio Ingress Gateway. The `guestbook-gateway.yaml` file is in this repository (istio101) in the `workshop/plans` directory.

    ```shell
    kubectl create -f guestbook-gateway.yaml
    ```

    b. Get the **EXTERNAL-IP** of the Istio Ingress Gateway.

    ```shell
    kubectl get service istio-ingressgateway -n istio-system
    ```
    Output:
    ```shell
    NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                       AGE
    istio-ingressgateway   LoadBalancer   172.21.254.53    169.6.1.1       80:31380/TCP,443:31390/TCP,31400:31400/TCP    1m
    2d
    ```

    c. Make note of the external IP address that you retrieved in the previous step, as it will be used to access the Guestbook app in later parts of the course. You can create an environment variable called $INGRESS_IP with your IP address.

    Example:
    ```
    export INGRESS_IP=169.61.37.141
    ```

2. If you have a lite cluster:

    a. Configure the guestbook default route with the Istio Ingress Gateway.

    ```shell
    kubectl create -f guestbook-gateway.yaml
    ```

    b. Now check the node port of the ingress.

    ```shell
    kubectl get svc istio-ingressgateway -n istio-system
    ```
    Output:
    ```shell
    NAME            TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
    istio-ingress   LoadBalancer                    *              80:31702/TCP,443:32290/TCP   10d
    ```
    Get the Public IP of your cluster.
    ```shell
    ibmcloud cs workers <cluster_name>
    ```
    Output:
    ```shell
    ID             Public IP      Private IP      Machine Type        State    Status   Zone    Version
    kube-xxx       169.60.87.20   10.188.80.69    u2c.2x4.encrypted   normal   Ready    wdc06   1.9.7_1510*
    ```

    The node port in above sample output is `169.60.87.20:31702`.

    c. Make note of the IP and node port that you retrieved in the previous step as it will be used to access the Guestbook app in later parts of the course. You can create an environment variable called $INGRESS_IP with your IP address.

    Example:
    ```
    export INGRESS_IP=169.60.72.58:31702
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
    Ingress subdomain:	mycluster.us-east.containers.mybluemix.net
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

#### [Continue to Exercise 6 - Traffic Management](../exercise-6/README.md)
