# Module 2 - Installing Istio on IBM Cloud Container Service
In this module, you download and install Istio.

1. Either download Istio directly from [https://github.com/istio/istio/releases](https://github.com/istio/istio/releases) or get the latest version by using curl:
```
curl -L https://git.io/getLatestIstio | sh -
```
2. Extract the installation files.
3. Add the `istioctl` client to your PATH. For example, run the following command on a MacOS or Linux system:
```
export PATH=$PWD/istio-<version-number>/bin:$PATH
```
4. Change the directory to the Istio file location.

5. Install Istio on the Kubernetes cluster. Istio is deployed in the Kubernetes namespace `istio-system`. Since in the later exercise we will try out the mutual TLS features, we install the `istio-auth.yaml` here.
```
kubectl apply -f install/kubernetes/istio-auth.yaml
```

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

Congratulations! You successfully installed Istio into your cluster. 
