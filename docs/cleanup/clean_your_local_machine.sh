#!/bin/bash

echo ''
echo 'You are about to clean up your local machine.'
echo ''
echo 'This includes removing: '
echo ' - the ENV for KUBECONFIG '
echo ' - the file that you exported to KUBECONFIG '
echo ' - the ibmcloud cli'
echo 'You must put in Y as your answer.'
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Y]$ ]]
then
    rm -rf /usr/local/ibmcloud
    rm -f /usr/local/bin/ibmcloud
    rm -f /usr/local/bin/bluemix
    rm -f /usr/local/bin/bx
    rm -f /usr/local/bin/ibmcloud-analytics
    rm $KUBECONFIG
    unset KUBECONFIG
fi
