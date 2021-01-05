# Exercise 7 - Secure your services

## Mutual authentication with Transport Layer Security (mTLS)

Istio can secure the communication between microservices without requiring application code changes. Security is provided by authenticating and encrypting communication paths within the cluster. This is becoming a common security and compliance requirement. Delegating communication security to Istio (as opposed to implementing TLS in each microservice), ensures that your application will be deployed with consistent and manageable security policies.

Istio Citadel is an optional part of Istio's control plane components. When enabled, it provides each Envoy sidecar proxy with a strong (cryptographic) identity, in the form of a certificate.
Identity is based on the microservice's service account and is independent of its specific network location, such as cluster or current IP address.
Envoys then use the certificates to identify each other and establish an authenticated and encrypted communication channel between them.

Citadel is responsible for:

* Providing each service with an identity representing its role.

* Providing a common trust root to allow Envoys to validate and authenticate each other.

* Providing a key management system, automating generation, distribution, and rotation of certificates and keys.

When an application microservice connects to another microservice, the communication is redirected through the client side and server side Envoys. The end-to-end communication path is:

* Local TCP connection (i.e., `localhost`, not reaching the "wire") between the application and Envoy (client- and server-side);

* Mutually authenticated and encrypted connection between Envoy proxies.

When Envoy proxies establish a connection, they exchange and validate certificates to confirm that each is indeed connected to a valid and expected peer. The established identities can later be used as basis for policy checks (e.g., access authorization).

## Enforce mTLS between all Istio services

1. To enforce a mesh-wide authentication policy that requires mutual TLS, submit the following policy. This policy specifies that all workloads in the mesh will only accept encrypted requests using TLS.

```shell
kubectl apply -f - <<EOF
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
  namespace: "istio-system"
spec:
  mtls:
    mode: STRICT
EOF
```

1. Visit your guestbook application by going to it in your browser. Everything should be working as expected! To confirm mTLS is infact enabled, you can run:

  ```shell
  istioctl x describe service guestbook
  ```

  Example output:

  ```yaml
  Service: guestbook
    Port: http 80/HTTP targets pod port 3000
  DestinationRule: destination-rule-guestbook for "guestbook"
    Matching subsets: v1,v2
    No Traffic Policy
  Pod is STRICT, clients configured automatically
  ```

## Configure access control for workloads using HTTP traffic

1. Modify guestbook and analyzer deployments to use leverage the service accounts.

    * Navigate to your guestbook dir first, for example:

    ```shell
    cd ../guestbook
    ```

    * Add serviceaccount to your guestbook and analyzer deployments

    ```shell
    echo "      serviceAccountName: guestbook" >> v1/guestbook-deployment.yaml
    echo "      serviceAccountName: guestbook" >> v2/guestbook-deployment.yaml
    echo "      serviceAccountName: analyzer" >> v2/analyzer-deployment.yaml
    ```

    * redeploy the guestbook and analyzer deployments

    ```shell
    kubectl replace -f v1/guestbook-deployment.yaml
    kubectl replace -f v2/guestbook-deployment.yaml
    kubectl replace -f v2/analyzer-deployment.yaml
    ```

1. Create a `AuthorizationPolicy` to disable all access to analyzer service.  This will effectively not allow guestbook or any services to access it.

```shell
cat <<EOF | kubectl create -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: analyzeraccess
spec:
  selector:
    matchLabels:
      app: analyzer
EOF
```

Output:

```shell
authorizationpolicy.security.istio.io/analyzeraccess created
```

1. Visit the Guestbook app from your favorite browser and validate that Guestbook V1 continues to work while Guestbook V2 will not run correctly. For every new message you write on the Guestbook v2 app, you will get a message such as "Error - unable to detect Tone from the Analyzer service".  It can take up to 15 seconds for the change to propogate to the envoy sidecar(s) so you may not see the error right away.

1. Configure the Analyzer service to only allow access from the Guestbook service using the added `rules` section:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: analyzeraccess
spec:
  selector:
    matchLabels:
      app: analyzer
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/guestbook"]
    to:
    - operation:
        methods: ["POST"]
EOF
```

1. Visit the Guestbook app from your favorite browser and validate that Guestbook V2 works now.  It can take a few seconds for the change to propogate to the envoy sidecar(s) so you may not observe Guestbook V2 to function right away.

## Cleanup

Run the following commands to clean up the Istio configuration resources as part of this exercise:

```shell
kubectl delete PeerAuthentication default
kubectl delete dr default
kubectl delete dr destination-rule-guestbook
kubectl delete sa guestbook analyzer
kubectl delete AuthorizationPolicy analyzeraccess
```

## Quiz

**True or False?**

1. Istio Citadel provides each microservice with a strong, cryptographic, identity in the form of a certificate. The certificates' life cycle is fully managed by Istio. (True)

2. Istio provides microservices with mutually authenticated connections, without requiring app code changes. (True)

3. Mutual authentication must be on or off for the entire cluster, gradual adoption is not possible. (False)

## Further Reading

* [Basic TLS/SSL Terminology](https://dzone.com/articles/tlsssl-terminology-and-basics)

* [TLS Handshake Explained](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.1.0/com.ibm.mq.doc/sy10660_.htm)

* [Istio Task](https://istio.io/latest/docs/tasks/security/)

* [Istio Concept](https://istio.io/docs/concepts/security/mutual-tls.html)
