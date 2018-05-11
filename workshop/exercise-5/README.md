# Exercise 5 - Telemetry 

### Challenges with microservices

For the longest time in the history of application development, we build our applications around the concept of monolith mindset. It basically having a large number of instances running all services provided in one application. Things like user account management, payment, reporting are all these services run from a shared resource. This worked pretty well until SOA came along and promised us a much brighter future. The basic principle is to break down applications to smaller components, and having them to talk to one other using protocols like REST or gRPC. Everyone thought this will fundamentally change the landscape and it did up to an extent. However, a new set of challenges emerged. How about cross services communication? How about observability between microservices such as logging or tracing? How about metrics?

### Istio telemetry
 
Istio's tracing and metrics features are designed to provide broad and granular insight into the health of all services. Istio's role as a service mesh makes it the ideal data source for observability information, particularly in a microservices environment. As requests pass through multiple services, identifying performance bottlenecks becomes increasingly difficult using traditional debugging techniques. Distributed tracing provides a holistic view of requests transiting through multiple services, allowing for immediate identification of latency issues. With Istio, distributed tracing comes by default. Simply configure Istio to export tracing data to a backend trace aggregator, such as Jaeger. This will expose latency, retry, and failure information for each hop in a request.

You can fine more on how Istio mixer enables the telemetry reporting.

### See it in action

Change the directory to the Istio file location.

````
cd [path_to_istio-version]
````

First we need to install add-ons for Grafana, Prometheus, ServiceGraph and Jaeger

```
kubectl apply -f install/kubernetes/addons/grafana.yaml
kubectl apply -f install/kubernetes/addons/prometheus.yaml
kubectl apply -f install/kubernetes/addons/servicegraph.yaml
kubectl apply -n istio-system -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml
```

You can view all of these deployments using the command below. You will find it under istio-system namespace

```
kubectl get pods -w --all-namespaces

kubectl get services -w --all-namespaces
```

Now we need to configure Istio to automatically gather telemetry data for services running in the mesh.

1. Go back to your v2 directory

    ````
    cd guestbook/v2
    ````

2. Create a rule to collect telemetry data.

    ```sh
    istioctl create -f guestbook-telemetry.yaml
    ```
3. Generate a small load to the application.

    ```sh
    while sleep 0.5; do curl http://$INGRESS_IP/; done
    ```

## View guestbook telemetry data

#### Grafana

Establish port forwarding from local port 3000 to the Grafana instance:

````
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana \  -o jsonpath='{.items[0].metadata.name}') 3000:3000
````

Browse to http://localhost:3000 and navigate to the Istio Dashboard.

#### Jaeger

Establish port forwarding from local port 16686 to the Jaeger instance

````
kubectl port-forward -n istio-system \$(kubectl get pod -n istio-system -l app=jaeger -o \jsonpath='{.items[0].metadata.name}') 16686:16686 &
````

Browse to http://localhost:9411

#### Prometheus

Establish port forwarding from local port 9090 to the Prometheus instance:

````
kubectl -n istio-system port-forward \
  $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') \
  9090:9090
````  
Browse to http://localhost:9090/graph, and in the “Expression” input box, enter: request_count. Click Execute.

#### Service Graph

Establish port forwarding from local port 8088 to the Service Graph instance:

````
kubectl -n istio-system port-forward \
  $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') \
  8088:8088
````  

Browse to http://localhost:8088/dotviz

#### Mixer Log Stream

````
kubectl -n istio-system logs $(kubectl -n istio-system get pods -l istio=mixer -o jsonpath='{.items[0].metadata.name}') mixer | grep \"instance\":\"newlog.logentry.istio-system\"
````


## Understanding what happened

Although Istio proxies are able to automatically send spans, they need some hints to tie together the entire trace. Applications need to propagate the appropriate HTTP headers so that when the proxies send span information to Zipkin or Jaeger, the spans can be correlated correctly into a single trace.

In the example, when a user visits the guestbook, the HTTP request is sent from the guestbook service to the analyzer service.   In order for the individual spans of guestbook service and analyzer service to be tied together, we have modified the guestbook service to extract the required headers (x-request-id, x-b3-traceid, x-b3-spanid, x-b3-parentspanid, x-b3-sampled, x-b3-flags, x-ot-span-context) and forward them onto the analyzer service when calling the analyzer service from the guestbook service.  The change is in the `v2/guestbook/main.go`.  By using the `getForwardHeaders()` method, we are able to extract the required headers, and then we use the required headers further when calling the analyzer service via the `getPrimaryTone()` method.


## Quizes

1. Does a user need to modify their application to get metrics for their applications?   A: 1. Yes 2. No.  (2 is correct)

2. Does a user need to modify their application to get distributed tracing for their application to work properly? A: 1. Yes 2. No.  (1 is correct)

3. What distributed tracing system does Istio support by default?  A: 1. Zipkin 2. Kibana 3. LogStash 4. Jaeger. (1 and 4 are correct)

