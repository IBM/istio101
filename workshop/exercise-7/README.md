# Exercise 7 - Secure your services

## Mutual authentication with Transport Layer Security (mTLS)

Istio can secure the communication between microservices without requiring app code changes. Security is provided by authenticating and encrypting communication paths within the cluster. This is becoming a common security and compliance requirement. Delegating communication security to Istio (as opposed to implementing TLS in each microservice), ensures that your app will be deployed with consistent and manageable security policies.

Istio Auth is an optional part of Istio's control plane components. When enabled, it provides each Envoy sidecar proxy with a strong (cryptographic) identity, in the form of certificates.
Identity is based on the microservice's the service account and is independent of its specific network location, such as cluster or current IP address.
Envoys then use these certificates to identify each other and establish an authenticated and encrypted communication channel between them.

Istio Auth is responsible for:

* Providing each service with an identity representing its role.

* Providing a common trust root to allow Envoys to validate and authenticate each other.

* Providing a key management system, automating generation, distribution, and rotation of certificates and keys.

When an app microservice connects to another microservice, the communication is tunneled through the client side and server side Envoys. The end-to-end communication flow is:

* Local TCP connection (i.e., `localhost`, not reaching the "wire") between the app and Envoy (client- and server-side);

* Mutually authenticated and encrypted connection between Envoy proxies.

When Envoy proxies establish a connection, they exchange and validate certificates to confirm that each is indeed connected to a valid and expected peer. The established identities can later be used as basis for policy checks (e.g., access authorization).

## Steps

<<<<<<< HEAD
> Version 2 of the guestbook application uses an external service (tone analyzer) which is not Istio-enabled. Current Istio release (0.8) has a [known limitation](https://istio.io/help/faq/security.html#istio-to-not-istio), where where an mTLS enabled service fails to communicate with a service without Istio. This limitation will be lifted in an upcoming release.
> Thus, we will disable mTLS globally and enable it only for communication between internal cluster services in this lab.

1. Setting up Istio Certificate Authority (CA)

If you have previously deployed Istio without cluster-level CA, start by redeploying Istio using istio-auth.yaml file:

```sh
kubectl delete -f install/kubernetes/istio.yaml
kubectl apply -f install/kubernetes/istio-auth.yaml
```

Be sure to confirm that Istio is running before continuing. See [exercise-2](../exercise-2/README.md) for more details.
=======
> Version 2 of the guestbook application uses an external service (tone analyzer) that is not Istio enabled. The current Istio release (0.8) has a [known limitation](https://istio.io/help/faq/security.html#istio-to-not-istio) where where an mTLS enabled service fails to communicate with a service without Istio. This limitation will be lifted in an upcoming release.
> Thus, we will disable mTLS globally and enable it only for communication between internal cluster services in this lab.

### Verify mTLS Setup
>>>>>>> 03a22d0d0f73728c237292a3a5061864fc6995fa

Verify the cluster-level CA is running:

```sh
kubectl get deployment -l istio=istio-ca -n istio-system
```

Expected output:
```sh
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
istio-ca   1         1         1            1           15h
```

2. Verify the AuthPolicy setting in ConfigMap:

```sh
kubectl get configmap istio -n istio-system | grep authPolicy | head -1
```

Istio mutual TLS authentication is enabled if the line `authPolicy: MUTUAL_TLS` isn't commented (i.e., doesn’t have a leading `#`). By default, mutual TLS authentication is enabled. However, if it is disabled/commented, you can [edit the configuration to enable it](#disabling-authentication).

Due to a [known limitation](https://istio.io/help/faq/security.html#istio-to-not-istio), the Guestbook application can not currently work with mTLS enabled for all services, and it should be disabled globally. Until the limitation is fixed, follow through with the steps defined [here](#disabling-authentication) instead of those listed directly below.

## Trying out the authenticated connection

If mTLS is working correctly, the Guestbook app should continue to operate as expected, without any user visible impact. Istio will automatically add (and manage) the required certificates and private keys. To confirm their presence in the Envoy containers, do the following:

1. Get the name of a guestbook-v2 pod. Make sure the pod is “Running”.

```sh
kubectl get pods -l app=guestbook-v2
NAME                            READY     STATUS    RESTARTS   AGE
guestbook-v2-784546fbb9-299jz   2/2       Running   0          13h
guestbook-v2-784546fbb9-hsbnq   2/2       Running   0          13h
guestbook-v2-784546fbb9-lcxdz   2/2       Running   0          13h
```

2. SSH into the Envoy container. Make sure to change the pod name into the corresponding one on your system. This command will ssh into istio-proxy container (sidecar) of the pod.

```sh
kubectl exec -it guestbook-v2-xxxxxxxx -c istio-proxy /bin/bash
```

3. Verify that the certificate and keys are present.

```sh
ls /etc/certs/
```

You should see the following (plus some others):

```sh
cert-chain.pem   key.pem   root-cert.pem
```

Note that `cert-chain.pem` is Envoy’s public certificate (i.e., presented to the peer), and `key.pem` is the corresponding private key. The `root-cert.pem` file is Istio Auth's root certificate, used to verify peer certificates.

## Disabling authentication

If, for some reason, mTLS is not functional, the Guestbook app will not operate correctly. This would be evident in its UI (e.g., it would display a [`Waiting for database connection`](waiting_on_database.png) message). In that case, mTLS should be disabled.

mTLS can be disabled globally or per service:

* To disable mTLS for all services in the mesh, comment out the `authPolicy` settings in the mesh configuration and restart Istio Pilot to pick up the new configuration:

```sh
kubectl edit configmap istio -n istio-system
...
apiVersion: v1
data:
  mesh: |-
    # Uncomment the following line to enable mutual TLS between proxies
    # authPolicy: MUTUAL_TLS
    ...

kubectl delete pod istio-pilot-657cb5ddf7-9c6nv -n istio-system
pod "istio-pilot-657cb5ddf7-9c6nv" deleted
<<<<<<< HEAD
```

After Istio Pilot is restarted, the Guestbook user interface should display correctly.

* We can now gradually enable mTLS on individual services. For example, in the case of Guestbook we can enable mTLS for the guestbook service:

```sh
kubectl edit service guestbook
apiVersion: v1
kind: Service
metadata:
  annotations:
    auth.istio.io/3000: MUTUAL_TLS
  ...
spec:
  ports:
    - name: http
      targetPort: 3000
  ...
```

=======
```

After Istio Pilot is restarted, the Guestbook user interface should display correctly.

* We can now gradually enable mTLS on individual services. For example, in the case of Guestbook we can enable mTLS for the guestbook service:

```sh
kubectl edit service guestbook
apiVersion: v1
kind: Service
metadata:
  annotations:
    auth.istio.io/3000: MUTUAL_TLS
  ...
spec:
  ports:
    - name: http
      targetPort: 3000
  ...
```

>>>>>>> 03a22d0d0f73728c237292a3a5061864fc6995fa
* Note that annotations also be used to disable mTLS for connections accessing a specific service. Since mTLS is triggered by the server-side proxy requesting a client certificate, add an `auth.istio.io/<port#>: NONE` annotation to the service definition. For example, to disable mTLS on guestbook and analyzer:

```sh
kubectl edit service guestbook
apiVersion: v1
kind: Service
metadata:
  annotations:
    auth.istio.io/3000: NONE
  ...
spec:
  ports:
    - name: http
      targetPort: 3000
  ...


kubectl edit service analyzer
...
metadata:
  annotations:
    auth.istio.io/5000: NONE
spec:
  ports:
    - name: http
      targetPort: 5000
  ...
```

## Quiz

**True or False?**

1. Istio Auth/Citadel provides each microservice with a strong, cryptographic, identity in the form of a certificate. The certificates' life cycle is fully managed by Istio. (True)

2. Istio provides microservices with mutually authenticated connections, without requiring app code changes. (True)

3. Mutual authentication must be on or off for the entire cluster, gradual adoption is not possible. (False)

## Further Reading

* [Basic TLS/SSL Terminology](https://dzone.com/articles/tlsssl-terminology-and-basics)

* [TLS Handshake Explained](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.1.0/com.ibm.mq.doc/sy10660_.htm)

* [Istio Task](https://istio.io/docs/tasks/security/mutual-tls.html)

* [Istio Concept](https://istio.io/docs/concepts/security/mutual-tls.html)

## [Continue to Exercise 8 - Policy Enforcement](../exercise-8/README.md)
