#!/bin/bash

### Set the OpenShift Project to use
PROJECT=$1

### Check if Project was passed in
if  [ -z "${PROJECT}" ]; then
    ### Usage
    echo "setup-siab myproject"
else
    ### Create the Build Config
    oc new-build --strategy docker --binary --docker-image centos:7 --name siab -n ${PROJECT}
    echo ""

    ### Start the Build
    oc start-build siab --from-dir . --follow -n ${PROJECT}
    echo ""

    ### Deploy the Application
    oc new-app siab --name siab -n ${PROJECT} --allow-missing-imagestream-tags
    echo ""
fi
