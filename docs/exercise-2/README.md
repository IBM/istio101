# Exercise 2 - Installing Istio on IBM Cloud Kubernetes Service

In this module, you will use the Managed Istio add-on to install Istio on your cluster.

Managed Istio is available as part of IBM Cloud™ Kubernetes Service. The service provides seamless installation of Istio, automatic updates and lifecycle management of control plane components, and integration with platform logging and monitoring tools.

1. Download the `istioctl` CLI and add it to your PATH:

   ```shell
   curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.5.6 sh -
   ```

   ```shell
   export PATH=$PWD/istio-1.5.6/bin:$PATH
   ```

1. Enable Managed Istio on your IKS cluster:

    ```shell
    ibmcloud ks cluster addon enable istio --cluster $MYCLUSTER
    ```

1. The install can take up to 10 minutes. Ensure the corresponding pods are all in **`Running`** state before you continue.

    ```shell
    kubectl get pods -n istio-system
    ```

    Sample output:

    ```shell
    NAME                                     READY   STATUS    RESTARTS   AGE

istio-egressgateway-6c966469cc-52t6f    1/1     Running   0          69s
istio-egressgateway-6c966469cc-qq5qd    1/1     Running   0          55s
istio-ingressgateway-7698c7b4f4-69c24   1/1     Running   0          68s
istio-ingressgateway-7698c7b4f4-qttzh   1/1     Running   0          54s
istiod-cbb98c74d-2wvql                  1/1     Running   0          54s
istiod-cbb98c74d-kcr4d                  1/1     Running   0          67s
    ```

> **NOTE** Before you continue, make sure all the pods are deployed and either in the **`Running`** or **`Completed`** state. If they're in `pending` state, wait a few minutes to let the installation and deployment finish.

1. Check the version of your Istio:

    ```shell
    istioctl version
    ```

    Sample output:

    ```shell
    client version: 1.5.6
    control plane version: 1.5.6
    data plane version: 1.5.6 (4 proxies)
    ```

    Congratulations! You successfully installed Istio into your cluster.

## [Continue to Exercise 3 - Deploy Guestbook with Istio Proxy](../exercise-3/README.md)
