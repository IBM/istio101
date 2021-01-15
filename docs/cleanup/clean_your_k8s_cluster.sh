#!/bin/bash

echo ''
echo 'You are about to remove Guestbook, Redis and Istio.'
echo ''
echo 'You must put in Y as your answer.'
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Y]$ ]]
then
  ibmcloud ks cluster addon disable istio -f --cluster $MYCLUSTER
  kubectl delete deploy,svc -l app=guestbook
  kubectl delete deploy,svc -l app=redis
  kubectl delete namespace istio-system
fi
