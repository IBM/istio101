# Beyond the Basics: Istio and IBM Cloud Kubernetes Service

[Istio](https://www.ibm.com/cloud/info/istio) is an open platform to connect, secure, control and observe microservices, also known as a service mesh, on cloud platforms such as Kubernetes in IBM Cloud Kubernetes Service and VMs. With Istio, You can manage network traffic, load balance across microservices, enforce access policies, verify service identity, secure service communication and observe what exactly is going on with your services.

YouTube: Istio Service Mesh Explained:

[![Istio Service Mesh Explained](http://img.youtube.com/vi/6zDrLvpfCK4/0.jpg)](https://youtu.be/6zDrLvpfCK4 "Istio Service Mesh Explained")

In this course, you can see how to install Istio alongside microservices for a simple mock app called [Guestbook](https://github.com/IBM/guestbook). When you deploy Guestbook's microservices into an IBM Cloud Kubernetes Service cluster where Istio is installed, you can choose to inject the Istio Envoy sidecar proxies in the pods of certain microservices.

Estimated completion time: 2 hours

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

You must you must have a Pay-As-You-Go, or Subscription [IBM Cloud account](https://cloud.ibm.com/registration/) to complete all the modules in this course.

You must have [already created a Standard 1.16+ cluster](https://cloud.ibm.com/docs/containers?topic=containers-clusters#clusters_standard) in IBM Cloud Kubernetes Service. **FREE Cluster is not supported for this lab**

You should have a basic understanding of containers, IBM Cloud Kubernetes Service, and Istio. If you have no experience with those, take the following courses:

1. [Get started with Kubernetes and IBM Cloud Kubernetes Service](https://cognitiveclass.ai/courses/kubernetes-course/)
2. [Get started with Istio and IBM Cloud Kubernetes Service](https://cognitiveclass.ai/courses/get-started-with-microservices-istio-and-ibm-cloud-container-service/)

## Workshop setup

- [Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Kubernetes Service](exercise-1/README.md)
- [Exercise 2 - Installing Istio](exercise-2/README.md)
- [Exercise 3 - Deploying Guestbook sample application](exercise-3/README.md)

## Creating a service mesh with Istio

- [Exercise 4 - Observe service telemetry: metrics and tracing](exercise-4/README.md)
- [Exercise 5 - Expose the service mesh with the Istio Ingress Gateway](exercise-5/README.md)
- [Exercise 6 - Perform traffic management](exercise-6/README.md)
- [Exercise 7 - Secure your service mesh](exercise-7/README.md)

## Cleaning up the Workshop

Script to uninstall `ibmcloud` CLI: [clean_your_local_machine.sh](cleanup/clean_your_local_machine.sh) and unset `KUBECONFIG`.

Script to delete Istio and Guestbook: [clean_your_k8s_cluster.sh](cleanup/clean_your_k8s_cluster.sh).
