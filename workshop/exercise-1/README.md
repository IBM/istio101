# Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Kubernetes Service

You must already have a [cluster created](https://console.bluemix.net/docs/containers/container_index.html#container_index). Here are the steps to access your cluster.

## Install IBM Cloud Kubernetes Service command line utilities

1. Install the IBM Cloud [command line interface](https://clis.ng.bluemix.net/ui/home.html).

2.  Log in to the IBM Cloud CLI. If you have a federated account, include the `[--sso]` flag.   
    
    ```bash
    bx login [--sso]
    ```

3.  Install the IBM Cloud Kubernetes Service plug-in.
    ```bash
    bx plugin install container-service -r Bluemix
    ```

4. To verify that the plug-in is installed properly, run `bx plugin list`. The Kubernetes Service plug-in is displayed in the results as `container-service`.

5.  Initialize the Kubernetes Service plug-in and point the endpoint to your region. For example when prompted, enter `5` for `us-east`.   
    ```bash
    $ bx cs region-set
    Choose a region:
    1. ap-north
    2. ap-south
    3. eu-central
    4. uk-south
    5. us-east
    6. us-south
    Enter a number> 5
    ```
    
6. Install the Kubernetes CLI. Go to the [Kubernetes page](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) to install the CLI and follow the steps.


## Access your cluster
Learn how to set the context to work with your cluster by using the `kubectl` CLI, access the Kubernetes dashboard, and gather basic information about your cluster.

1.  Set the context for your cluster in your CLI. Every time you log in to the IBM Cloud Kubernetes Service CLI to work with the cluster, you must run these commands to set the path to the cluster's configuration file as a session variable. The Kubernetes CLI uses this variable to find a local configuration file and certificates that are necessary to connect with the cluster in IBM Cloud.

    a. List the available clusters.
    
    ```bash
    bx cs clusters
    ```
    
    b. Download the configuration file and certificates for your cluster using the `cluster-config` command.
    
    ```bash
    bx cs cluster-config <your_cluster_name>
    ```
    
    c. Copy and paste the output command from the previous step to set the `KUBECONFIG` environment variable and configure your CLI to run `kubectl` commands against your cluster.

2.  View the Kubernetes dashboard. With the dashboard, you can get an overview of the apps and services that run in your cluster, as well as manage your Kubernetes resources such as deployments and pods.

    a.  Obtain your Kubernetes cluster token.

    ```bash
    kubectl config view -o jsonpath='{.users[0].user.auth-provider.config.id-token}{"\n"}'
    ```

    b.  Create a proxy to your Kubernetes API server.

    ```bash
    kubectl proxy
    ```
    
    c.  In a browser, go to http://localhost:8001/ui to access the API server dashboard.   Choose the `Token` option and paste in the token obtained earlier from step 2 into the token field and click `SIGN IN`.

3.  Get basic information about your cluster and its worker nodes. This information can help you manage your cluster and troubleshoot issues.

    a.  View details of your cluster.
    
    ```bash
    bx cs cluster-get <your_cluster_name>
    ```

    b.  Verify the worker nodes in the cluster.   
    ```bash
    bx cs workers <your_cluster_name>
    bx cs worker-get <worker_ID>
    ```
    
## Clone the lab repo

From your command line, run:
   
```bash   
git clone https://github.com/IBM/istio101

cd istio101/workshop
```

This is the working directory for the workshop. You use the example `.yaml` files that are located in the _workshop/plans_ directory in the following exercises.

### [Continue to Exercise 2 - Installing Istio](../exercise-2/README.md)
