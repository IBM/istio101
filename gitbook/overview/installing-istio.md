# Install Istio

In this module, you download and install Istio.

1. Either download Istio directly from [https://github.com/istio/istio/releases](https://github.com/istio/istio/releases) or get the latest version by using curl:

   ```text
   curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.3.3 sh -
   ```

> Note : At the time of testing this workshop the latest version of Istio was 1.1.2 If the latest version of Istio updates \(which is very possible\) it should still work. But in case it doesn't, contact the instructor or download 1.1.2 from the releases.



1. Add the `istioctl` client to your PATH. The `<version-number>` is in the directory name. For example, run the following command on a MacOS or Linux system:

   ```text
   export PATH="$PATH:$PWD/istio-1.3.3/bin"
   ```

2. Change the directory to the Istio file location.

   ```text
   cd istio-1.3.3
   ```

3. Install Istio’s Custom Resource Definitions via kubectl apply, and wait a few seconds for the CRDs to be committed in the kube-apiserver:

   ```text
   for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
   ```

4. Now let's install Istio into the `istio-system` namespace in your Kubernetes cluster:

   ```text
   kubectl apply -f install/kubernetes/istio-demo.yaml
   ```

5. Ensure that the `istio-*` Kubernetes services are deployed before you continue.

   ```text
   kubectl get svc -n istio-system
   ```

   ```text
   NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                                                                                                                      AGE
   grafana                  ClusterIP      172.21.52.105    <none>          3000/TCP                                                                                                                                     40s
   istio-citadel            ClusterIP      172.21.219.187   <none>          8060/TCP,15014/TCP                                                                                                                           39s
   istio-egressgateway      ClusterIP      172.21.145.44    <none>          80/TCP,443/TCP,15443/TCP                                                                                                                     40s
   istio-galley             ClusterIP      172.21.207.240   <none>          443/TCP,15014/TCP,9901/TCP                                                                                                                   41s
   istio-ingressgateway     LoadBalancer   172.21.183.182   169.61.84.238   15020:30711/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:32724/TCP,15030:30567/TCP,15031:30282/TCP,15032:32408/TCP,15443:30723/TCP   40s
   istio-pilot              ClusterIP      172.21.255.172   <none>          15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                                       39s
   istio-policy             ClusterIP      172.21.109.44    <none>          9091/TCP,15004/TCP,15014/TCP                                                                                                                 40s
   istio-sidecar-injector   ClusterIP      172.21.106.20    <none>          443/TCP,15014/TCP                                                                                                                            39s
   istio-telemetry          ClusterIP      172.21.196.129   <none>          9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                                       40s
   jaeger-agent             ClusterIP      None             <none>          5775/UDP,6831/UDP,6832/UDP                                                                                                                   36s
   jaeger-collector         ClusterIP      172.21.162.67    <none>          14267/TCP,14268/TCP                                                                                                                          36s
   jaeger-query             ClusterIP      172.21.41.237    <none>          16686/TCP                                                                                                                                    36s
   kiali                    ClusterIP      172.21.230.5     <none>          20001/TCP                                                                                                                                    40s
   prometheus               ClusterIP      172.21.69.254    <none>          9090/TCP                                                                                                                                     39s
   tracing                  ClusterIP      172.21.200.30    <none>          80/TCP                                                                                                                                       36s
   zipkin                   ClusterIP      172.21.11.17     <none>          9411/TCP         9411/TCP                                                                                                                  5d
   ```

6. Ensure the corresponding pods `istio-citadel-*`, `istio-ingressgateway-*`, `istio-pilot-*`, and `istio-policy-*` are all in `Running` state before you continue.

   ```text
    kubectl get pods -n istio-system
   ```

   ```text
   NAME                                      READY   STATUS      RESTARTS   AGE
   grafana-59d57c5c56-9l2nz                  1/1     Running     0          44s
   istio-citadel-66f699cf68-l225h            1/1     Running     0          43s
   istio-egressgateway-7fbcf68b68-78tbm      0/1     Running     0          45s
   istio-galley-fd94bc888-l7kv7              1/1     Running     0          45s
   istio-grafana-post-install-1.3.3-8fl97    0/1     Completed   0          50s
   istio-ingressgateway-587c9fbc85-hzxvq     0/1     Running     0          45s
   istio-pilot-74cb5d88bc-p4kt7              2/2     Running     0          43s
   istio-policy-5865b8c696-df8vn             2/2     Running     1          43s
   istio-security-post-install-1.3.3-q9ttx   0/1     Completed   0          49s
   istio-sidecar-injector-d8856c48f-bqbdp    1/1     Running     0          43s
   istio-telemetry-95689668-qr56h            2/2     Running     2          43s
   istio-tracing-6bbdc67d6c-67nbt            1/1     Running     0          42s
   kiali-8c9d6fbf6-md58d                     1/1     Running     0          44s
   prometheus-7d7b9f7844-5rpbn               1/1     Running     0          43s          5d
   ```

   Before you continue, make sure all the pods are deployed and are either in the `Running` or `Completed` state. If they're in `pending` state, wait a few minutes to let the deployment finish.

7. We will enable automatic sidecar injection.

   ```text
    kubectl label namespace default istio-injection=enabled
   ```

   To Check if it worked.

   ```text
    kubectl get ns --show-labels
   ```

   Output:

   ```text
   NAME              STATUS   AGE    LABELS
   default           Active   25d    istio-injection=enabled
   ibm-cert-store    Active   25d    <none>
   ibm-system        Active   25d    <none>
   istio-system      Active   108s   istio-injection=disabled
   kube-node-lease   Active   25d    <none>
   kube-public       Active   25d    <none>
   kube-system       Active   25d    <none>
   ```

Congratulations! You successfully installed Istio into your cluster.

