# Enforce Policies

Backend systems such as access control systems, telemetry capturing systems, quota enforcement systems, billing systems, and so forth, traditionally directly integrate with services, creating a hard coupling and baking-in specific semantics and usage options.

Istio Mixer provides a generic intermediation layer between app code and infrastructure backends. Its design moves policy decisions out of the app layer and into configuration instead, under operator control. Instead of having app code integrate with specific backends, the app code instead does a fairly simple integration with Mixer, and Mixer takes responsibility for interfacing with the backend systems.

Given that individual infrastructure backends each have different interfaces and operational models, Mixer needs custom code to deal with each and we call these custom bundles of code **adapters**. Here are some built-in adapters: denier, prometheus, memquota, and stackdriver.

In this exercise we'll use the denier adapter.

## Rate Limiting

We can add a a rate limiting logic that will stop more that 2 request going into the productpage in a 5s time window.

1. Send every request to `v1` of all the services.

```text
kubectl apply -f 06-rate-limit-policy/01-all-v1.yaml
```

2. Apply the rate limiting policy.

```text
kubectl apply -f 06-rate-limit-policy/02-productpage-ratelimit.yaml
```

3. On your browser go to the productpage url and quickly refresh a few times.

![](../.gitbook/assets/image%20%2814%29.png)

4. Lets delete this policy 

```text
kubectl delete -f 06-rate-limit-policy/02-productpage-ratelimit.yaml
```

## Denials and White/Black Listing

We can also apply cluster wide denials or white/black listing

### Denials

1. Send traffic to `v3` of reviews and `v2` if user name is `jason`

```text
kubectl apply -f 07-denials-white-black-policy/01-jason-v2-all-v3.yaml
```

2.  Apply the policy.

```text
kubectl apply -f 07-denials-white-black-policy/02-label-denial.yaml
```

3. Refresh the page a few times. You should see denial for regular user. Log in as Jason to see black stars just fine.

> The policy can take a second to propagate.

4. Delete this policy

```text
kubectl apply -f 07-denials-white-black-policy/02-label-denial.yaml
```

### White/Black Listing

We can accomplish similar task with white listing certain labels as well.

1. Apply the policy

```text
kubectl apply -f 07-denials-white-black-policy/03-whitelist.yaml
```

2. Refresh the page a few times. You should see denial for regular user. Log in as Jason to see black stars just fine.

3. Delete the policy

```text
kubectl delete -f 07-denials-white-black-policy/03-whitelist.yaml
```

## Quiz

1. Does creating mixer rules require app code changes? \(Yes/No\) No
2. The custom code that interacts with the backend system, i.e. Prometheus, is called

   A. Rule B. Instance C. Adapter

   Answer is C

## Further reading

* [Istio Mixer](https://istio.io/docs/concepts/policy-and-control/mixer.html)
* [How to write istio mixer policies](https://medium.com/@szihai_37982/how-to-write-istio-mixer-policies-50dc639acf75)

