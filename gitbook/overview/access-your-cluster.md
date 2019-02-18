# Access Your Cluster

Learn how to set the context to work with your cluster by using the `kubectl` CLI, access the Kubernetes dashboard, and gather basic information about your cluster.

1. First, login to IBM Cloud using the CLI:  
   `ibmcloud login`

   When asked to choose an account, choose the `IBM` account. For region, choose `us-south`.

2. Set the context for your cluster in your CLI.

   a. List the available clusters.

   ```text
   ibmcloud ks clusters
   ```

   > Note: If no clusters are shown, make sure you are targeting the right region with `ibmcloud ks region-set us-south`.

   b. Download the configuration file and certificates for your cluster using the `cluster-config` command.

   ```text
   ibmcloud ks cluster-config <your_cluster_name>
   ```

   c. Copy and paste the output export command from the previous step to set the `KUBECONFIG` environment variable and configure your CLI to run `kubectl` commands against your cluster. Example:  
   `export KUBECONFIG=/Users...`   


   > Note: Every time you log in to the IBM Cloud Kubernetes Service CLI to work with the cluster, you must run these commands to set the path to the cluster's configuration file as a session variable. The Kubernetes CLI uses this variable to find a local configuration file and certificates that are necessary to connect with the cluster in IBM Cloud.

3. Get basic information about your cluster and its worker nodes. This information can help you manage your cluster and troubleshoot issues.

   a. View details of your cluster.

   ```text
   ibmcloud ks cluster-get <your_cluster_name>
   ```

   b. Verify the worker nodes in the cluster.

   ```text
   ibmcloud ks workers <your_cluster_name>
   ibmcloud ks worker-get <worker_ID>
   ```

4. Validate access to your cluster.

   a. View nodes in the cluster.

   ```text
   kubectl get node
   ```

   b. View services, deployments, and pods.

   ```text
   kubectl get svc,deploy,po --all-namespaces
   ```

