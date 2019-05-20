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

## Enforce mTLS between guestbook and analyzer services

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

   Define mTLS authentication policy for the analyzer service:

```shell
cat <<EOF | kubectl create -f -
apiVersion: authentication.istio.io/v1alpha1
kind: Policy
metadata:
  name: mtls-to-analyzer
  namespace: default
spec:
  targets:
  - name: analyzer
  peers:
  - mtls:
EOF
```
   
   You should see:
    
   ```shell
   policy.authentication.istio.io/mtls-to-analyzer created
   ```

   Confirm the policy has been created:
    
   ```shell
   kubectl get policies.authentication.istio.io
   ```
   
   Output:
   
   ```shell
   NAME              AGE
   mtls-to-analyzer  1m
   ```

3. Enable mTLS from guestbook using a Destination rule

```shell
cat <<EOF | kubectl create -f -
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: route-with-mtls-for-analyzer
  namespace: default
spec:
  host: "analyzer.default.svc.cluster.local"
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
EOF
```
    Output:
    ```
    destinationrule.networking.istio.io/route-with-mtls-for-analyzer created
    ```

## Verifying the Authenticated Connection

If mTLS is working correctly, the Guestbook app should continue to operate as expected, without any user visible impact. Istio will automatically add (and manage) the required certificates and private keys. 

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
cd ../../../guestbook
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

3. Create a RBAC configuration to disable all access to analyzer service.  This will effectively not allow guestbook or any services to access it.

```shell
cat <<EOF | kubectl create -f -
apiVersion: "rbac.istio.io/v1alpha1"
kind: RbacConfig
metadata:
  name: default
spec:
  mode: 'ON_WITH_INCLUSION'
  inclusion:
    services: ["analyzer.default.svc.cluster.local"]
EOF
```

Output:
```
rbacconfig.rbac.istio.io/default created
```
   
4.  Visit the Guestbook app from your favorite browser and validate that Guestbook V1 continue to work while Guestbook V2 will not run correctly.   For every message you wrote on the Guestbook v2 app, you will get a message such as "Error - unable to detect Tone from the Analyzer service".  It can take up to 15 seconds for the change to propogate to the envoy sidecar(s) so you may not see the error right away.

5. Configure the Analyzer service to only allow access from the Guestbook service using service role and service role binding:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: "rbac.istio.io/v1alpha1"
kind: ServiceRole
metadata:
  name: analyzer-viewer
  namespace: default
spec:
  rules:
  - services: ["analyzer.default.svc.cluster.local"]
    methods: ["POST"]
---
apiVersion: "rbac.istio.io/v1alpha1"
kind: ServiceRoleBinding
metadata:
  name: bind-analyzer
  namespace: default
spec:
  subjects:
  - user: "cluster.local/ns/default/sa/guestbook"
  roleRef:
    kind: ServiceRole
    name: "analyzer-viewer"
EOF
```

6.  Visit the Guestbook app from your favorite browser and validate that Guestbook V1 and V2 both work now.  It can take up to 15 seconds for the change to propogate to the envoy sidecar(s) so you may not observe Guestbook V2 to function right away.

## Cleanup

Run the following commands to clean up the Istio configuration resources as part of this exercise:

```shell
kubectl delete policy mtls-to-analyzer
kubectl delete dr route-with-mtls-for-analyzer
kubectl delete rbacconfig default
kubectl delete servicerole analyzer-viewer 
kubectl delete servicerolebinding bind-analyzer
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
