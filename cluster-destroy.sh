#!/bin/bash

BUILD_LAB=gsslab

# Cleanup:
rm -fr install-dir bin downloads
mkdir -p {install-dir,bin,downloads}

# Cluster name
if [ "$1" != "--silent" ]; then
    printf "Specify Cluster Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: ${BUILD_LAB})\n"
    read -r BUILD_LAB_CHOICE
    if [ "${BUILD_LAB_CHOICE}" != "" ]; then
        BUILD_LAB=${BUILD_LAB_CHOICE}
    fi
fi
printf "* Cluster Name: ${BUILD_LAB}\n\n"

# Run Ansible setup-vcenter-vms playbook:
ansible-playbook -e @./vars/vars-${BUILD_LAB}.yml destroy-ocp-vsphere.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml
