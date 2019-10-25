# Metrics and Tracing

### Challenges with microservices

We all know that microservice architecture is the perfect fit for cloud native applications and it increases the delivery velocities greatly. Envision you have many microservices that are delivered by multiple teams, how do you observe the the overall platform and each of the service to find out exactly what is going on with each of the services? When something goes wrong, how do you know which service or which communication among the few services are causing the problem?

### Istio telemetry

Istio's tracing and metrics features are designed to provide broad and granular insight into the health of all services. Istio's role as a service mesh makes it the ideal data source for observability information, particularly in a microservices environment. As requests pass through multiple services, identifying performance bottlenecks becomes increasingly difficult using traditional debugging techniques. Distributed tracing provides a holistic view of requests transiting through multiple services, allowing for immediate identification of latency issues. With Istio, distributed tracing comes by default. This will expose latency, retry, and failure information for each hop in a request.

You can read more about how [Istio mixer enables telemetry reporting](https://istio.io/docs/concepts/policy-and-control/mixer.html).

### Configure Istio to receive telemetry data

Istio collects metrics data automatically.

### Prometheus

1. Establish port forwarding from local port 9090 to the Prometheus instance.

   ```text
    kubectl -n istio-system port-forward \
      $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') \
      9090:9090 &
   ```

2. Browse to [http://localhost:9090/graph](http://localhost:9090/graph), and in the “Expression” input box, enter: `istio_request_bytes_count`. Click Execute.

![](../.gitbook/assets/prometheus%20%281%29.png)

3. 

```text
kill <process-id>
```

### Jaeger

1. Establish port forwarding from local port 16686 to the Tracing instance:

   ```text
    kubectl port-forward -n istio-system \
      $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') \
      16686:16686 &
   ```

2. In your browser, go to `http://127.0.0.1:16686`

![Jaeger UI](../.gitbook/assets/image%20%287%29.png)

3. From the **Services** menu, select either the **guestbook** or **analyzer** service.

4. Scroll to the bottom and click on **Find Traces** button to see traces.

![Jaeger UI](../.gitbook/assets/image%20%2812%29.png)

5. 

```text
kill <process-id>
```

### Grafana

1. Establish port forwarding from local port 3000 to the Grafana instance:

   ```text
    kubectl -n istio-system port-forward \
      $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') \
      3000:3000 &
   ```

2. Browse to [http://localhost:3000](http://localhost:3000) and navigate to the Istio Mesh Dashboard by clicking on the Home menu on the top left.

![](../.gitbook/assets/image%20%2814%29.png)

3. 

```text
kill <process-id>
```

### Kiali

Kiali is an open-source project that installs on top of Istio to visualize your service mesh. It provides deeper insight into how your microservices interact with one another, and provides features such as circuit breakers and request rates for your services.

1. Establish port forwarding from local port 8084.

   ```text
    kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
   ```

2. Go to [http://localhost:20001/kiali/console](http://localhost:20001/kiali/console) to access kiali dashboard. Use admin/admin as username and password.
3. Click the "Graph" tab on the left side to see the a visual service graph of the various services in your Istio mesh. You can see request rates as well by clicking the "Edge Labels" tab and choosing "Traffic rate per second".

![](../.gitbook/assets/image%20%289%29.png)

4. 

```text
kill <process-id>
```

## Questions

1. Does a user need to modify their app to get metrics for their apps? A: 1. Yes 2. No. \(2 is correct\)
2. Does a user need to modify their app to get distributed tracing for their app to work properly? A: 1. Yes 2. No. \(1 is correct\)
3. What distributed tracing system does Istio support by default? A: 1. Zipkin 2. Kibana 3. LogStash 4. Jaeger. \(1 and 4 are correct\)

