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

# Build Node
ansible-playbook -e "BUILD_LAB=${BUILD_LAB}" -e @./vars/vars-${BUILD_LAB}.yml helper-destroy-vsphere.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml

# Update the Helper Node
#ansible-playbook -e @./vars/vars-helpernode-${BUILD_LAB}.yaml setup-helpernode.yml
