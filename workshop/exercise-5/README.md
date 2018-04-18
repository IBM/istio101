# Exercise 5 - Telemetry 



## Understanding what happened

Although Istio proxies are able to automatically send spans, they need some hints to tie together the entire trace. Applications need to propagate the appropriate HTTP headers so that when the proxies send span information to Zipkin or Jaeger, the spans can be correlated correctly into a single trace.

In the example, when a user visits the guestbook, the http request is sent from the guestbook service to the analyzer service.   In order for the individual spans of guestbook service and analyzer service to be tied together, we have modified the guestbook service to extract the required headers (x-request-id, x-b3-traceid, x-b3-spanid, x-b3-parentspanid, x-b3-sampled, x-b3-flags, x-ot-span-context) and forward them onto the analyzer service when calling the analyzer service from the guestbook service.  The change is in the `v2/guestbook/main.go`.  By using the `getForwardHeaders()` method, we are able to extract the required headers, and then we use the required headers further when calling the analyzer service via the `getPrimaryTone()` method.

## Quizes

1. Does a user need to modify their application to get metrics for their applications?   A: 1. Yes 2. No.

2. Does a user need to modify their application to get distributed tracing for their application to work properly? A: 1. Yes 2. No.

3. What distributed tracing system does Istio support by default?  A: 1. Zipkin 2. Kibana 3. LogStash 4. Jaeger

