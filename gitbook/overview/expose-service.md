# Expose with Istio Gateway

The components deployed on the service mesh by default are not exposed outside the cluster. External access to individual services so far has been provided by creating an external load balancer or node port on each service.

An Ingress Gateway resource can be created to allow external requests through the Istio Ingress Gateway to the backing services.

![](../.gitbook/assets/image%20%286%29.png)

### Expose the Guestbook app with Ingress Gateway

1. Configure the guestbook default route with the Istio Ingress Gateway. The `guestbook-gateway.yaml` file is in this repository \(istio101\) in the `workshop/plans` directory.

   ```text
    kubectl create -f guestbook-gateway.yaml
   ```

2. Get the **EXTERNAL-IP** of the Istio Ingress Gateway.

   ```text
    kubectl get service istio-ingressgateway -n istio-system
   ```

   Output:

   ```text
    NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                       AGE
    istio-ingressgateway   LoadBalancer   172.21.254.53    169.6.1.1       80:31380/TCP,443:31390/TCP,31400:31400/TCP    1m
    2d
   ```

3. Make note of the external IP address that you retrieved in the previous step, as it will be used to access the Guestbook app in later parts of the course. You can create an environment variable called $INGRESS\_IP with your IP address.

   Example:

   ```text
    export INGRESS_IP=169.6.1.1
   ```

4. You could look at your guestbook service and and see what port its running on. You can access your service using  `INGRESS_IP/INGRESS_PORT` where INGRESS\_PORT is the port of your service.

## References:

[Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) [Istio Ingress](https://istio.io/docs/tasks/traffic-management/ingress.html)

