# Exercise 7 - Security

## Mutual Authentication with Transport Layer Security (mTLS)

Istio can secure the communication between microservices without requiring application code changes.

Istio Auth is an optional part of Istio's control plane components. When enabled, it provides each Envoy sidecar proxy with a strong (cryptographic) identity, in the form of certificates.
Identity is based on the microservice's the service account and is independent of its specific network location, such as cluster or current IP address.
Envoys then use these certificates to identify each other and establish an authenticated and encrypted communication channel between them.

Istio Auth is responsible for:

* Providing each service with an identity representing its role.

* Providing a common trust root to allow Envoys to validate and authenticate each other.

* Providing a key management system, automating generation, distribution, and rotation of certificates and keys.

When an application microservice connects to another microservice, the communication is tunneled through the client side and server side Envoys. The end-to-end communication flow is:

* Local TCP connection (i.e., `localhost`, not reaching the "wire") between the application and Envoy (client- and server-side);

* Mutually authenticated and encrypted connection between Envoy proxies.

When Envoys establish a connection, they exchange and validate certificates to confirm that each is indeed connected to a valid and expected peer. The established identities can later be used as basis for policy checks (e.g. access authorization).

### Verify Istio’s mTLS Setup

Verify the cluster-level CA is running:

```sh
kubectl get deployment -l istio=istio-ca -n istio-system
```

Istio CA is up if the “AVAILABLE” column is 1. For example:
```sh
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
istio-ca   1         1         1            1           15h
```

### Verify AuthPolicy Setting in ConfigMap

```sh
kubectl get configmap istio -o yaml -n istio-system | grep authPolicy | head -1
```

Istio mutual TLS authentication is enabled if the line `authPolicy: MUTUAL_TLS` isn't commented (i.e., doesn’t have a leading `#`).

### Trying out the Authenticated Connection

If mTLS is working correctly, the Guestbook application should continue to operate as expected, without any user visible impact. Istio will automatically add (and manage) the required certificates and private keys. To confirm their presence in the Envoy containers, do the following:

1. Get the name of a guestbook-v2 pod. Make sure the pod is “Running”.

```sh
kubectl get pods -l app=guestbook-v2
NAME                            READY     STATUS    RESTARTS   AGE
guestbook-v2-784546fbb9-299jz   2/2       Running   0          13h
guestbook-v2-784546fbb9-hsbnq   2/2       Running   0          13h
guestbook-v2-784546fbb9-lcxdz   2/2       Running   0          13h
```

2. SSH into the istio-proxy envoy container (sidecar) of the pod.

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

Note that `cert-chain.pem` is Envoy’s public certificate (i.e., presented to the peer), and `key.pem` is the corresponding private key. The `root-cert.pem` file is Istio Auth's root certificate, used to verify peers` certificates.

### Disabling Authentication when Things Go Astray

If, for some reason, mTLS is not functional, the Guestbook application will not operate correctly. This would be evident in its UI (e.g., it would display a [`Waiting for database connection`](waiting_on_database.png) message). In that case, mTLS should be disabled.

mTLS it can be disabled globally or per service.

* To disable mTLS for all services in the mesh, comment out the `authPolicy` settings in the mesh configuration:

```sh
kubectl edit configmap istio -o yaml -n istio-system
...
apiVersion: v1
data:
  mesh: |-
    # Uncomment the following line to enable mutual TLS between proxies
    # authPolicy: MUTUAL_TLS
    ...
```

* To disable mTLS for connections accessing a specific service (since mTLS is triggered by the server-side proxy requesting a client certificate), add an `auth.istio.io/<port#>: NONE` annotation to the service definition:

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

Note that the annotations can also be used to gradually enable mTLS on individual services.

## Further Reading

* [Basic TLS/SSL Terminology](https://dzone.com/articles/tlsssl-terminology-and-basics)

* [TLS Handshake Explained](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.1.0/com.ibm.mq.doc/sy10660_.htm)

* [Istio Task](https://istio.io/docs/tasks/security/mutual-tls.html)

* [Istio Concept](https://istio.io/docs/concepts/security/mutual-tls.html)

#### [Continue to Exercise 8 - Policy Enforcement ](../exercise-8/README.md)
