## Circuit-breaker

Now that we have reviewed the metrics Mixer is collecting, let's start generating some failures.
We will be using a simple application that will respond to our requests with an HTTP status code.
We want to test out the circuit-breaking features of Istio by generating load incremently with an application called fortio.

We start with a basic Istio route rule (samples/httpbin/routerules/httpbin-v1.yaml) that will direct all of our traffic for the httpbin service to services with the version v1 label.
We will also create a new Istio DestinationPolicy (samples/httpbin/destinationpolicies/httpbin-circuit-breaker.yaml). This will allow us to limit the impact that other clients can have on our service during failures, erratic network chatter, etc. (Review notes about the options set in destinationpolicyfile)

```shell
demo-circuit.sh
```

Let's start to generate some load to the httpbin backend to see if we can trip the circuit.

Our first load test will be with one call to ensure that we return a 200.
<b>PRESS ENTER IN TERMINAL.</b>

Our single request completes with a 200.

Let's trip the breaker with 2 connections and 20 requests. Our current circuit-breaker settings only allow 1 connection and 1 pending request. We should see a 500 for at least one request in our load generation.

<b>PRESS ENTER IN TERMINAL.</b>

After running this load test twice we now see our 503 error codes going up.

Let's generate even more load with 3 connections and 20 requests.

<b>PRESS ENTER IN TERMINAL.</b>

## Failure testing

To test how our service deals with failure, we will try to inject some delays within our bookinfo service. This service will display books with brief descriptions. It will also dispaly ratings by calling on a seperate service.

Let's view a working example of our application.

<b>NAVIGATE TO INGRESSIP/productpage in browser</b>

We create a default routing rule to enable all of our services to connect with each other over version v1 labels
```shell
./demo-failtest.sh
```

From our browser Network dev tools we can see that our landing page is loading all of its services in around X milliseconds.

Let's switch everyone over to v2 and introduce some latency between reviews and book details.

<b>PRESS ENTER IN TERMINAL.</b>

We now get pretty stars on our landing page and our network latency has gone up slightly to X milliseconds. Now are users depend on the stars to always show up and we want to see how are system reacts when we introduce delays in calling to our reviews.

If we look at our grafana Istio dashboard we can see some metrics already being collected for us in regards to our interaction with the bookinfo service.

```shell
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &
```

We now introduce an artificial 2 second latency for all requests to our ratings backend service with a httpFault RouteRule
(manifests/2secratings.yaml)

<b>PRESS ENTER IN TERMINAL.</b>

Notice how our Network debug tools always return in 2+ seconds when we refresh the page. Our ratings service graphs also show increase responce time for our 99th percentile of requests.

Now that we have artifical latency set, we can introduce a mandatory request timeout of 1 second for client's calling our reviews service. (manifests/1secreviews.yaml). Our 2 second latency should now cause failures because we timeout requests in 1 second when calling to the reviews service. We should see failures when calling to the reviews service.

<b>PRESS ENTER IN TERMINAL.</b>

Now when we reload the page, we see an error returned indicating that we cannot fetch reviews for our book. And if we lower our grafana viewing window to 15 minutes, we see all of the metrics indicating 400s from our reviews service.

If we cleanup the delays we caused, our metrics should indicate that we are back to normal.

<b>PRESS ENTER IN TERMINAL.</b>

Grafana shows that our 400s are now decreasing and we're back to version 1 success.

## Traffic shifting with Header Filtering

We will use our book information example again to launch our star ratings service for our colleague Jason to test.

We start with a basic route-rule to make sure all users are routed to v1 of all services

```shell
./demo-tshift.sh
```

Notice how both frank and jason see the same page

We now want to add stars to our rating service to display alongside each review.
Our new rule ( scripts/samples/bookinfo/kube/route-rule-reviews-test-v2.yaml ) will filter all requests for user=jason to the v2 service while everyone else will continue to see v1.

<b>PRESS ENTER IN TERMINAL.</b>

Notice how jason can now see stars next to his reviews and if we login as frank, we still see no stars on v1

<b>PRESS ENTER IN TERMINAL TO CLEANUP</b>
