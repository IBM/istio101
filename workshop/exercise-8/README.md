# Exercise 8 - Enforce policies for microservices

Backend systems such as access control systems, telemetry capturing systems, quota enforcement systems, billing systems, and so forth, traditionally directly integrate with services, creating a hard coupling and baking-in specific semantics and usage options.

Istio Mixer provides a generic intermediation layer between app code and infrastructure backends. Its design moves policy decisions out of the app layer and into configuration instead, under operator control. Instead of having app code integrate with specific backends, the app code instead does a fairly simple integration with Mixer, and Mixer takes responsibility for interfacing with the backend systems.

Given that individual infrastructure backends each have different interfaces and operational models, Mixer needs custom code to deal with each and we call these custom bundles of code **adapters**. Some built-in adapters include denier, prometheus,  memquota, and stackdriver.

In this exercise we'll use the denier adapter.

## Service isolation with the denier adapter

1. Block access to Guestbook service:

    ```shell
    kubectl create -f mixer-rule-denial.yaml
    ```

    Let's examine the rule:
    ```yaml
        apiVersion: "config.istio.io/v1alpha2"
        kind: denier
        metadata:
          name: denyall
          namespace: istio-system
        spec:
          status:
            code: 7
            message: Not allowed
        ---
        # The (empty) data handed to denyall at run time
        apiVersion: "config.istio.io/v1alpha2"
        kind: checknothing
        metadata:
          name: denyrequest
          namespace: istio-system
        spec:
        ---
        # The rule that uses denier to deny requests to the guestbook service
        apiVersion: "config.istio.io/v1alpha2"
        kind: rule
        metadata:
          name: deny-hello-world
          namespace: istio-system
        spec:
          match: destination.service=="guestbook.default.svc.cluster.local"
          actions:
          - handler: denyall.denier
            instances:
            - denyrequest.checknothing
    ```

2. Verify that the service is denied:

   In [Exercise 5](../exercise-5/README.md), we created the Ingress resource. Make sure the $INGRESS_IP environment variable is still present. Then in the terminal, try:

    ```shell
    curl http://$INGRESS_IP/
    ```

    You should see the error message `PERMISSION_DENIED:denyall.denier.istio-system:Not allowed`.

    You can also try visiting the guestbook app in the browser, and you should see the same error message.

3. Clean up the rule.

    ```shell
    kubectl delete -f mixer-rule-denial.yaml
    ```

## Quiz
1. Does creating mixer rules require app code changes? (Yes/No) No
2. The custom code that interacts with the backend system, i.e. Prometheus, is called
A. Rule B. Instance C. Adapter
Answer is C

## Further reading
* [Istio Mixer](https://istio.io/docs/concepts/policy-and-control/mixer.html)
* [How to write istio mixer policies](https://medium.com/@szihai_37982/how-to-write-istio-mixer-policies-50dc639acf75)
