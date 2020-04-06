#!/bin/bash

DEFAULT_OCPVERSION=4.3.8
WORKER_SIZE=small
WORKER_MEMORY=8192
WORKER_CPU=2
DISCONNECTED=false
OCS_SETTING=false
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

# Set Node size
if [ "$1" != "--silent" ]; then
    printf "Enter OpenShift Worker Node Size (small [8gb,2vcpu],medium [32gb,4vcpu],large [64gb,8vcpu]): (Press ENTER for default: ${WORKER_SIZE} ${SMALL_CLUSTER})\n"
    read -r WORKER_SIZE
    if [ "${WORKER_SIZE}" == "medium" ]; then
        WORKER_MEMORY=32768
        WORKER_CPU=4
    elif [ "${WORKER_SIZE}" == "large" ]; then
        WORKER_MEMORY=65536
        WORKER_CPU=8
    elif [ "${WORKER_SIZE}" != "" ]; then
        WORKER_SIZE=${WORKER_SIZE};
        WORKER_MEMORY=8192
        WORKER_CPU=2
    fi
fi
printf "* Using: ${WORKER_SIZE} Cluster Settings Memory ${WORKER_MEMORY} CPU ${WORKER_CPU}\n\n"

# Update the Helper Node 
ansible-playbook -e @./vars/vars-helpernode-${BUILD_LAB}.yaml setup-helpernode.yml

# Run Ansible scale-node-vsphere playbook:
ansible-playbook -e "worker_memory=${WORKER_MEMORY} worker_cpu=${WORKER_CPU} BUILD_LAB=${BUILD_LAB}" -e @./vars/vars-${BUILD_LAB}.yml scale-up-nodes-vsphere.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml
