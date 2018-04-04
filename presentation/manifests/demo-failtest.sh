#!/bin/bash

kubectl apply -f ../scripts/samples/bookinfo/kube/route-rule-all-v1.yaml
echo "Ready to create and view routerulev2"
read -n 1 -s -r -p "Press any key to continue"
kubectl apply -f ./v2reviews.yaml
echo "RouteRulev2 ###########################
#############################################
#############################################"
cat ./v2reviews.yaml

echo "Ready to create and view 2sec latency to ratings backend"
read -n 1 -s -r -p "Press any key to continue"
kubectl apply -f ./2secratings.yaml
echo "Ratings httpFault #####################
#############################################
#############################################"
cat ./2secratings.yaml

echo "Ready to create and view 1 second timeout"
read -n 1 -s -r -p "Press any key to continue"
kubectl apply -f ./1secreviews.yaml
echo "Ratings httpFault #####################
#############################################
#############################################"
cat ./1secreviews.yaml

echo "Ready to cleanup"
read -n 1 -s -r -p "Press any key to continue"
kubectl delete -f ./v2reviews.yaml
kubectl delete -f ./2secratings.yaml
kubectl delete -f ./1secreviews.yaml
