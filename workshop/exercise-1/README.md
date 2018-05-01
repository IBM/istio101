# Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Container Service

Assume you already have a Kubernetes cluster, here are the steps to access your cluster:

### Install IBM Cloud Container Service command line utilities

1. Install the IBM Cloud [command line interface](https://clis.ng.bluemix.net/ui/home.html).

2. Log in to the IBM Cloud CLI with IBM API key:   
   `bx login -u ibmcloudxx@us.ibm.com --apikey xxxx`      

3. Install the IBM Cloud Container Service plug-in with `bx plugin install container-service -r Bluemix`.

4. To verify that the plug-in is installed properly, run `bx plugin list`. The Container Service plug-in is displayed in the results as `container-service`.

5. Initialize the Container Service plug-in and point the endpoint to your region, e.g. if your region is us-east:   
   `bx cs region-set us-east`

6. Install the Kubernetes CLI. Go to the [Kubernetes page](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) to install the CLI and follow the steps.


### Access your cluster

1. Set the context for your cluster in your CLI. Every time you log in to the IBM Bluemix Container Service CLI to work with the cluster, you must run these commands to set the path to the cluster's configuration file as a session variable. The Kubernetes CLI uses this variable to find a local configuration file and certificates that are necessary to connect with the cluster in IBM Cloud.

    a. List the available clusters.
    
    ```bash
    bx cs clusters
    ```
    
    b. Download the configuration file and certificates for your cluster using the `cluster-config` command.
    
    ```bash
    bx cs cluster-config {your_cluster_name}
    ```
    
    c. Copy and paste the output command from the previous step to set the `KUBECONFIG` environment variable and configure your CLI to run `kubectl` commands against your cluster.

2. Obtain your kubernetes cluster token.

    ```
    kubectl config view -o jsonpath='{.users[0].user.auth-provider.config.id-token}'
    ```

3. Create a proxy to your Kubernetes API server.

    ```
    kubectl proxy
    ```
    
4. In a browser, go to http://localhost:8001/ui to access the API server dashboard.   Choose the `Token` option and paste in the token obtained earlier from step 2 into the token field and click `SIGN IN`.

5. View details of your cluster.
    ```
    bx cs cluster-get {your_cluster_name}
    ```

6. Verify the worker nodes in the cluster.   
    ```
    bx cs workers {your_cluster_name}
    bx cs worker-get [worker name]
    ```
### Clone the lab repo

From your command line, run:
   
```    
git clone https://github.com/IBM/istio101

cd workshop
```

This is the working directory for the workshop.

#### [Continue to Exercise 2 - Installing Istio](../exercise-2/README.md)
