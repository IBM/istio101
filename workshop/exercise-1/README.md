# Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Kubernetes Service

You must already have a [cluster created](https://console.bluemix.net/docs/containers/container_index.html#container_index). Here are the steps to access your cluster.

## Install IBM Cloud Kubernetes Service command line utilities

1. Install the IBM Cloud [command line interface](https://console.bluemix.net/docs/cli/reference/bluemix_cli/get_started.html#getting-started).

2.  Log in to the IBM Cloud CLI. If you have a federated account, include the `[--sso]` flag.

```shell
ibmcloud login [--sso]
```


3.  Install the IBM Cloud Kubernetes Service plug-in.

```shell
ibmcloud plugin install container-service -r Bluemix
```

4. To verify that the plug-in is installed properly, run `ibmcloud plugin list`. The Container Service plug-in is displayed in the results as `container-service`.

5.  Initialize the Container Service plug-in and point the endpoint to your region. For example when prompted, enter `5` for `us-east`.

Example:

```shell
ibmcloud cs region-set
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

> To proceed, your Kubernetes cluster must be started - the state should change from "Pending" to "Normal". Here are the steps to access your cluster. If your cluster is taking too long to create, ask a room moderator for help.


## Access your cluster
Learn how to set the context to work with your cluster by using the `kubectl` CLI, access the Kubernetes dashboard, and gather basic information about your cluster.

1.  Set the context for your cluster in your CLI. Every time you log in to the IBM Cloud Kubernetes Service CLI to work with the cluster, you must run these commands to set the path to the cluster's configuration file as a session variable. The Kubernetes CLI uses this variable to find a local configuration file and certificates that are necessary to connect with the cluster in IBM Cloud.

a. List the available clusters.

```shell
ibmcloud cs clusters
```

b. Download the configuration file and certificates for your cluster using the `cluster-config` command.

```shell
ibmcloud cs cluster-config <your_cluster_name>
```

c. Copy and paste the output command from the previous step to set the `KUBECONFIG` environment variable and configure your CLI to run `kubectl` commands against your cluster.

    > Consider placing the EXPORT command in your bash profile to avoid running these commands every time you open a new shell.


2.  Get basic information about your cluster and its worker nodes. This information can help you manage your cluster and troubleshoot issues.

a.  View details of your cluster.

```shell
ibmcloud cs cluster-get <your_cluster_name>
```

b.  Verify the worker nodes in the cluster.

```shell
ibmcloud cs workers <your_cluster_name>
ibmcloud cs worker-get <worker_ID>
```

3.  Validate access to your cluster.

a.  View nodes in the cluster.

```shell
kubectl get node
```

b.  View services, deployments, and pods.

```shell
kubectl get svc,deploy,po --all-namespaces
```

## Clone the lab repo

From your command line, run:

```shell
git clone https://github.com/IBM/istio101

cd istio101/workshop
```

This is the working directory for the workshop. You use the example `.yaml` files that are located in the _workshop/plans_ directory in the following exercises.

### [Continue to Exercise 2 - Installing Istio](../exercise-2/README.md)
