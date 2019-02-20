# Traffic Management

## Using rules to manage traffic

The core component used for traffic management in Istio is Pilot, which manages and configures all the Envoy proxy instances deployed in a particular Istio service mesh. It lets you specify what rules you want to use to route traffic between Envoy proxies, which run as sidecars to each service in the mesh. Each service consists of any number of instances running on pods, containers, VMs etc. Each service can have any number of versions \(a.k.a. subsets\). There can be distinct subsets of service instances running different variants of the app binary. These variants are not necessarily different API versions. They could be iterative changes to the same service, deployed in different environments \(prod, staging, dev, etc.\). Pilot translates high-level rules into low-level configurations and distributes this config to Envoy instances. Pilot uses three types of configuration resources to manage traffic within its service mesh: Virtual Services, Destination Rules, and Service Entries.

### Virtual Services

A [VirtualService](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#VirtualService) defines a set of traffic routing rules to apply when a host is addressed. Each routing rule defines matching criteria for traffic of a specific protocol. If the traffic is matched, then it is sent to a named [destination](https://istio.io/docs/reference/config/istio.networking.v1alpha3.html#Destination) service \(or [subset](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#Subset) or version of it\) defined in the service registry.

### Destination Rules

A [DestinationRule](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#Destination) defines policies that apply to traffic intended for a service after routing has occurred. These rules specify configuration for load balancing, connection pool size from the sidecar, and outlier detection settings to detect and evict unhealthy hosts from the load balancing pool. Any destination `host` and `subset` referenced in a `VirtualService` rule must be defined in a corresponding `DestinationRule`.

### Service Entries

A [ServiceEntry](https://istio.io/docs/reference/config/istio.networking.v1alpha3.html#ServiceEntry) configuration enables services within the mesh to access a service not necessarily managed by Istio. The rule describes the endpoints, ports and protocols of a white-listed set of mesh-external domains and IP blocks that services in the mesh are allowed to access.

## The Bookinfo app

Guest book app was interesting and allowed us to see few of the istio features like egress and metrics and such. But to totally get the routing power of istio we will make use of the official istio app Bookinfo. If you have  gone through the istio docs you may have seen this app.

If you want to clear your cluster and remove the Guestbook app for now you can run the following script from the `guestbook/v2` folder.

{% code-tabs %}
{% code-tabs-item title="clean.sh" %}
```bash
 #!/bin/bash
 kubectl delete -f redis-master-deployment.yaml
 kubectl delete -f redis-master-service.yaml
 kubectl delete -f redis-slave-deployment.yaml
 kubectl delete -f redis-slave-service.yaml

 kubectl delete -f ../v1/guestbook-deployment.yaml
 kubectl delete -f guestbook-deployment.yaml

 kubectl delete -f guestbook-service.yaml

 kubectl delete -f analyzer-deployment.yaml
 kubectl delete -f analyzer-service.yaml

```
{% endcode-tabs-item %}
{% endcode-tabs %}

and from the istio101/workshop/plans folder run the following 

{% code-tabs %}
{% code-tabs-item title="clean-plans.sh" %}
```bash
kubectl delete -f guestbook-gateway.yaml
kubectl get gateways.networking.istio.io
```
{% endcode-tabs-item %}
{% endcode-tabs %}

In the install istio step we downloaded the `istio-1.0.6` folder. Go to that folder. The rest of the traffic management stuff will be run from there.

### App Overview



The Bookinfo application is broken into four separate microservices:

* `productpage`. The `productpage` microservice calls the `details` and `reviews` microservices to populate the page.
* `details`. The `details` microservice contains book information.
* `reviews`. The `reviews` microservice contains book reviews. It also calls the `ratings` microservice.
* `ratings`. The `ratings` microservice contains book ranking information that accompanies a book review.

There are 3 versions of the `reviews` microservice:

* Version v1 doesn’t call the `ratings` service.
* Version v2 calls the `ratings` service, and displays each rating as 1 to 5 black stars.
* Version v3 calls the `ratings` service, and displays each rating as 1 to 5 red stars.

![](../.gitbook/assets/image%20%284%29.png)

## Deploying the app

```bash
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```

The command above deploys following pods

```text
NAME                             READY     STATUS    RESTARTS   AGE
details-v1-6764bbc7f7-qx9lq      2/2       Running   0          5m
productpage-v1-54b8b9f55-l2n48   2/2       Running   0          5m
ratings-v1-7bc85949-gxdpt        2/2       Running   0          5m
reviews-v1-fdbf674bb-29cnw       2/2       Running   0          5m
reviews-v2-5bdc5877d6-2jwc2      2/2       Running   0          5m
reviews-v3-dd846cc78-fgxzx       2/2       Running   0          5m
```

We would like to access the app from outside the cluster like from our browser or curl from terminal. We define a Istio Gateway for that.

```bash
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
```

Confirm the gateway was created by running `kubectl get gateway`

Lets find out Ingress Host and Ingress Port.

```bash
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
```

Now lets combine this two to find out gateway url.

```bash
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
```

### Confirm the app is running



## Implementing circuit breakers with destination rules

Istio `DestinationRules` allow users to configure Envoy's implementation of [circuit breakers](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/circuit_breaking). Circuit breakers are critical for defining the behavior for service-to-service communication in the service mesh. In the event of a failure for a particular service, circuit breakers allow users to set global defaults for failure recovery on a per service and/or per service version basis. Users can apply a [traffic policy](https://istio.io/docs/reference/config/istio.networking.v1alpha3.html#TrafficPolicy) at the top level of the `DestinationRule` to create circuit breaker settings for an entire service, or it can be defined at the subset level to create settings for a particular version of a service.

Depending on whether a service handles [HTTP](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#ConnectionPoolSettings.HTTPSettings) requests or [TCP](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#ConnectionPoolSettings.TCPSettings) connections, `DestinationRules` expose a number of ways for Envoy to limit traffic to a particular service as well as define failure recovery behavior for services initiating the connection to an unhealthy service.

## Further reading

* [Istio Concept](https://istio.io/docs/concepts/traffic-management/)
* [Istio Rules API](https://istio.io/docs/reference/config/istio.networking.v1alpha3)
* [Istio V1alpha1 to V1alpha3 Converter Tool](https://istio.io/docs/reference/commands/istioctl.html#istioctl%20experimental%20convert-networking-config)
* [Istio Proxy Debug Tool](https://istio.io/docs/reference/commands/istioctl/#istioctl%20proxy-config)
* [Traffic Management](https://blog.openshift.com/istio-traffic-management-diving-deeper/)
* [Circuit Breaking](https://blog.openshift.com/microservices-patterns-envoy-part-i/)
* [Timeouts and Retries](https://blog.openshift.com/microservices-patterns-envoy-proxy-part-ii-timeouts-retries/)

## Questions

1. Where are routing rules defined?  Options: \(VirtualService, DestinationRule, ServiceEntry\)  Answer: VirtualService
2. Where are service versions \(subsets\) defined?  Options: \(VirtualService, DestinationRule, ServiceEntry\)  Answer: DestinationRule
3. Which Istio component is responsible for sending traffic management configurations to Istio sidecars?  Options: \(Mixer, Citadel, Pilot, Kubernetes\)  Answer: Pilot
4. What is the name of the default proxy that runs in Istio sidecars and routes requests within the service mesh?  Options: \(NGINX, Envoy, HAProxy\)  Answer: Envoy

