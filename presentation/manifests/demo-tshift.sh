#!/bin/bash

echo "Ready to create and view routerulev1"
read -n 1 -s -r -p "Press any key to continue"
kubectl apply -f ../scripts/samples/bookinfo/kube/route-rule-all-v1.yaml
echo "RouteRulev1 ###########################
#############################################
#############################################"
cat ../scripts/samples/bookinfo/kube/route-rule-all-v1.yaml

echo "Ready to switch jason to v2"
read -n 1 -s -r -p "Press any key to continue"
kubectl apply -f ../scripts/samples/bookinfo/kube/route-rule-reviews-test-v2.yaml
echo "Jasonv2 ###########################
#############################################
#############################################"
cat ../scripts/samples/bookinfo/kube/route-rule-reviews-test-v2.yaml

echo "Ready to cleanup all routerules for Traffic Shaping"
read -n 1 -s -r -p "Press any key to continue"
kubectl delete -f ../scripts/samples/bookinfo/kube/route-rule-all-v1.yaml
kubectl delete -f ../scripts/samples/bookinfo/kube/route-rule-reviews-test-v2.yaml
