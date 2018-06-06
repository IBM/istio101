# Exercise 2 - Installing Istio on IBM Cloud Container Service
In this module, you download and install Istio.

1.  Either download Istio directly from [https://github.com/istio/istio/releases](https://github.com/istio/istio/releases) or get the latest version by using curl:
    ```bash
    curl -L https://git.io/getLatestIstio | sh -
    ```
2. Extract the installation files.
3. Add the `istioctl` client to your PATH. The `<version-number>` is in the directory name. For example, run the following command on a MacOS or Linux system:
```
export PATH=$PWD/istio-<version-number>/bin:$PATH
```
4. Change the directory to the Istio file location.

5. Install Istio on the Kubernetes cluster. Istio is deployed in the Kubernetes namespace `istio-system`. Since in a later exercise we will try out the mutual TLS features, we install the `istio-demo-auth.yaml` here.
```bash
kubectl apply -f install/kubernetes/istio-demo.yaml
```

6. Ensure that the Kubernetes services `istio-ingress`, `istio-mixer`, and `istio-pilot` are fully deployed before you continue.
```bash
kubectl get svc -n istio-system
```
```
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                                                            AGE
istio-ingress   LoadBalancer   172.21.xxx.xxx   169.xx.xxx.xxx   80:31176/TCP,443:30288/TCP                                         2m
istio-mixer     ClusterIP      172.21.xxx.xxx   <none>           9091/TCP,15004/TCP,9093/TCP,9094/TCP,9102/TCP,9125/UDP,42422/TCP   2m
istio-pilot     ClusterIP      172.21.xxx.xxx   <none>           15003/TCP,443/TCP                                                  2m
```
  **Note: For Lite clusters, the istio-ingress service will be in `pending` state with no external ip. That is normal.**

7. Ensure the corresponding pods `istio-ca-*`, `istio-ingress-*`, `istio-mixer-*`, and `istio-pilot-*` are all in **`Running`** state before you continue.
```
kubectl get pods -n istio-system
```
```
istio-ca-3657790228-j21b9           1/1       Running   0          5m
istio-ingress-1842462111-j3vcs      1/1       Running   0          5m
istio-mixer-2104784889-20rm8        3/3       Running   0          5m
istio-pilot-2275554717-93c43        2/2       Running   0          5m
```

Before your continue, make sure all the pods are deployed. If they're in running state, wait and let the deployment finish.

Congratulations! You successfully installed Istio into your cluster.

#### [Continue to Exercise 3 - Deploy Guestbook with Istio Proxy](../exercise-3/README.md)
