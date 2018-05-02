# Exercise 8 - Policy Enforcement

Backend systems such as access control systems, telemetry capturing systems, quota enforcement systems, billing systems, and so forth, traditionally directly integrate with Services, creating a hard coupling and baking-in specific semantics and usage options.

Mixer provides a generic intermediation layer between application code and infrastructure backends. Its design moves policy decisions out of the app layer and into configuration instead, under operator control. Instead of having application code integrate with specific backends, the app code instead does a fairly simple integration with Mixer, and Mixer takes responsibility for interfacing with the backend systems.

Here are the tasks for this exercise.

## Service isolation

1. Block access to Guestbook service

    ```sh
    istioctl create -f mixer-rule-denial.yaml
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

2. Verify that you service is denied:

    ```sh
    curl http://$INGRESS_IP/
    ```
    You should the error message `PERMISSION_DENIED:denyall.denier.istio-system:Not allowed`.

3. Clean up the rule.
    ```sh
    istioctl delete -f mixer-rule-denial.yaml
    ```
## Further Reading
[Istio Mixer](https://istio.io/docs/concepts/policy-and-control/mixer.html)
[How to write istio mixer policies](https://medium.com/@szihai_37982/how-to-write-istio-mixer-policies-50dc639acf75)
