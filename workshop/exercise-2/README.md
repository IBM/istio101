# Module 2 - Installing Istio on IBM Cloud Container Service
In this module, you install Istio,  connect the microservices in the service mesh, and verify the app deployment. 

## Lesson 1: Download and install Istio

1. Either download Istio directly from [https://github.com/istio/istio/releases](https://github.com/istio/istio/releases) or get the latest version by using curl:
```
curl -L https://git.io/getLatestIstio | sh -
```
2. Extract the installation files.
3. Add the `istioctl` client to your PATH. For example, run the following command on a MacOS or Linux system:
```
export PATH=$PWD/istio-0.4.0/bin:$PATH
```
4. Change the directory to the Istio file location.
```
cd filepath/istio-0.4.0
```
5. Install Istio on the Kubernetes cluster. Istio is deployed in the Kubernetes namespace `istio-system`.
```
kubectl apply -f install/kubernetes/istio.yaml
```
**Note**: If you need to enable mutual TLS authentication between sidecars, you can install the `istio-auth` file instead: `kubectl apply -f install/kubernetes/istio-auth.yaml`
6. Ensure that the Kubernetes services `istio-pilot`, `istio-mixer`, and `istio-ingress` are fully deployed before you continue.
```
kubectl get svc -n istio-system
```
```
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                                                            AGE
istio-ingress   LoadBalancer   {[service_private_IP]}   {[public_IP]}   80:31176/TCP,443:30288/TCP                                         2m
istio-mixer     ClusterIP      {[service_private_IP]}     <none>           9091/TCP,15004/TCP,9093/TCP,9094/TCP,9102/TCP,9125/UDP,42422/TCP   2m
istio-pilot     ClusterIP      {[service_private_IP]}    <none>           15003/TCP,443/TCP                                                  2m
```
7. Ensure the corresponding pods `istio-pilot-*`, `istio-mixer-*`, `istio-ingress-*`, and `istio-ca-*` are also fully deployed before you continue.
```
kubectl get pods -n istio-system
```
```
istio-ca-3657790228-j21b9           1/1       Running   0          5m
istio-ingress-1842462111-j3vcs      1/1       Running   0          5m
istio-pilot-2275554717-93c43        1/1       Running   0          5m
istio-mixer-2104784889-20rm8        2/2       Running   0          5m
```

Congratulations! You successfully installed Istio into your cluster. Next, deploy the Guestbook sample app into your cluster.


## Lesson 2: Deploy the Guestbook app

The app's microservices include a product web page, details, reviews (with several versions of the review microservice), and ratings. You can find all files that are used in this example in your Istio installation's `samples/Guestbook` directory.

When you deploy Guestbook, Envoy sidecar proxies are injected as containers into your app microservices' pods before the microservice pods are deployed. Istio uses an extended version of the Envoy proxy to mediate all inbound and outbound traffic for all microservices in the service mesh. For more about Envoy, see the [Istio documentation](https://istio.io/docs/concepts/what-is-istio/overview.html#envoy).

1. Deploy the Guestbook app. The `kube-inject` command adds Envoy to the `Guestbook.yaml` file and uses this updated file to deploy the app. When the app microservices deploy, the Envoy sidecar is also deployed in each microservice pod.

   ```
   kubectl apply -f <(istioctl kube-inject -f samples/Guestbook/kube/Guestbook.yaml)
   ```
2. Ensure that the microservices and their corresponding pods are deployed:

   ```
   kubectl get svc
   ```
   
   ```
   NAME                       CLUSTER-IP   EXTERNAL-IP   PORT(S)              AGE
   details                    {[internal_cluster_IP]}    <none>        9080/TCP             6m
   kubernetes                 {[internal_cluster_IP]}     <none>        443/TCP              30m
   productpage                {[internal_cluster_IP]}   <none>        9080/TCP             6m
   ratings                    {[internal_cluster_IP]}    <none>        9080/TCP             6m
   reviews                    {[internal_cluster_IP]}   <none>        9080/TCP             6m
   ```
   
   ```
   kubectl get pods
   ```
   
   ```
   NAME                                        READY     STATUS    RESTARTS   AGE
   details-v1-1520924117-48z17                 2/2       Running   0          6m
   productpage-v1-560495357-jk1lz              2/2       Running   0          6m
   ratings-v1-734492171-rnr5l                  2/2       Running   0          6m
   reviews-v1-874083890-f0qf0                  2/2       Running   0          6m
   reviews-v2-1343845940-b34q5                 2/2       Running   0          6m
   reviews-v3-1813607990-8ch52                 2/2       Running   0          6m
   ```
3. To verify the application deployment, get the public address for your cluster. Run the following command to get the Ingress IP and port of your cluster:
```
kubectl get ingress
```
The output looks like the following:
```
NAME      HOSTS     ADDRESS          PORTS     AGE
gateway   *         {[public_IP]}   80        3m
```
The resulting Ingress address for this example is `169.48.221.218:80`. Export the address as the gateway URL with the following command. You will use the gateway URL in the next step to access the Guestbook product page.
```
export GATEWAY_URL={[public_IP]}:80
```
4. Curl the `GATEWAY_URL` variable to check that Guestbook is running. A `200` response means that Guestbook is running properly with Istio.
```
curl -I http://$GATEWAY_URL/productpage
```
5. In a browser, navigate to `http://$GATEWAY_URL/productpage` to view the Guestbook web page.

Congratulations! You successfully deployed the Guestbook sample app with Istio Envoy sidecars.



