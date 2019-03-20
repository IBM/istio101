# Exercise 2 - Installing Istio on IBM Cloud Kubernetes Service
In this module, you download and install Istio.

1.  Either download Istio directly from [https://github.com/istio/istio/releases](https://github.com/istio/istio/releases) or get the latest version by using curl:

    ```shell
    curl -L https://git.io/getLatestIstio | sh -
    ```

2. Change the directory to the Istio file location.

    ```shell
    cd istio-<version-number>
    ```

3. Add the `istioctl` client to your PATH. 

    ```shell
    export PATH=$PWD/bin:$PATH
    ```

4. Install Istio’s Custom Resource Definitions via kubectl apply, and wait a few seconds for the CRDs to be committed in the kube-apiserver:

    ```shell
    for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
    ```

5. Now let's install Istio demo profile into the `istio-system` namespace in your Kubernetes cluster:

    ```shell
    kubectl apply -f install/kubernetes/istio-demo.yaml
    ```

6. Ensure that the `istio-*` Kubernetes services are deployed before you continue.

    ```shell
    kubectl get svc -n istio-system
    ```
    Sample output:
    ```shell
    NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                                                                                                                                      AGE
    grafana                  ClusterIP      172.21.135.33    <none>           3000/TCP                                                                                                                                     35s
    istio-citadel            ClusterIP      172.21.242.77    <none>           8060/TCP,15014/TCP                                                                                                                           34s
    istio-egressgateway      ClusterIP      172.21.20.200    <none>           80/TCP,443/TCP,15443/TCP                                                                                                                     35s
    istio-galley             ClusterIP      172.21.246.214   <none>           443/TCP,15014/TCP,9901/TCP                                                                                                                   36s
    istio-ingressgateway     LoadBalancer   172.21.151.128   169.60.168.234   80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:32268/TCP,15030:30743/TCP,15031:32200/TCP,15032:31341/TCP,15443:31059/TCP,15020:31039/TCP   35s
    istio-pilot              ClusterIP      172.21.243.70    <none>           15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                                       34s
    istio-policy             ClusterIP      172.21.144.137   <none>           9091/TCP,15004/TCP,15014/TCP                                                                                                                 34s
    istio-sidecar-injector   ClusterIP      172.21.230.192   <none>           443/TCP                                                                                                                                      33s
    istio-telemetry          ClusterIP      172.21.213.11    <none>           9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                                       34s
    jaeger-agent             ClusterIP      None             <none>           5775/UDP,6831/UDP,6832/UDP                                                                                                                   29s
    jaeger-collector         ClusterIP      172.21.187.128   <none>           14267/TCP,14268/TCP                                                                                                                          29s
    jaeger-query             ClusterIP      172.21.89.210    <none>           16686/TCP                                                                                                                                    30s
    kiali                    ClusterIP      172.21.219.101   <none>           20001/TCP                                                                                                                                    35s
    prometheus               ClusterIP      172.21.53.185    <none>           9090/TCP                                                                                                                                     34s
    tracing                  ClusterIP      172.21.6.64      <none>           80/TCP                                                                                                                                       29s
    zipkin                   ClusterIP      172.21.229.37    <none>           9411/TCP                                                                                                                                     29s
    ```

**Note: If your istio-ingressgateway service IP is <pending>, confirm that you are using a standard/paid cluster. Free cluster is not supported for this lab.**

1. Ensure the corresponding pods `istio-citadel-*`, `istio-ingressgateway-*`, `istio-pilot-*`, and `istio-policy-*` are all in **`Running`** state before you continue.

    ```shell
    kubectl get pods -n istio-system
    ```
    Sample output:
    ```shell
    NAME                                      READY   STATUS      RESTARTS   AGE
    grafana-5c45779547-v77cl                  1/1     Running     0          103s
    istio-citadel-79cb95445b-29wvj            1/1     Running     0          102s
    istio-cleanup-secrets-1.1.0-mp6qq         0/1     Completed   0          112s
    istio-egressgateway-6dfb8dd765-jzzxf      1/1     Running     0          104s
    istio-galley-7bccb97448-tk8bz             1/1     Running     0          104s
    istio-grafana-post-install-1.1.0-bvng6    0/1     Completed   0          113s
    istio-ingressgateway-679bd59c6-5bsbr      1/1     Running     0          104s
    istio-pilot-674d4b8469-ttxs8              2/2     Running     0          103s
    istio-policy-6b8795b6b5-g5m2k             2/2     Running     2          103s
    istio-security-post-install-1.1.0-cfqpx   0/1     Completed   0          111s
    istio-sidecar-injector-646d77f96c-55twm   1/1     Running     0          102s
    istio-telemetry-76c8fbc99f-hxskk          2/2     Running     2          103s
    istio-tracing-5fbc94c494-5nkjd            1/1     Running     0          102s
    kiali-56d95cf466-bpgfq                    1/1     Running     0          103s
    prometheus-8647cf4bc7-qnp6x               1/1     Running     0          102s
    ```

    Before you continue, make sure all the pods are deployed and are either in the **`Running`** or **`Completed`** state. If they're in `pending` state, wait a few minutes to let the deployment finish.

    Congratulations! You successfully installed Istio into your cluster.

#### [Continue to Exercise 3 - Deploy Guestbook with Istio Proxy](../exercise-3/README.md)
