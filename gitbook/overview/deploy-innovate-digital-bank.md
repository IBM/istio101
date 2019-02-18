# Deploy Innovate Digital Bank

We will take advantage of Helm to deploy the application into our Kubernetes cluster. A chart is a collection of files that describe a related set of Kubernetes resources. A single chart might be used to deploy something simple, like a memcached pod, or something complex like a full web app stack with HTTP servers, databases, caches, and so on. For our lab each helm chart corresponds to a single Kubernetes deployment.

You should already have the repo cloned. Change directory into the folder.

```bash
cd innovate-digital-bank
```

Let's see all the directories in the folder

```bash
$ ls -1 -d */
accounts/
authentication/
bills/
doc/
portal/
support/
transactions/
userbase/
```

We can see our 7 microservices and the doc folder.

> The flags on the `ls` command lists the directories and forces them to be printed on separate lines.

We'll deploy the `portal` microservice first.

`cat` the helm chart to take a look before we deploy.

```bash
$ cat portal/chart/innovate-portal/values.yaml

# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
replicaCount: 1
revisionHistoryLimit: 3
image:
  repository: moficodes/innovate-portal
  tag: v1.0.1-alpine
  pullPolicy: Always
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
livenessProbe:
  initialDelaySeconds: 3000
  periodSeconds: 1000
service:
  name: Node
  type: NodePort
  servicePort: 3100
  serviceNodePort: 30060
hpa:
  enabled: false
  minReplicas: 2
  maxReplicas: 3
  metrics:
    cpu:
      targetAverageUtilization: 80
    memory:
      targetAverageUtilization: 80
services:
```

This file defines how Helm deploys applications. For instance, we can see what image we are using for our deployment. We have also set some [resource quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/). We have a liveness probe that [health checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/) our application every second. We could also have [horizontal pod autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) for automatically scaling based on load. For this workshop we keep it as `false`.

For this workshop we are using pre-built images of the services. These images live in [Docker Hub](https://hub.docker.com/u/moficodes).

```bash
$ helm upgrade innovate-portal portal/chart/innovate-portal --install

Release "innovate-portal" has been upgraded. Happy Helming!
LAST DEPLOYED: Sun Jan 27 20:42:16 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME             TYPE      CLUSTER-IP     EXTERNAL-IP  PORT(S)         AGE
innovate-portal  NodePort  172.21.236.41  <none>       3100:30060/TCP  2d

==> v1beta1/Deployment
NAME                        DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
innovate-portal-deployment  1        1        1           0          0s

==> v1/Pod(related)
NAME                                         READY  STATUS             RESTARTS  AGE
innovate-portal-deployment-57b478cc5f-gds6x  0/1    ContainerCreating  0         0s
```

The `--install` flag installs the helm chart only if it is not already installed - otherwise it will upgrade it.

Give it a few seconds and then run the following commands:

```bash
$ kubectl get po
NAME                                                  READY     STATUS    RESTARTS   AGE
innovate-portal-deployment-57b478cc5f-gds6x           1/1       Running   0          1m

$ kubectl get deploy
NAME                                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
innovate-portal-deployment           1         1         1            1           28s

$ kubectl get svc
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
innovate-portal           NodePort    172.21.236.41    <none>        3100:30060/TCP   2d
```

The image was deployed and a service was created allowing us to access it from anywhere.

That's one of the seven microservices deployed. Go ahead and deploy the other six:

```bash
accounts
authentication
bills
portal (already deployed)
support
transactions
userbase
```

Run the following commands for all the microservices:

```bash
helm upgrade innovate-<microservice-name> <microservice-name>/chart/innovate-<microservice-name> --install
```

When it's all done check that all the pods, deployments, and services are running properly. If you see a pod in any state other than `Running`, get an instructor to troubleshoot.

```bash
$ kubectl get po
NAME                                                  READY     STATUS    RESTARTS   AGE
innovate-accounts-deployment-d9ffcfcf5-7rqmp          1/1       Running   0          1h
innovate-authentication-deployment-59d6796fdc-pbgxg   1/1       Running   0          1h
innovate-bills-deployment-5896bbf875-qj7lb            1/1       Running   0          1h
innovate-portal-deployment-57b478cc5f-gds6x           1/1       Running   0          1h
innovate-support-deployment-5b9889dd84-4b58w          1/1       Running   0          1h
innovate-transactions-deployment-88889b98f-gdm8n      1/1       Running   0          1h
innovate-userbase-deployment-5f8478b8f-c4vm4          1/1       Running   0          1h

$ kubectl get deploy
NAME                                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
innovate-accounts-deployment         1         1         1            1           1h
innovate-authentication-deployment   1         1         1            1           1h
innovate-bills-deployment            1         1         1            1           1h
innovate-portal-deployment           1         1         1            1           1h
innovate-support-deployment          1         1         1            1           1h
innovate-transactions-deployment     1         1         1            1           1h
innovate-userbase-deployment         1         1         1            1           1h

$ kubectl get svc
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
innovate-accounts         NodePort    172.21.10.10     <none>        3400:30120/TCP   1h
innovate-authentication   NodePort    172.21.24.92     <none>        3200:30100/TCP   1h
innovate-bills            NodePort    172.21.122.166   <none>        3800:30160/TCP   1h
innovate-portal           NodePort    172.21.236.41    <none>        3100:30060/TCP   1h
innovate-support          NodePort    172.21.93.40     <none>        4000:30180/TCP   1h
innovate-transactions     NodePort    172.21.166.41    <none>        3600:30200/TCP   1h
innovate-userbase         NodePort    172.21.240.7     <none>        4100:30050/TCP   1h
kubernetes                ClusterIP   172.21.0.1       <none>        443/TCP          2d
```

That's it! Using the simplified process made available by Helm, you've deployed the Innovate Digital Bank sample application to your cluster.

