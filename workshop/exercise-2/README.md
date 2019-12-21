# Exercise 2 - Installing Istio on IBM Cloud Kubernetes Service

In this module, you will use the Managed Istio add-on to install Istio on your cluster. 

Managed Istio is available as part of IBM Cloud™ Kubernetes Service. The service provides seamless installation of Istio, automatic updates and lifecycle management of control plane components, and integration with platform logging and monitoring tools.

1. Download the `istioctl` CLI and add it to your PATH:
   ```shell
   curl -sL https://raw.githubusercontent.com/istio/istio/release-1.4/release/downloadIstioCtl.sh | sh -
   ```
   ```
   export PATH=$PATH:$HOME/.istioctl/bin
   ```

2. Enable Managed Istio on your IKS cluster:

    ```shell
    ibmcloud ks cluster addon enable istio --cluster $MYCLUSTER
    ```

3. Ensure that the `istio-*` Kubernetes services are deployed before you continue. This might take up to 5 minutes.

    ```shell
    kubectl get svc -n istio-system
    ```

    Sample output:
    ```shell
    NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                                                                                                                      AGE
    grafana                  ClusterIP      172.21.248.16    <none>          3000/TCP                                                                                                                                     2s
    istio-citadel            ClusterIP      172.21.86.151    <none>          8060/TCP,15014/TCP                                                                                                                           6m56s
    istio-egressgateway      ClusterIP      172.21.197.125   <none>          80/TCP,443/TCP,15443/TCP                                                                                                                     6m56s
    istio-galley             ClusterIP      172.21.29.234    <none>          443/TCP,15014/TCP,9901/TCP                                                                                                                   6m56s
    istio-ingressgateway     LoadBalancer   172.21.161.24    169.61.10.106   15020:31167/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:30889/TCP,15030:31326/TCP,15031:30961/TCP,15032:31491/TCP,15443:30967/TCP   6m55s
    istio-pilot              ClusterIP      172.21.168.110   <none>          15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                                       6m55s
    istio-policy             ClusterIP      172.21.147.132   <none>          9091/TCP,15004/TCP,15014/TCP                                                                                                                 6m55s
    istio-sidecar-injector   ClusterIP      172.21.57.81     <none>          443/TCP                                                                                                                                      6m55s
    istio-telemetry          ClusterIP      172.21.231.56    <none>          9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                                       6m55s
    jaeger-agent             ClusterIP      None             <none>          5775/UDP,6831/UDP,6832/UDP                                                                                                                   2s
    jaeger-collector         ClusterIP      172.21.0.87      <none>          14267/TCP,14268/TCP                                                                                                                          2s
    jaeger-query             ClusterIP      172.21.157.12    <none>          16686/TCP                                                                                                                                    2s
    kiali                    ClusterIP      172.21.156.209   <none>          20001/TCP                                                                                                                                    2s
    prometheus               ClusterIP      172.21.159.166   <none>          9090/TCP                                                                                                                                     6m55s
    tracing                  ClusterIP      172.21.210.248   <none>          80/TCP                                                                                                                                       1s
    zipkin                   ClusterIP      172.21.214.67    <none>          9411/TCP                                                                                                                                     1s

    ```

**Note: If your istio-ingressgateway service IP is <pending>, confirm that you are using a standard/paid cluster. Free cluster is not supported for this lab.**

1. Ensure the corresponding pods `istio-citadel-*`, `istio-ingressgateway-*`, `istio-pilot-*`, and `istio-policy-*` are all in **`Running`** state before you continue.

    ```shell
    kubectl get pods -n istio-system
    ```
    Sample output:
    ```shell
    NAME                                     READY   STATUS    RESTARTS   AGE
    grafana-6c89cb48cf-v767v                 1/1     Running   0          33s
    istio-citadel-66dff76d4-r9gsf            1/1     Running   0          7m27s
    istio-egressgateway-55fc547574-svkkr     1/1     Running   0          7m27s
    istio-galley-7d9dbfd4b9-fw2qk            1/1     Running   0          7m27s
    istio-ingressgateway-9c4856497-rpxvs     1/1     Running   0          7m27s
    istio-pilot-7ff6949955-d9hbw             2/2     Running   0          7m27s
    istio-policy-6b88dd467b-hxhqx            2/2     Running   1          7m27s
    istio-sidecar-injector-bc8dddd65-bwhbq   1/1     Running   0          7m27s
    istio-telemetry-5f9df6d9cc-wppmf         2/2     Running   1          7m26s
    istio-tracing-5777dc949f-k2lhc           1/1     Running   0          33s
    kiali-8c696cc97-2cwk2                    1/1     Running   0          33s
    prometheus-65c985bf4c-g8ch5              1/1     Running   0          7m26s
    ```

    Before you continue, make sure all the pods are deployed and either in the **`Running`** or **`Completed`** state. If they're in `pending` state, wait a few minutes to let the installation and deployment finish.

    Congratulations! You successfully installed Istio into your cluster.

#### [Continue to Exercise 3 - Deploy Guestbook with Istio Proxy](../exercise-3/README.md)
