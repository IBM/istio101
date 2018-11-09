# Exercise 2 - Installing Istio on IBM Cloud Kubernetes Service
In this module, you download and install Istio.

1.  Either download Istio directly from [https://github.com/istio/istio/releases](https://github.com/istio/istio/releases) or get the latest version by using curl:

    ```shell
    curl -L https://git.io/getLatestIstio | sh -
    ```

2. Extract the installation files, if the script doesn't do it for you.

    ```shell
    tar -xvzf istio-<istio-version>-linux.tar.gz
    ```

3. Add the `istioctl` client to your PATH. The `<version-number>` is in the directory name. For example, run the following command on a MacOS or Linux system:

    ```shell
    export PATH=$PWD/istio-<version-number>/bin:$PATH
    ```

4. Change the directory to the Istio file location.

5. Now let's install Istio into the `istio-system` namespace in your Kubernetes cluster:

    ```shell
    kubectl apply -f $PWD/<istio-installation>/install/kubernetes/istio-demo.yaml
    ```

6. Ensure that the `istio-*` Kubernetes services are deployed before you continue.

    ```shell
    kubectl get svc -n istio-system
    ```

    ```shell
    NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                                                                                                                   AGE
    grafana                    ClusterIP      172.21.44.128    <none>           3000/TCP                                                                                                                  5d
    istio-citadel              ClusterIP      172.21.62.12     <none>           8060/TCP,9093/TCP                                                                                                         5d
    istio-egressgateway        ClusterIP      172.21.115.236   <none>           80/TCP,443/TCP                                                                                                            5d
    istio-galley               ClusterIP      172.21.7.201     <none>           443/TCP,9093/TCP                                                                                                          5d
    istio-ingressgateway       LoadBalancer   172.21.19.202    169.61.151.162   80:31380/TCP,443:31390/TCP,31400:31400/TCP,15011:32440/TCP,8060:32156/TCP,853:30932/TCP,15030:32259/TCP,15031:31292/TCP   5d
    istio-pilot                ClusterIP      172.21.115.9     <none>           15010/TCP,15011/TCP,8080/TCP,9093/TCP                                                                                     5d
    istio-policy               ClusterIP      172.21.165.123   <none>           9091/TCP,15004/TCP,9093/TCP                                                                                               5d
    istio-sidecar-injector     ClusterIP      172.21.164.224   <none>           443/TCP                                                                                                                   5d
    istio-statsd-prom-bridge   ClusterIP      172.21.57.144    <none>           9102/TCP,9125/UDP                                                                                                         5d
    istio-telemetry            ClusterIP      172.21.165.71    <none>           9091/TCP,15004/TCP,9093/TCP,42422/TCP                                                                                     5d
    jaeger-agent               ClusterIP      None             <none>           5775/UDP,6831/UDP,6832/UDP                                                                                                5d
    jaeger-collector           ClusterIP      172.21.154.138   <none>           14267/TCP,14268/TCP                                                                                                       5d
    jaeger-query               ClusterIP      172.21.224.97    <none>           16686/TCP                                                                                                                 5d
    prometheus                 ClusterIP      172.21.173.167   <none>           9090/TCP                                                                                                                  5d
    servicegraph               ClusterIP      172.21.190.31    <none>           8088/TCP                                                                                                                  5d
    tracing                    ClusterIP      172.21.2.208     <none>           80/TCP                                                                                                                    5d
    zipkin                     ClusterIP      172.21.76.162    <none>           9411/TCP                                                                                                                  5d

    ```

  **Note: For Lite clusters, the istio-ingressgateway service will be in `pending` state with no external ip. That is normal.**

7. Ensure the corresponding pods `istio-citadel-*`, `istio-ingressgateway-*`, `istio-pilot-*`, and `istio-policy-*` are all in **`Running`** state before you continue.

    ```shell
    kubectl get pods -n istio-system
    ```

    ```shell
    grafana-85dbf49c94-gccvp                    1/1       Running     0          5d
    istio-citadel-545f49c58b-j8tm5              1/1       Running     0          5d
    istio-cleanup-secrets-smtxn                 0/1       Completed   0          5d
    istio-egressgateway-79f4b99d6f-t2lvk        1/1       Running     0          5d
    istio-galley-5b6449c48f-sc92j               1/1       Running     0          5d
    istio-grafana-post-install-djzm9            0/1       Completed   0          5d
    istio-ingressgateway-6894bd895b-tvklg       1/1       Running     0          5d
    istio-pilot-cb58b65c9-sj8zb                 2/2       Running     0          5d
    istio-policy-69cc5c74d5-gz8kt               2/2       Running     0          5d
    istio-sidecar-injector-75b9866679-sldhs     1/1       Running     0          5d
    istio-statsd-prom-bridge-549d687fd9-hrhfs   1/1       Running     0          5d
    istio-telemetry-d8898f9bd-2gl49             2/2       Running     0          5d
    istio-telemetry-d8898f9bd-9r9jz             2/2       Running     0          5d
    istio-tracing-7596597bd7-tqwkr              1/1       Running     0          5d
    prometheus-6ffc56584f-6jqhg                 1/1       Running     0          5d
    servicegraph-5d64b457b4-z2ctz               1/1       Running     0          5d
    ```

    Before your continue, make sure all the pods are deployed and **`Running`**. If they're in `pending` state, wait a few minutes to let the deployment finish.

    Congratulations! You successfully installed Istio into your cluster.

#### [Continue to Exercise 3 - Deploy Guestbook with Istio Proxy](../exercise-3/README.md)
