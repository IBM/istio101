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

1. Ensure Citadel is running

    Citadel is Istio's in-cluster Certificate Authority (CA) and is required for generating and managing cryptographic identities in the cluster.
    Verify Citadel is running:

    ```shell
    kubectl get deployment -l istio=citadel -n istio-system
    ```

    Expected output:

    ```shell
    NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    istio-citadel   1         1         1            1           15h
    ```

2. Define mTLS Authentication Policy

   First, we create a `MeshPolicy` for configuring the receiving end to use mTLS. The following two destination rules will then configure the client side to use mTLS. We'll update the previously created DestinationRule to include mTLS and create a new blanket rule (`*.local`) for all other services. Run the following command to enable mTLS across your cluster:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: "authentication.istio.io/v1alpha1"
kind: "MeshPolicy"
metadata:
  name: "default"
spec:
  peers:
  - mtls: {}
---
apiVersion: "networking.istio.io/v1alpha3"
kind: "DestinationRule"
metadata:
  name: "default"
spec:
  host: "*.local"
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: destination-rule-guestbook
spec:
  host: guestbook
  subsets:
  - name: v1
    labels:
      version: "1.0"
  - name: v2
    labels:
      version: "2.0"
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
EOF
```
   
   You should see:
    
   ```shell
    meshpolicy.authentication.istio.io/default created
    destinationrule.networking.istio.io/destination created
    destinationrule.networking.istio.io/destination-rule-guestbook configured
   ```

   Confirm the policy for the receiving services to use mTLS has been created:
    
   ```shell
   kubectl get meshpolicies
   ```
   
   Output:
   
   ```shell
   NAME              AGE
   default           1m
   ```

   Confirm the destination rules for client-side mTLS has been created:
     
   ```shell
   kubectl get destinationrules
   ```
   
   Output:
    
   ```shell
   NAME                         HOST        AGE
   destination                  *.local     3m21s
   destination-rule-guestbook   guestbook   3m21s
   ```

## Verifying the Authenticated Connection

If mTLS is working correctly, the Guestbook app should continue to operate as expected, without any user visible impact. Istio will automatically add (and manage) the required certificates and private keys. 

To verify this, you can use an experimental `istioctl` feature to describe pods.

<!-- First, ensure you are using the latest version of `istioctl`:

```shell
curl -sL https://istio.io/downloadIstioctl | sh -
export PATH=$HOME/.istioctl/bin:$PATH
```

Verify it's installed properly:

```shell
istioctl version --remote=false
```

Output:
```shell
1.4.2
``` -->

1. First, get your pods:

    ```shell
    kubectl get pods
    ```

2. Copy the name of the guestbook v2 pod, for exmaple: `guestbook-v2-f9f597d8d-zbhkt`.

    ```shell
    istioctl x describe pod guestbook-v2-f9f597d8d-zbhkt
    ```

3. You should see something like this:

    ```shell
    Pod: guestbook-v2-f9f597d8d-zbhkt
      Pod Ports: 3000 (guestbook), 15090 (istio-proxy)
    --------------------
    Service: guestbook
      Port: http 80/HTTP targets pod port 3000
    DestinationRule: destination-rule-guestbook for "guestbook"
      Matching subsets: v2
          (Non-matching subsets v1)
      Traffic Policy TLS Mode: ISTIO_MUTUAL
    Pod is STRICT and clients are ISTIO_MUTUAL

    Exposed on Ingress Gateway http://159.23.74.230
    VirtualService: virtual-service-guestbook
      1 HTTP route(s)
    ```

You'll see that the pod policy is "STRICT" and clients are "ISTIO_MUTUAL". In addition, note `Traffic Policy TLS Mode: ISTIO_MUTUAL`.

## Control Access to the Analyzer Service

Istio support Role Based Access Control(RBAC) for HTTP services in the service mesh.  Let's leverage this to configure access among guestbook and analyzer services.

1. Create service accounts for the guestbook and analyzer services.

    ```shell
    kubectl create sa guestbook
    kubectl create sa analyzer
    ```

2. Modify guestbook and analyzer deployments to use leverage the service accounts.

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

3. Create a `AuthorizationPolicy` to disable all access to analyzer service.  This will effectively not allow guestbook or any services to access it.

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
    
4.  Visit the Guestbook app from your favorite browser and validate that Guestbook V1 continues to work while Guestbook V2 will not run correctly. For every new message you write on the Guestbook v2 app, you will get a message such as "Error - unable to detect Tone from the Analyzer service".  It can take up to 15 seconds for the change to propogate to the envoy sidecar(s) so you may not see the error right away.

5. Configure the Analyzer service to only allow access from the Guestbook service using the added `rules` section:

```
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

6.  Visit the Guestbook app from your favorite browser and validate that Guestbook V2 works now.  It can take a few seconds for the change to propogate to the envoy sidecar(s) so you may not observe Guestbook V2 to function right away.

## Cleanup

Run the following commands to clean up the Istio configuration resources as part of this exercise:

```shell
kubectl delete MeshPolicy default
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

* [Istio Task](https://istio.io/docs/tasks/security/mutual-tls.html)

* [Istio Concept](https://istio.io/docs/concepts/security/mutual-tls.html)

## [Continue to Exercise 8 - Policy Enforcement](../exercise-8/README.md)
