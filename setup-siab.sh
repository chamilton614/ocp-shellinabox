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

    # Create a ServiceAccount to let our container startup as a privileged pod
    oc create serviceaccount siab
    echo ""

    # As `cluster-admin`, give the ServiceAccount the permission start as an anyuid pod (in our case, `UID 1001` or `developer:developer`)
    oc adm policy add-scc-to-user anyuid -z siab
    echo ""

    ### Deploy the Application
    oc new-app siab --name siab -n ${PROJECT} --allow-missing-imagestream-tags
    echo ""

    # Apply the ServiceAccount to the DeploymentConfig
    oc patch deployment/siab --patch '{"spec":{"template":{"spec":{"serviceAccountName": "siab"}}}}'
    echo ""

    # Expose our shellinabox container
    oc expose svc/siab
    echo ""
    
    # Extend the session idle timeout to 10 minutes
    oc annotate route siab --overwrite haproxy.router.openshift.io/timeout=600s
    echo ""
fi
