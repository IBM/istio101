# Istio 101 workshop

[Istio](https://www.ibm.com/cloud/info/istio) is an open platform to connect, secure, and manage a network of microservices, also known as a service mesh, on cloud platforms such as Kubernetes in IBM Cloud Container Service. With Istio, manage network traffic, load balance across microservices, enforce access policies, verify service identity on the service mesh, and more.

In this tutorial, you can see how to install Istio alongside microservices for a simple mock app called Guestbook. The microservices include a product web page, book details, reviews, and ratings. When you deploy Guestbook's microservices into an IBM Cloud Container Service cluster where Istio is installed, you inject the Istio Envoy sidecar proxies in the pods of each microservice.

**Note**: Some configurations and features of the Istio platform are still under development and are subject to change based on user feedback. Allow a few months for stablilization before you use Istio in production.

## Objectives
After you complete this course, you'll be able to: 
- Download and install Istio in your cluster
- Deploy the Guestbook sample app
- Set up the Istio Ingress controller
- Use metrics, logging and tracing to observe services
- Perform simple traffic management, such as A/B tests and canary deployments
- Secure your service mesh
- Enforce policies for your microservices

## Prerequisites
You must create a [standard cluster in a Pay-As-You-Go and Subscription account](https://console.bluemix.net/registration/) to complete all the modules in this course. A free cluster in a Trial account does not have access to all the advanced features of this course. 

You should have a basic understanding of containers, IBM Cloud Container Service, and Istio. If you have no experience with those, take the following courses:
1. [Docker essentials: Extend your apps with containers](https://developer.ibm.com/courses/all/docker-essentials-extend-your-apps-with-containers/) 
2. [Get started with Kubernetes and IBM Cloud Container Service](https://developer.ibm.com/courses/all/get-started-kubernetes-ibm-cloud-container-service/)
3. [Get started with Istio and IBM Cloud Container Service](https://developer.ibm.com/courses/all/get-started-istio-ibm-cloud-container-service/)


## Workshop setup
- [Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Container Service](exercise-1/README.md)

## Creating a service mesh with Istio

- [Exercise 2 - Installing Istio](exercise-2/README.md)
- [Exercise 3 - Deploy Guestbook with Istio Proxy](exercise-3/README.md)
- [Exercise 4 - Istio Ingress controller](exercise-4/README.md)
- [Exercise 5 - Telemetry](exercise-5/README.md)
- [Exercise 6 - Traffic Management](exercise-6/README.md)
- [Exercise 7 - Security](exercise-7/README.md)
- [Exercise 8 - Policy Enforcement](exercise-8/README.md)
