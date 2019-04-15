# Traffic Management

## Using rules to manage traffic

The core component used for traffic management in Istio is Pilot, which manages and configures all the Envoy proxy instances deployed in a particular Istio service mesh. It lets you specify what rules you want to use to route traffic between Envoy proxies, which run as sidecars to each service in the mesh. Each service consists of any number of instances running on pods, containers, VMs etc. Each service can have any number of versions \(a.k.a. subsets\). There can be distinct subsets of service instances running different variants of the app binary. These variants are not necessarily different API versions. They could be iterative changes to the same service, deployed in different environments \(prod, staging, dev, etc.\). Pilot translates high-level rules into low-level configurations and distributes this config to Envoy instances. Pilot uses three types of configuration resources to manage traffic within its service mesh: Virtual Services, Destination Rules, and Service Entries.

### Virtual Services

A [VirtualService](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#VirtualService) defines a set of traffic routing rules to apply when a host is addressed. Each routing rule defines matching criteria for traffic of a specific protocol. If the traffic is matched, then it is sent to a named [destination](https://istio.io/docs/reference/config/istio.networking.v1alpha3.html#Destination) service \(or [subset](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#Subset) or version of it\) defined in the service registry.

### Destination Rules

A [DestinationRule](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#Destination) defines policies that apply to traffic intended for a service after routing has occurred. These rules specify configuration for load balancing, connection pool size from the sidecar, and outlier detection settings to detect and evict unhealthy hosts from the load balancing pool. Any destination `host` and `subset` referenced in a `VirtualService` rule must be defined in a corresponding `DestinationRule`.

### Service Entries

A [ServiceEntry](https://istio.io/docs/reference/config/istio.networking.v1alpha3.html#ServiceEntry) configuration enables services within the mesh to access a service not necessarily managed by Istio. The rule describes the endpoints, ports and protocols of a white-listed set of mesh-external domains and IP blocks that services in the mesh are allowed to access.

### Gateways

A [Gateway](https://istio.io/docs/reference/config/networking/v1alpha3/gateway/) configures a load balancer for HTTP/TCP traffic operating at the edge of the mesh, most commonly to enable ingress traffic for an application.

## Sidecar injection

In Kubernetes, a sidecar is a utility container in the pod, and its purpose is to support the main container. For Istio to work, Envoy proxies must be deployed as sidecars to each pod of the deployment. There are two ways of injecting the Istio sidecar into a pod: manually using the istioctl CLI tool or automatically using the Istio Initializer. If we followed step 9 in the Setup Steps we should have automatic sidecar injection enabled already. If not we can always inject the sidecar manually.

## The Bookinfo app

If you have  gone through the istio docs you may have seen this app. 

This is a demo application that is a hypothetical book info website comprised of microservices. We can do cool little experiments of the website services using istio features.

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

```bash
curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage
```

We should see an output of `200`

We can also go to our browser and go to our `http://$GATEWAY_URL/productpage` we should see the webpage. Refresh a few times and we will see the rating change from no stars, black stars and red stars.

Before you can use Istio to control the Bookinfo version routing, you need to define the available versions, called _subsets_, in destination rules.

```bash
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml
```

### Apply a virtual service <a id="apply-a-virtual-service"></a>

To route to one version only, you apply virtual services that set the default version for the microservices. In this case, the virtual services will route all traffic to `v1` of each microservice.

```text
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```

Now if we go to our browser and refresh we won't see the rating change. Because we are only seeing `v1` of the rating app.

## Routing

We will see how we can set some routing rules. 

### Route based on user identity <a id="route-based-on-user-identity"></a>

We can also route based on other things like user name. In our app header there is a field that is injected called `end-user` we can match and route based on that. 

```bash
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
```

This is what the virtualservice rule says

```text
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
  ...
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
```

We can see that we are matching on the end-user header and routing all request from user `jason` to review version `v2` and all other request goes to `v1` 

On the `/productpage` of Bookinfo app, log in as `jason` , refresh and you should see ratings appear.

As a practice, you could edit the file and add another match rule to match for your name and route to `v3`

## Fault Injection

We will see how we can inject a fault in the app flow. This can be used for finding bugs in logic as well as testing resiliency to slow networks.

### Injecting an HTTP delay fault <a id="injecting-an-http-delay-fault"></a>

We will inject a delay in the `rating` service for user `jason` 

To test the Bookinfo application microservices for resiliency, inject a 7s delay between the `reviews:v2` and `ratings` microservices for user `jason`. This test will uncover a bug that was intentionally introduced into the Bookinfo app.

Note that the `reviews:v2` service has a 10s hard-coded connection timeout for calls to the ratings service. Even with the 7s delay that you introduced, you still expect the end-to-end flow to continue without any errors.

```text
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml
```

### Testing the delay configuration <a id="testing-the-delay-configuration"></a>

1. Open the [Bookinfo](https://istio.io/docs/examples/bookinfo) web application in your browser.
2. On the `/productpage`, log in as user `jason`.

   You expect the Bookinfo home page to load without errors in approximately 7 seconds. However, there is a problem: the Reviews section displays an error message:

   ```text
   Error fetching product reviews!
   Sorry, product reviews are currently unavailable for this book.
   ```

3. View the web page response times:
   1. Open the _Developer Tools_ menu in you web browser.
   2. Open the Network tab
   3. Reload the `productpage` web page. You will see that the webpage actually loads in about 6 seconds.

### Understanding what happened <a id="understanding-what-happened"></a>

You’ve found a bug. There are hard-coded timeouts in the microservices that have caused the `reviews` service to fail.

The timeout between the `productpage` and the `reviews` service is 6 seconds - coded as 3s + 1 retry for 6s total. The timeout between the `reviews` and `ratings`service is hard-coded at 10 seconds. Because of the delay we introduced, the `/productpage` times out prematurely and throws the error.

```text
...
def getProductReviews(product_id, headers):
    ## Do not remove. Bug introduced explicitly for illustration in fault injection task
    ## TODO: Figure out how to achieve the same effect using Envoy retries/timeouts
    for _ in range(2):
        try:
            url = reviews['name'] + "/" + reviews['endpoint'] + "/" + str(product_id)
            res = requests.get(url, headers=headers, timeout=3.0)
        except:
            res = None
        if res and res.status_code == 200:
            return 200, res.json()
    status = res.status_code if res is not None and res.status_code else 500
    return status, {'error': 'Sorry, product reviews are currently unavailable for this book.'}
    ...
```

The above code snippet is the source code of productpage service. And we can see it tries 2 times for 3 seconds. Thats where the 6 s return is coming from.

Bugs like this can occur in typical enterprise applications where different teams develop different microservices independently. Istio’s fault injection rules help you identify such anomalies without impacting end users.

> Notice that the fault injection test is restricted to when the logged in user is `jason`. If you login as any other user, you will not experience any delays.

## Traffic Shifting

When a new service is created we sometimes want to test the service by allowing a little bit of traffic overtime shifting the entire load. Istio makes it very easy to do.

### Apply weight-based routing <a id="apply-weight-based-routing"></a>

1. To get started, run this command to route all traffic to the `v1` version of each microservice. 

   ```text
   $ kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
   ```

2. Open the Bookinfo site in your browser. The URL is `http://$GATEWAY_URL/productpage`, where `$GATEWAY_URL` is the External IP address of the ingress, as explained in the [Bookinfo](https://istio.io/docs/examples/bookinfo/#determining-the-ingress-ip-and-port) doc.

   Notice that the reviews part of the page displays with no rating stars, no matter how many times you refresh. This is because you configured Istio to route all traffic for the reviews service to the version `reviews:v1` and this version of the service does not access the star ratings service.

3. Transfer 50% of the traffic from `reviews:v1` to `reviews:v3` with the following command:

   ```text
   $ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml
   ```

   Wait a few seconds for the new rules to propagate. Now if you refresh a few times, you should see it change between no stars and red stars.

4. Refresh the `/productpage` in your browser and you now see _red_ colored star ratings approximately 50% of the time. This is because the `v3` version of `reviews` accesses the star ratings service, but the `v1` version does not.

   > With the current Envoy sidecar implementation, you may need to refresh the `/productpage` many times –perhaps 15 or more–to see the proper distribution. You can modify the rules to route 90% of the traffic to `v3` to see red stars more often.

5. Assuming you decide that the `reviews:v3` microservice is stable, you can route 100% of the traffic to `reviews:v3` by applying this virtual service:

```text
$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-v3.yaml
```

Now when you refresh the `/productpage` you will always see book reviews with _red_ colored star ratings for each review.

### Understanding what happened <a id="understanding-what-happened"></a>

In this task you migrated traffic from an old to new version of the `reviews` service using Istio’s weighted routing feature. Note that this is very different than doing version migration using the deployment features of container orchestration platforms, which use instance scaling to manage the traffic.

With Istio, you can allow the two versions of the `reviews` service to scale up and down independently, without affecting the traffic distribution between them.

For more information about version routing with autoscaling, check out the blog article [Canary Deployments using Istio](https://istio.io/blog/2017/0.1-canary/).

## Setting Request Timeouts <a id="title"></a>

We can set request timeouts to service. Microservices take a fail fast approach to application development. So it is suggested that every service have a timeout set so that we can avoid any hanging of resources. We will see that in action next.

Initialize the application version routing by running the following command:

```text
$ kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```

### Request timeouts <a id="request-timeouts"></a>



A timeout for http requests can be specified using the _timeout_ field of the [route rule](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#HTTPRoute). By default, the timeout is 15 seconds, but in this task you override the `reviews` service timeout to 1 second. To see its effect, however, you also introduce an artificial 2 second delay in calls to the `ratings` service.

1. Route requests to v2 of the `reviews` service, i.e., a version that calls the `ratings` service:

   ```text
   cat <<EOF | kubectl apply -f -
   apiVersion: networking.istio.io/v1alpha3
   kind: VirtualService
   metadata:
     name: reviews
   spec:
     hosts:
       - reviews
     http:
     - route:
       - destination:
           host: reviews
           subset: v2
   EOF
   ```

2. Add a 2 second delay to calls to the `ratings` service:

   ```text
   cat <<EOF | kubectl apply -f -
   apiVersion: networking.istio.io/v1alpha3
   kind: VirtualService
   metadata:
     name: ratings
   spec:
     hosts:
     - ratings
     http:
     - fault:
         delay:
           percent: 100
           fixedDelay: 2s
       route:
       - destination:
           host: ratings
           subset: v1
   EOF
   ```

3. Open the Bookinfo URL `http://$GATEWAY_URL/productpage` in your browser.

   You should see the Bookinfo application working normally \(with ratings stars displayed\), but there is a 2 second delay whenever you refresh the page.

4. Now add a half second request timeout for calls to the `reviews` service:

   ```text
   cat <<EOF | kubectl apply -f -
   apiVersion: networking.istio.io/v1alpha3
   kind: VirtualService
   metadata:
     name: reviews
   spec:
     hosts:
     - reviews
     http:
     - route:
       - destination:
           host: reviews
           subset: v2
       timeout: 0.5s
   EOF
   ```

5. Refresh the Bookinfo web page.

   You should now see that it returns in about 1 second, instead of 2, and the reviews are unavailable.

   > The reason that the response takes 1 second, even though the timeout is configured at half a second, is because there is a hard-coded retry in the `productpage` service, so it calls the timing out `reviews` service twice before returning.

### Understanding what happened <a id="understanding-what-happened"></a>

In this task, you used Istio to set the request timeout for calls to the `reviews` microservice to half a second instead of the default of 15 seconds. Since the `reviews` service subsequently calls the `ratings` service when handling requests, you used Istio to inject a 2 second delay in calls to `ratings` to cause the `reviews`service to take longer than half a second to complete and consequently you could see the timeout in action.

You observed that instead of displaying reviews, the Bookinfo product page \(which calls the `reviews` service to populate the page\) displayed the message: Sorry, product reviews are currently unavailable for this book. This was the result of it receiving the timeout error from the `reviews` service.

If you examine the [fault injection task](https://istio.io/docs/tasks/traffic-management/fault-injection/), you’ll find out that the `productpage` microservice also has its own application-level timeout \(3 seconds\) for calls to the `reviews` microservice. Notice that in this task you used an Istio route rule to set the timeout to half a second. Had you instead set the timeout to something greater than 3 seconds \(such as 4 seconds\) the timeout would have had no effect since the more restrictive of the two takes precedence. More details can be found [here](https://istio.io/docs/concepts/traffic-management/#failure-handling-faq).

## Implementing circuit breakers with destination rules

Istio `DestinationRules` allow users to configure Envoy's implementation of [circuit breakers](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/circuit_breaking). Circuit breakers are critical for defining the behavior for service-to-service communication in the service mesh. In the event of a failure for a particular service, circuit breakers allow users to set global defaults for failure recovery on a per service and/or per service version basis. Users can apply a [traffic policy](https://istio.io/docs/reference/config/istio.networking.v1alpha3.html#TrafficPolicy) at the top level of the `DestinationRule` to create circuit breaker settings for an entire service, or it can be defined at the subset level to create settings for a particular version of a service.

Depending on whether a service handles [HTTP](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#ConnectionPoolSettings.HTTPSettings) requests or [TCP](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#ConnectionPoolSettings.TCPSettings) connections, `DestinationRules` expose a number of ways for Envoy to limit traffic to a particular service as well as define failure recovery behavior for services initiating the connection to an unhealthy service.

## Clean Up

For the rest of the workshop we won't use the Bookinfo app. So it might be a good idea to cleanup.

Delete the routing rules and terminate the application pods, run the following shell script from `istio-1.0.6`

folder.

```text
./samples/bookinfo/platform/kube/cleanup.sh
```

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

