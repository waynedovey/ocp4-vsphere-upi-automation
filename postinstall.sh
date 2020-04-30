#!/bin/bash

DISCONNECTED=false
OCS_SETTING=false
BUILD_LAB=gsslab

# Cleanup:
rm -fr install-dir bin downloads
mkdir -p {install-dir,bin,downloads}

# Set the OCP version
if [ "$1" != "--silent" ]; then
    printf "Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: ${BUILD_LAB})\n"
    read -r BUILD_LAB_CHOICE
    if [ "${BUILD_LAB_CHOICE}" != "" ]; then
        BUILD_LAB=${BUILD_LAB_CHOICE}
    fi
fi
printf "* Cluster Name: ${BUILD_LAB}\n\n"

# Disconnected
if [ "$1" != "--silent" ]; then
    printf "Confirm OpenShift Disconnected setting true/false: (Press ENTER for default: ${DISCONNECTED})\n"
    read -r DISCONNECTED_CHOICE
    if [ "${DISCONNECTED_CHOICE}" == "true" ]; then
        DISCONNECTED=true
    elif [ "${DISCONNECTED_CHOICE}" == "false" ]; then
        DISCONNECTED=false
    elif [ "${DISCONNECTED_CHOICE}" != "" ]; then
        DISCONNECTED=false
    fi
fi
printf "* Disconnected Setting: ${DISCONNECTED}\n\n"

# Storage Nodes
if [ "$1" != "--silent" ]; then
    printf "Confirm OpenShift Container Storage (OCS) true/false: (Press ENTER for default: ${OCS_SETTING})\n"
    read -r OCS_CHOICE
    if [ "${OCS_CHOICE}" == "true" ]; then
        OCS_SETTING=true
    elif [ "${OCS_CHOICE}" == "false" ]; then
        OCS_SETTING=false
    elif [ "${OCS_CHOICE}" != "" ]; then
        OCS_SETTING=false
    fi
fi
printf "* OpenShift Container Storage (OCS) Setting: ${OCS_SETTING}\n\n"

# Run Ansible post-install playbook:
ansible-playbook -e "disconnected_setting=${DISCONNECTED} ocs_setting=${OCS_SETTING} BUILD_LAB=${BUILD_LAB}" \
-e @./vars/vars-${BUILD_LAB}.yml post-install.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml \
--skip-tag=9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24 \
--skip-tags=6,7
