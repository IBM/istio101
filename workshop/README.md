# Beyond the Basics: Istio and IBM Cloud Kubernetes Service
[Istio](https://www.ibm.com/cloud/info/istio) is an open platform to connect, secure, and manage a network of microservices, also known as a service mesh, on cloud platforms such as Kubernetes in IBM Cloud Kubernetes Service. With Istio, You can manage network traffic, load balance across microservices, enforce access policies, verify service identity on the service mesh, and more.

In this course, you can see how to install Istio alongside microservices for a simple mock app called Guestbook. When you deploy Guestbook's microservices into an IBM Cloud Kubernetes Service cluster where Istio is installed, you inject the Istio Envoy sidecar proxies in the pods of each microservice.

**Note**: Some configurations and features of the Istio platform are still under development and are subject to change based on user feedback. Allow a few months for stablilization before you use Istio in production.

## Objectives
After you complete this course, you'll be able to:
- Download and install Istio in your cluster
- Deploy the Guestbook sample app
- Use metrics, logging and tracing to observe services
- Set up the Istio Ingress Gateway
- Perform simple traffic management, such as A/B tests and canary deployments
- Secure your service mesh
- Enforce policies for your microservices

## Prerequisites
You must you must have a Trial, Pay-As-You-Go, or Subscription [IBM Cloud account](https://console.bluemix.net/registration/) to complete all the modules in this course.

Use Kubernetes 1.9.x or newer because earlier versions may require changes in manifests.

You must have [already created a cluster](https://console.bluemix.net/docs/containers/container_index.html#container_index) in IBM Cloud Kubernetes Service.

If you are using a Trial IBM Cloud Account, be aware that you may encounter resource caps, especially if there are existing resources in your cluster.  During the course, if any pods remain in `Pending` status, you may need to adjust the number of `replicas` in the various deployment yamls to a value of 1, delete the deployment, and attempt the steps again.

You should have a basic understanding of containers, IBM Cloud Kubernetes Service, and Istio. If you have no experience with those, take the following courses:
1. [Get started with Kubernetes and IBM Cloud Kubernetes Service](https://developer.ibm.com/courses/all/get-started-kubernetes-ibm-cloud-container-service/)
2. [Get started with Istio and IBM Cloud Kubernetes Service](https://developer.ibm.com/courses/all/get-started-istio-ibm-cloud-container-service/)


## Workshop setup
- [Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Kubernetes Service](exercise-1/README.md)
- [Exercise 2 - Installing Istio](exercise-2/README.md)
- [Exercise 3 - Deploying Guestbook with Istio Proxy](exercise-3/README.md)

## Creating a service mesh with Istio

- [Exercise 4 - Observe service telemetry: metrics and tracing](exercise-4/README.md)
- [Exercise 5 - Expose the service mesh with the Istio Ingress Gateway](exercise-5/README.md)
- [Exercise 6 - Perform traffic management](exercise-6/README.md)
- [Exercise 7 - Secure your service mesh](exercise-7/README.md)
- [Exercise 8 - Enforce policies for microservices](exercise-8/README.md)

## Cleaning up the Workshop

We have given you a [script](cleanup/nuke_the_workshop.sh) as a conveant way to remove Istio and the guestbook
application from your instance.

**NOTE**: This puts your kubernetes cluster in a empty state, so do not run this on anything other then
a place you are willing to loose everything.

```shell
cd cleanup
./nuke_the_workshop.sh

You are about to remove EVERYTHING on your Kubernetes cluster, including Istio.

You must put in Y as your answer.
Are you sure? Y
pod "guestbook-v1-5d956b6c57-8gjrw" deleted
pod "guestbook-v1-5d956b6c57-gtwnh" deleted
pod "guestbook-v1-5d956b6c57-q77sw" deleted
pod "guestbook-v2-f7f8f789b-mtq57" deleted
pod "guestbook-v2-f7f8f789b-qfn5f" deleted
pod "guestbook-v2-f7f8f789b-zw88p" deleted
pod "redis-master-67c878bfb4-psmdh" deleted
pod "redis-slave-5596f694d8-96dtq" deleted
pod "redis-slave-5596f694d8-vb7sk" deleted
[-- snip --]

deployment.extensions "istio-sidecar-injector" deleted
deployment.extensions "istio-statsd-prom-bridge" deleted
deployment.extensions "istio-telemetry" deleted
deployment.extensions "istio-tracing" deleted
deployment.extensions "prometheus" deleted
deployment.extensions "servicegraph" deleted
    ```
