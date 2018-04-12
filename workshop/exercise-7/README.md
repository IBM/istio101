# Exercise 7 - Security

## Mutual Authentication with Transport Layer Security (mTLS)

Istio can secure the communication between microservices without requiring application code changes.

Istio Auth is an optional part of Istio's control plane components. When enabled, it provides each Envoy sidecar proxy with a strong (cryptographic) identity, in the form of certificates.
Identity is based on the microservice's role (specifically, the service account it runs under) and is independent of its specific network location, such as cluster or current IP address.
Envoys then use these certificates to identify each other and establish an authenticated and encrypted communication channel between them.

Istio Auth is responsible for:

* Providing each service with an identity representing its role;

* Providing a common trust root to allow Envoys to validate and authenticate each other; and

* Providing a key management system, automating generation, distribution, and rotation of certificates and keys.

When an application microservice connects to another microservice, the communication is tunneled through the client side and server side Envoys. The end-to-end communication flow is:

* Local TCP connection (i.e., `localhost`, not reaching the "wire") between the application and Envoy (client- and server-side);

* Mutually authenticated and encrypted connection between Envoy proxies;

When Envoy's establish a connection, they exchange and validate certificates to confirm that each is indeed connected to a valid and expected peer. The established identities can later be used as basis for policy checks (e.g., access authorization).

## Steps

### Verifying Istio’s mTLS Setup

Verify the cluster-level CA is running:

```sh
kubectl get deploy -l istio=istio-ca -n istio-system
```

Istio CA is up if the “AVAILABLE” column is 1. For example:
```sh
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
istio-ca   1         1         1            1           1m
```

### Verify AuthPolicy Ssetting in ConfigMap

```sh
kubectl get configmap istio -o yaml -n istio-system | grep authPolicy | head -1
```

Istio mutual TLS authentication is enabled if the line `authPolicy: MUTUAL_TLS` is uncommented (i.e., doesn’t have a `#`).

### Trying out the Authenticated Connection

One way to try out the mutual TLS authentication communication, is to use curl in one service’s envoy proxy to send request to other services. For example, after starting the Helloworld application you can ssh into the Envoy container of Helloworld service, and send request to guestbook service by curl.

1. get the Helloworld pod name

```sh
kubectl get pods -l app=guestbook-ui
NAME                            READY     STATUS    RESTARTS   AGE
guestbook-ui-596d68d88f-qxhzk   2/2       Running   1          1h
```

Make sure the pod is “Running”.

1. ssh into the envoy container

```sh
kubectl exec -it guestbook-ui-xxxxxxxx -c istio-proxy /bin/bash
```

Make sure to change the pod name into the corresponding one on your system. This command will ssh into istio-proxy container(sidecar) of the pod.

1. check out the certificate and keys are present

```sh
ls /etc/certs/ 
```

You should see

```sh
cert-chain.pem   key.pem   root-cert.pem
```

Note that `cert-chain.pem` is Envoy’s public certificate (i.e., presented to the peer), and `key.pem` is the corresponding private key. The `root-cert.pem` file is Istio Auth's root certificate, used to verify peers` certificates.

1. send request to the guestbook-ui service

```sh
curl https://guestbook-service:8080 -v --key /etc/certs/key.pem --cert /etc/certs/cert-chain.pem --cacert /etc/certs/root-cert.pem -k
```

From the output there will be some error message `error fetching CN from cert:The requested data were not available`. This is expected.
Go to the bottom and there you will see the success message.

```sh
< HTTP/1.1 200 OK
< x-application-context: helloworld-service
< content-type: application/json;charset=UTF-8
< date: Thu, 01 Feb 2018 06:12:46 GMT
...
```

## Further Reading

* [Basic TLS/SSL Terminology](https://dzone.com/articles/tlsssl-terminology-and-basics)

* [TLS Handshake Explained](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.1.0/com.ibm.mq.doc/sy10660_.htm)

* [Istio Task](https://istio.io/docs/tasks/security/mutual-tls.html)

* [Istio Concept](https://istio.io/docs/concepts/security/mutual-tls.html)