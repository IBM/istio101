#!/bin/bash

kubectl delete -f ./install/kubernetes/addons/prometheus.yaml
kubectl delete -f ./install/kubernetes/addons/grafana.yaml
kubectl delete -f ./install/kubernetes/addons/zipkin.yaml
kubectl delete -f ./samples/httpbin/httpbin.yaml
kubectl delete -f ./samples/bookinfo/kube/bookinfo.yaml
kubectl delete -f ./samples/httpbin/sample-client/fortio-deploy.yaml

kubectl delete -f ./samples/bookinfo/kube/route-rule-all-v1.yaml

kubectl delete -f ./install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

kubectl -n istio-system delete secret sidecar-injector-certs

kubectl delete csr istio-sidecar-injector.istio-system

kubectl label namespace default istio-injection-

kubectl delete -f ./install/kubernetes/istio.yaml

kubectl get pods --all-namespaces
