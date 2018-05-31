#!/bin/bash

# Install istio control plane
kubectl apply -f ./install/kubernetes/istio.yaml

echo "Confirm that all services started successfully under istio-system"
read -n 1 -s -r -p "Press any key to continue"
# Create signed key/cert for Istio Sidecar-Injector
# K8s requires all webhooks to have a signed key/cert
./install/kubernetes/webhook-create-signed-cert.sh \
    --service istio-sidecar-injector \
    --namespace istio-system \
    --secret sidecar-injector-certs

# Ensure generated certificate is valid
kubectl -n istio-system get certificatesigningrequest

# Deploy release version of Istio Sidecar-Injector configuration settings
kubectl apply -f install/kubernetes/istio-sidecar-injector-configmap-release.yaml

# Ensure Istio Sidecar-Injector is created
kubectl -n istio-system get cm istio-inject

# Sets the caBundle for the webhook for the k8s-apiserver to leverage when calling the hook
cat install/kubernetes/istio-sidecar-injector.yaml | \
    ./install/kubernetes/webhook-patch-ca-bundle.sh > \
    ./install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

# Deploy the actual Istio Sidecar-Injector
kubectl apply -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml
kubectl -n istio-system get deployment -listio=sidecar-injector
kubectl label namespace default istio-injection=enabled
kubectl get namespace -L istio-injection

echo "Confirm that istio-sidecar started successfully under istio-system"
read -n 1 -s -r -p "Press any key to continue"
# Deploy all demo application
kubectl apply -f ./install/kubernetes/addons/prometheus.yaml
kubectl apply -f ./install/kubernetes/addons/grafana.yaml
kubectl apply -f ./install/kubernetes/addons/zipkin.yaml
kubectl apply -f ./samples/httpbin/httpbin.yaml
kubectl apply -f ./samples/bookinfo/kube/bookinfo.yaml
kubectl apply -f ./samples/httpbin/sample-client/fortio-deploy.yaml
