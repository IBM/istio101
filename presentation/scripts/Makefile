SHELL := /bin/bash
REGISTRY := cmluciano/istio-intro
VERSION ?= $(shell git describe --tags --always --dirty)

# WARNING: This command contains a MacOS workaround for cluster certificates
# WARNING: ClusterSigningCertFile & ClusterSigningKeyFile may not work on non-MacOS platforms
#
# Starts minikube with all Istio required flags and required k8s version
minikube:
	minikube start \
	--extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
	--extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key" \
	--extra-config=apiserver.Admission.PluginNames=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota \
	--kubernetes-version=v1.9.0

# Downloads latest Istio tarball and copies contents into root of scripts dir
download:
	curl -L https://git.io/getLatestIstio | sh -
	cp -r ./istio-0.5.0/* .

# Deploys entire Istio control plane
# Should be followed by `make injector-all`
setup:
	kubectl apply -f ./install/kubernetes/istio.yaml

# Poll every 3 seconds to check pod statuses
# CTRL-C exits the loop
watch:
	watch -n3 kubectl get pods --all-namespaces

# Hack to copy scripts not included in Istio release
copy-scripts:
	cp ./webhook* ./install/kubernetes/.

# Create signed key/cert for Istio Sidecar-Injector
# K8s requires all webhooks to have a signed key/cert
create-cert:
	./install/kubernetes/webhook-create-signed-cert.sh \
	    --service istio-sidecar-injector \
	    --namespace istio-system \
	    --secret sidecar-injector-certs

# Ensure generated certificate is valid
check-cert:
	kubectl -n istio-system get certificatesigningrequest

# Deploy release version of Istio Sidecar-Injector configuration settings
deploy-configmap:
	kubectl apply -f install/kubernetes/istio-sidecar-injector-configmap-release.yaml

# Ensure Istio Sidecar-Injector is created
check-configmap:
	kubectl -n istio-system get cm istio-inject

# Sets the caBundle for the webhook for the k8s-apiserver to leverage when calling the hook
create-cabundle:
	cat install/kubernetes/istio-sidecar-injector.yaml | \
	     ./install/kubernetes/webhook-patch-ca-bundle.sh > \
	     ./install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

# Deploy the actual Istio Sidecar-Injector
deploy-injector:
	kubectl apply -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

check-injector:
	kubectl -n istio-system get deployment -listio=sidecar-injector

# Label default namespace so Istio Sidecar-Injector will automatically inject Envoy proxy
label-default:
	kubectl label namespace default istio-injection=enabled
	kubectl get namespace -L istio-injection

# One command deploy for Istio Sidecar-Injector 
injector-all: create-cert deploy-configmap create-cabundle deploy-injector label-default

# Deploy all demo applications
deploy-demos:
	kubectl apply -f ./install/kubernetes/addons/prometheus.yaml
	kubectl apply -f ./install/kubernetes/addons/grafana.yaml
	kubectl apply -f ./install/kubernetes/addons/zipkin.yaml
	kubectl apply -f ./samples/httpbin/httpbin.yaml
	kubectl apply -f ./samples/bookinfo/kube/bookinfo.yaml
	kubectl apply -f ./samples/httpbin/sample-client/fortio-deploy.yaml
