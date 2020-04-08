#!/bin/bash

DEFAULT_OCPVERSION=4.3.8
CLUSTER_SIZE=small
WORKER_MEMORY=8192
WORKER_CPU=2
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

# Set the OCP version
if [ "$1" != "--silent" ]; then
    printf "Enter OpenShift Version: (Press ENTER for default: ${DEFAULT_OCPVERSION})\n"
    read -r OCPVERSION_CHOICE
    if [ "${OCPVERSION_CHOICE}" != "" ]; then
        DEFAULT_OCPVERSION=${OCPVERSION_CHOICE}
    fi
fi
printf "* Using: ${DEFAULT_OCPVERSION}\n\n"

# Set Cluster size
if [ "$1" != "--silent" ]; then
    printf "Enter OpenShift Cluster Size (small [8gb,2vcpu],medium [32gb,4vcpu],large [64gb,8vcpu]): (Press ENTER for default: ${CLUSTER_SIZE} ${SMALL_CLUSTER})\n"
    read -r CLUSTER_SIZE
    if [ "${CLUSTER_SIZE}" == "medium" ]; then
        WORKER_MEMORY=32768
        WORKER_CPU=4
    elif [ "${CLUSTER_SIZE}" == "large" ]; then
        WORKER_MEMORY=65536
        WORKER_CPU=8
    elif [ "${CLUSTER_SIZE}" != "" ]; then
        CLUSTER_SIZE=${CLUSTER_SIZE};
        WORKER_MEMORY=8192
        WORKER_CPU=2
    fi
fi
printf "* Using: ${CLUSTER_SIZE} Cluster Settings Memory ${WORKER_MEMORY} CPU ${WORKER_CPU}\n\n"

# Disconnected
if [ "$1" != "--silent" ]; then
    printf "Enter OpenShift Disconnected setting true/false: (Press ENTER for default: ${DISCONNECTED})\n"
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
    printf "Enable OpenShift Container Storage (OCS) true/false: (Press ENTER for default: ${OCS_SETTING})\n"
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

# Run Ansible setup-ocp-vsphere playbook:
ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION} disconnected_setting=${DISCONNECTED} ocs_setting=${OCS_SETTING}" -e @./vars/vars-${BUILD_LAB}.yml setup-ocp-vsphere.yml

# Copy Ignition file to the Apache's ignition folder under DocumentRoot:
cp install-dir/bootstrap.ign /var/www/html/ignition
chmod 644 /var/www/html/ignition/bootstrap.ign

# Run Ansible setup-vcenter-vms playbook:
ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION} worker_memory=${WORKER_MEMORY} worker_cpu=${WORKER_CPU} disconnected_setting=${DISCONNECTED} ocs_setting=${OCS_SETTING}" -e @./vars/vars-${BUILD_LAB}.yml setup-vcenter-vms.yml

# Wait for a Cluster Build Status
ansible-playbook -e "BUILD_LAB=${BUILD_LAB}" -e @./vars/vars-${BUILD_LAB}.yml cluster-status.yml
