# Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Kubernetes Service

You must already have a [cluster created](https://cloud.ibm.com/docs/containers?topic=containers-clusters#clusters_standard). Your cluster must have **3 or more worker nodes** with at least **4 cores and 16GB RAM**, and run Kubernetes version 1.16 or later.

## Install IBM Cloud Kubernetes Service command line utilities

1. Download and install the required CLI tools.

    ```shell
    curl -sL https://ibm.biz/idt-installer | bash
    ```

1. Log in to the IBM Cloud CLI. (If you have a federated account, include the `--sso` flag.)

    ```shell
    ibmcloud login
    ```

## Access your cluster

Learn how to set the context to work with your cluster by using the `kubectl` CLI, access the Kubernetes dashboard, and gather basic information about your cluster.

1. Set the context for your cluster in your CLI. Every time you log in to the IBM Cloud Kubernetes Service CLI to work with the cluster, you must run these commands to set the path to the cluster's configuration file as a session variable. The Kubernetes CLI uses this variable to find a local configuration file and certificates that are necessary to connect with the cluster in IBM Cloud.

    a. List the available clusters.

    ```shell
    ibmcloud ks clusters
    ```

    b. Set an environment variable for your cluster name:

    ```shell
    export MYCLUSTER=<your_cluster_name>
    ```

    c. Download the configuration file and certificates for your cluster using the `cluster-config` command.

    ```shell
    ibmcloud ks cluster config --cluster $MYCLUSTER
    ```

1. Get basic information about your cluster and its worker nodes. This information can help you manage your cluster and troubleshoot issues.

    a.  View details of your cluster.

    ```shell
    ibmcloud ks cluster get --cluster $MYCLUSTER
    ```

    b.  Verify the worker nodes in the cluster.

    ```shell
    ibmcloud ks workers --cluster $MYCLUSTER
    ```

1. Validate access to your cluster by viewing the nodes in the cluster.

    ```shell
    kubectl get nodes
    ```

## Clone the lab repo

1. From your command line, run:

    ```shell
    git clone https://github.com/IBM/istio101

    cd istio101/workshop
    ```

    This is the working directory for the workshop. You will use the example `.yaml` files that are located in the `workshop/plans` directory in the following exercises.

### [Continue to Exercise 2 - Installing Istio](../exercise-2/README.md)
