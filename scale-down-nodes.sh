#!/bin/bash

BUILD_LAB=gsslab

# Set the Cluster 
if [ "$1" != "--silent" ]; then
    printf "Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: ${BUILD_LAB})\n"
    read -r BUILD_LAB_CHOICE
    if [ "${BUILD_LAB_CHOICE}" != "" ]; then
        BUILD_LAB=${BUILD_LAB_CHOICE}
    fi
fi
printf "* Cluster Name: ${BUILD_LAB}\n\n"

# Remove Nodes
ansible-playbook -e @./vars/vars-helpernode.yaml -e @./vars/vars-${BUILD_LAB}.yml scale-down-nodes-vsphere.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml
