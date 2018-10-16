#!/bin/bash

echo ''
echo 'You are about to remove EVERYTHING on your Kubernetes cluster, including Istio.'
echo ''
echo 'You must put in Y as your answer.'
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Y]$ ]]
then
  kubectl delete pods --all
  kubectl delete svc --all
  kubectl delete deployments --all
  kubectl delete configmaps --all
  kubectl delete pods -n istio-system --all
  kubectl delete svc -n istio-system --all
  kubectl delete deployments -n istio-system --all
  kubectl delete namespace istio-system
fi
