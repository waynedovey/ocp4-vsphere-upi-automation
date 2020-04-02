#!/bin/bash

BUILD_LAB=gsslab

# Cleanup:
rm -fr roles

# Set the Cluster 
if [ "$1" != "--silent" ]; then
    printf "Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: ${BUILD_LAB})\n"
    read -r BUILD_LAB_CHOICE
    if [ "${BUILD_LAB_CHOICE}" != "" ]; then
        BUILD_LAB=${BUILD_LAB_CHOICE}
    fi
fi
printf "* Cluster Name: ${BUILD_LAB}\n\n"

mkdir -p roles
git clone https://github.com/waynedovey/ocp4-upi-helpernode.git roles/ocp4-upi-helpernode
git clone https://github.com/waynedovey/389-ldap-server.git roles/389-ldap-server

# CreateHelper Node 
ansible-playbook -e @./vars/vars-helpernode-${BUILD_LAB}.yaml setup-helpernode.yml
