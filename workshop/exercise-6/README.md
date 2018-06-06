# Exercise 5 - Observe service telemetry: metrics and tracing

### Challenges with microservices

For the longest time in the history of app development, apps were built with monolith mindset. Monolith apps have a large number of instances running all of the services provided in one app. Things like user account management, payment, and reporting are all run from a shared resource. This worked pretty well until service-oriented architecture (SOA) came along and promised us a much brighter future. The basic principle of SOA is to break down apps to smaller components, and having them to talk to one other using protocols like REST or gRPC. Everyone thought this would fundamentally change the landscape, and it did--up to an extent. However, a new set of challenges emerged. What about cross-services communication? What about observability between microservices, such as logging or tracing? What about metrics?

### Istio telemetry

Istio's tracing and metrics features are designed to provide broad and granular insight into the health of all services. Istio's role as a service mesh makes it the ideal data source for observability information, particularly in a microservices environment. As requests pass through multiple services, identifying performance bottlenecks becomes increasingly difficult using traditional debugging techniques. Distributed tracing provides a holistic view of requests transiting through multiple services, allowing for immediate identification of latency issues. With Istio, distributed tracing comes by default. Simply configure Istio to export tracing data to a backend trace aggregator, such as Jaeger. This will expose latency, retry, and failure information for each hop in a request.

You can read more about how [Istio mixer enables telemetry reporting](https://istio.io/docs/concepts/policy-and-control/mixer.html).

### Configure Istio to receive telemetry data

1. Change the directory to the Istio file location.
   ````
   cd [path_to_istio-version]
   ````

2. Install add-ons for Grafana, Prometheus, ServiceGraph and Jaeger.
   ```console
   kubectl apply -f install/kubernetes/addons/grafana.yaml
   kubectl apply -f install/kubernetes/addons/prometheus.yaml
   kubectl apply -f install/kubernetes/addons/servicegraph.yaml
   kubectl apply -n istio-system -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml
   ```

3. Verify that the add-ons were installed successfully. All add-ons are installed into the `istio-system` namespace.
   ```console
   kubectl get pods -w -n istio-system

   kubectl get services -w -n istio-system
   ```

3. Configure Istio to automatically gather telemetry data for services that run in the service mesh.
   1. Go back to your v2 directory.
      ````
      cd guestbook/v2
      ````

   2. Create a rule to collect telemetry data.
      ```sh
      istioctl create -f guestbook-telemetry.yaml
      ```
   3. Generate a small load to the app.
      ```sh
      while sleep 0.5; do curl http://<guestbook_loadbalancer_external_IP/; done
      ```

## View guestbook telemetry data

#### Jaeger

1. Establish port forwarding from local port 16686 to the Jaeger instance.
   ```console
   kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686
   ```

2. Browse to http://localhost:16686.

3. From the **Services** menu, select **guestbook-v2**.
4. Scroll to the bottom and click on **Find Traces** button to see traces


#### Grafana

1. Establish port forwarding from local port 3000 to the Grafana instance:
   ````
   kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000
   ````

2. Browse to http://localhost:3000 and navigate to the Istio, Mixer or Pilot Dashboard by clicking on the Home menu on the top left.


#### Prometheus

1. Establish port forwarding from local port 9090 to the Prometheus instance.

   ```console
   kubectl -n istio-system port-forward \
     $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') \
     9090:9090
   ```
2. Browse to http://localhost:9090/graph, and in the “Expression” input box, enter: request_count. Click Execute.

#### Service Graph

1. Establish port forwarding from local port 8088 to the Service Graph instance:

   ```console
   kubectl -n istio-system port-forward \
     $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') \
     8088:8088
   ```  

2. Browse to http://localhost:8088/dotviz

#### Mixer Log Stream

```console
kubectl -n istio-system logs $(kubectl -n istio-system get pods -l istio=mixer -o jsonpath='{.items[0].metadata.name}') mixer | grep \"instance\":\"newlog.logentry.istio-system\"
```


## Understand what happened

Although Istio proxies are able to automatically send spans, they need some hints to tie together the entire trace. Apps need to propagate the appropriate HTTP headers so that when the proxies send span information to Zipkin or Jaeger, the spans can be correlated correctly into a single trace.

In the example, when a user visits the Guestbook app, the HTTP request is sent from the guestbook service to Watson Tone Analyzer. In order for the individual spans of guestbook service and Watson Tone Analyzer to be tied together, we have modified the guestbook service to extract the required headers (x-request-id, x-b3-traceid, x-b3-spanid, x-b3-parentspanid, x-b3-sampled, x-b3-flags, x-ot-span-context) and forward them onto the analyzer service when calling the analyzer service from the guestbook service.  The change is in the `v2/guestbook/main.go`. By using the `getForwardHeaders()` method, we are able to extract the required headers, and then we use the required headers further when calling the analyzer service via the `getPrimaryTone()` method.


## Quizzes

1. Does a user need to modify their app to get metrics for their apps?   A: 1. Yes 2. No.  (2 is correct)

2. Does a user need to modify their app to get distributed tracing for their app to work properly? A: 1. Yes 2. No.  (1 is correct)

3. What distributed tracing system does Istio support by default?  A: 1. Zipkin 2. Kibana 3. LogStash 4. Jaeger. (1 and 4 are correct)

#### [Continue to Exercise 7 - Security](../exercise-7/README.md)
