# Basic Kubernetes

## What is Kubernetes?

Now that we know what containers are, let's define what Kubernetes is. Kubernetes is a container orchestrator to provision, manage, and scale applications. In other words, Kubernetes allows you to manage the lifecycle of containerized applications within a cluster of nodes \(which are a collection of worker machines, for example, VMs, physical machines etc.\).

Your applications may need many other resources to run such as Volumes, Networks, and Secrets that will help you to do things such as connect to databases, talk to firewalled backends, and secure keys. Kubernetes helps you add these resources into your application. Infrastructure resources needed by applications are managed declaratively.

**Fast fact:** Other orchestration technologies are Mesos and Swarm.

The key paradigm of kubernetes is it’s Declarative model. The user provides the "desired state" and Kubernetes will do it's best make it happen. If you need 5 instances, you do not start 5 separate instances on your own but rather tell Kubernetes that you need 5 instances and Kubernetes will reconcile the state automatically. Simply at this point you need to know that you declare the state you want and Kubernetes makes that happen. If something goes wrong with one of your instances and it crashes, Kubernetes still knows the desired state and creates a new instances on an available node.

**Fun to know:** Kubernetes goes by many names. Sometimes it is shortened to _k8s_ \(losing the internal 8 letters\), or _kube_. The word is rooted in ancient Greek and means "Helmsman". A helmsman is the person who steers a ship. We hope you can seen the analogy between directing a ship and the decisions made to orchestrate containers on a cluster.

## Kubernetes architecture

At its core, Kubernetes is a data store \(etcd\). The declarative model is stored in the data store as objects, that means when you say I want 5 instances of a container then that request is stored into the data store. This information change is watched and delegated to Controllers to take action. Controllers then react to the model and attempt to take action to achieve the desired state. The power of Kubernetes is in its simplistic model.

As shown, API server is a simple HTTP server handling create/read/update/delete\(CRUD\) operations on the data store. Then the controller picks up the change you wanted and makes that happen. Controllers are responsible for instantiating the actual resource represented by any Kubernetes resource. These actual resources are what your application needs to allow it to run successfully

![](../.gitbook/assets/image%20%288%29.png)



## Kubernetes resource model

Kubernetes Infrastructure defines a resource for every purpose. Each resource is monitored and processed by a controller. When you define your application, it contains a collection of these resources. This collection will then be read by Controllers to build your applications actual backing instances. Some of resources that you may work with are listed below for your reference, for a full list you should go to [https://kubernetes.io/docs/concepts/](https://kubernetes.io/docs/concepts/). In this class we will only use a few of them, like Pod, Deployment, etc.

* Config Maps holds configuration data for pods to consume.
* Daemon Sets ensure that each node in the cluster runs this Pod
* Deployments defines a desired state of a deployment object
* Events provides lifecycle events on Pods and other deployment objects
* Endpoints allows a inbound connections to reach the cluster services
* Ingress is a collection of rules that allow inbound connections to reach the cluster services
* Jobs creates one or more pods and as they complete successfully the job is marked as completed.
* Node is a worker machine in Kubernetes
* Namespaces are multiple virtual clusters backed by the same physical cluster
* Pods are the smallest deployable units of computing that can be created and managed in Kubernetes
* Persistent Volumes provides an API for users and administrators that abstracts details of how storage is provided from how it is consumed
* Replica Sets ensures that a specified number of pod replicas are running at any given time
* Secrets are intended to hold sensitive information, such as passwords, OAuth tokens, and ssh keys
* Service Accounts provides an identity for processes that run in a Pod
* Services is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service.
* Stateful Sets is the workload API object used to manage stateful applications.
* and more...

![](../.gitbook/assets/image%20%289%29.png)

#### Hardware <a id="baff"></a>

**Nodes**

![](https://cdn-images-1.medium.com/max/1600/1*uyMd-QxYaOk_APwtuScsOg.png)

A [node](https://kubernetes.io/docs/concepts/architecture/nodes/) is the smallest unit of computing hardware in Kubernetes. It is a representation of a single machine in your cluster. In most production systems, a node will likely be either a physical machine in a datacenter, or virtual machine hosted on a cloud provider like [Google Cloud Platform](https://cloud.google.com/). Don’t let conventions limit you, however; in theory, you can make a node out of [almost](https://twitter.com/jkrippy/status/932800484703862784) [anything](https://blog.hypriot.com/post/setup-kubernetes-raspberry-pi-cluster/).

Thinking of a machine as a “node” allows us to insert a layer of abstraction. Now, instead of worrying about the unique characteristics of any individual machine, we can instead simply view each machine as a set of CPU and RAM resources that can be utilized. In this way, any machine can substitute any other machine in a Kubernetes cluster.

**The Cluster**

![](https://cdn-images-1.medium.com/max/1600/1*KoMzLETQeN-c63x7xzSKPw.png)

Although working with individual nodes can be useful, it’s not the Kubernetes way. In general, you should think about the cluster as a whole, instead of worrying about the state of individual nodes.

In Kubernetes, nodes pool together their resources to form a more powerful machine. When you deploy programs onto the cluster, it intelligently handles distributing work to the individual nodes for you. If any nodes are added or removed, the cluster will shift around work as necessary. It shouldn’t matter to the program, or the programmer, which individual machines are actually running the code.

If this kind of hivemind-like system reminds you of the [Borg from Star Trek](http://memory-alpha.wikia.com/wiki/Borg), you’re not alone; “Borg” is the name for the [internal Google project](http://blog.kubernetes.io/2015/04/borg-predecessor-to-kubernetes.html)Kubernetes was based on.

**Persistent Volumes**

Because programs running on your cluster aren’t guaranteed to run on a specific node, data can’t be saved to any arbitrary place in the file system. If a program tries to save data to a file for later, but is then relocated onto a new node, the file will no longer be where the program expects it to be. For this reason, the traditional local storage associated to each node is treated as a temporary cache to hold programs, but any data saved locally can not be expected to persist.![](https://cdn-images-1.medium.com/max/1200/1*kF57zE9a5YCzhILHdmuRvQ.png)

To store data permanently, Kubernetes uses [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). While the CPU and RAM resources of all nodes are effectively pooled and managed by the cluster, persistent file storage is not. Instead, local or cloud drives can be attached to the cluster as a Persistent Volume. This can be thought of as plugging an external hard drive in to the cluster. Persistent Volumes provide a file system that can be mounted to the cluster, without being associated with any particular node.

#### Software <a id="9af2"></a>

**Containers**

![](https://cdn-images-1.medium.com/max/1600/1*ILinzzMdnD5oQ6Tu2bfBgQ.png)![](https://cdn-images-1.medium.com/max/2000/1*ILinzzMdnD5oQ6Tu2bfBgQ.png)

Programs running on Kubernetes are packaged as [Linux containers](https://www.docker.com/what-container). Containers are a widely accepted standard, so there are already many [pre-built images](https://hub.docker.com/explore/) that can be deployed on Kubernetes.

Containerization allows you to create self-contained Linux execution environments. Any program and all its dependencies can be bundled up into a single file and then shared on the internet. Anyone can download the container and deploy it on their infrastructure with very little setup required. Creating a container can be done programmatically, allowing powerful [CI and CD](http://blog.sonatype.com/achieving-ci/cd-with-kubernetes) pipelines to be formed.

Multiple programs can be added into a single container, but you should limit yourself to one process per container if at all possible. It’s better to have many small containers than one large one. If each container has a tight focus, updates are easier to deploy and issues are easier to diagnose.

**Pods**

![](https://cdn-images-1.medium.com/max/1600/1*8OD0MgDNu3Csq0tGpS8Obg.png)

Unlike other systems you may have used in the past, Kubernetes doesn’t run containers directly; instead it wraps one or more containers into a higher-level structure called a [pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/). Any containers in the same pod will share the same resources and local network. Containers can easily communicate with other containers in the same pod as though they were on the same machine while maintaining a degree of isolation from others.

Pods are used as the unit of replication in Kubernetes. If your application becomes too popular and a single pod instance can’t carry the load, Kubernetes can be configured to deploy new replicas of your pod to the cluster as necessary. Even when not under heavy load, it is standard to have multiple copies of a pod running at any time in a production system to allow load balancing and failure resistance.

Pods can hold multiple containers, but you should limit yourself when possible. Because pods are scaled up and down as a unit, all containers in a pod must scale together, regardless of their individual needs. This leads to wasted resources and an expensive bill. To resolve this, pods should remain as small as possible, typically holding only a main process and its tightly-coupled helper containers \(these helper containers are typically referred to as “side-cars”\).

**Deployments**

![](https://cdn-images-1.medium.com/max/1600/1*iTAVk3glVD95hb-X3HiCKg.png)

Although pods are the basic unit of computation in Kubernetes, they are not typically directly launched on a cluster. Instead, pods are usually managed by one more layer of abstraction: the [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

A deployment’s primary purpose is to declare how many replicas of a pod should be running at a time. When a deployment is added to the cluster, it will automatically spin up the requested number of pods, and then monitor them. If a pod dies, the deployment will automatically re-create it.

Using a deployment, you don’t have to deal with pods manually. You can just declare the desired state of the system, and it will be managed for you automatically.

**Ingress**

![](https://cdn-images-1.medium.com/max/1600/1*tBJ-_g4Mk5OkfzLEHrRsRw.png)

Using the concepts described above, you can create a cluster of nodes, and launch deployments of pods onto the cluster. There is one last problem to solve, however: allowing external traffic to your application.

By default, Kubernetes provides isolation between pods and the outside world. If you want to communicate with a service running in a pod, you have to open up a channel for communication. This is referred to as ingress.

There are multiple ways to add ingress to your cluster. The most common ways are by adding either an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) controller, or a [LoadBalancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/). The exact tradeoffs between these two options are out of scope for this post, but you must be aware that ingress is something you need to handle before you can experiment with Kubernetes.

