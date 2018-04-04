## Istio Setup

These notes are for information and are not necessarily designed to be shown in the demo. This should be set up ahead of presentation start.

### Prerequisites

- [minikube 0.25.0](https://github.com/kubernetes/minikube#installation)
- openssl (Tested with LibreSSL 2.2.7)
- Make
- [kubectl v1.9](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl)
  - MacOS: `brew update; brew install kubectl`
- [istioctl Installation steps 2 & 4](https://istio.io/docs/setup/kubernetes/quick-start.html)
- Istio 0.5.0 
  - `make download` from the scripts directory

### Minikube Environment

- WARNING: This command contains a MacOS workaround for cluster certificates
- WARNING: ClusterSigningCertFile & ClusterSigningKeyFile may not work on non-MacOS platforms

minikube:
```shell
minikube start \
	--extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
	--extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key" \
	--extra-config=apiserver.Admission.PluginNames=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota \
	--kubernetes-version=v1.9.0
```

### Demo Preparation

Run the following commands from the scripts directory or simply run the [setup script](./scripts/setup.sh)

- Deploy Istio control plane (sometimes need to run twice due to CRD create race conditions)

```shell
make setup
```

- Deploy Istio Sidecar-Injector

```shell
make injector-all
```

- Open k8s-dashboard to ensure applications in istio-system namespace deployed properly

```shell
minikube dashboard
```

- Deploy all demo applications (do this way ahead of time to be sure everything comes up properly before you start demo'ing)

```shell
make deploy-demos
```
