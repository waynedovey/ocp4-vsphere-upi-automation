#!/bin/bash

DEFAULT_OCPVERSION=4.3.8
DEFAULT_CLUSTERSIZE=small
WORKER_MEMORY=8192
WORKER_CPU=2

# Cleanup:
#rm -fr install-dir bin downloads
#mkdir -p {install-dir,bin,downloads}

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
    printf "Enter OpenShift Cluster Size (small [8gb,2vcpu],medium [32gb,4vcpu],large [64gb,8vcpu]): (Press ENTER for default: ${DEFAULT_CLUSTERSIZE} ${SMALL_CLUSTER})\n"
    read -r CLUSTER_SIZE
    if [ "${CLUSTER_SIZE}" == "medium" ]; then
        WORKER_MEMORY=32768;
        WORKER_CPU=4;
    elif [ "${CLUSTER_SIZE}" == "large" ]; then
        WORKER_MEMORY=65536;
        WORKER_CPU=8;
    elif [ "${CLUSTER_SIZE}" != "" ]; then
        CLUSTER_SIZE=${DEFAULT_CLUSTERSIZE};
        WORKER_MEMORY=8192;
        WORKER_CPU=2;
    fi
fi
printf "* Using: ${CLUSTER_SIZE} Cluster Settings Memory ${WORKER_MEMORY} CPU ${WORKER_CPU}\n\n"

# Disconnected 
if [ "$1" != "--silent" ]; then
    printf "Enter OpenShift Version: (Press ENTER for default: ${DEFAULT_OCPVERSION})\n"
    read -r OCPVERSION_CHOICE
    if [ "${OCPVERSION_CHOICE}" != "" ]; then
        DEFAULT_OCPVERSION=${OCPVERSION_CHOICE}
    fi
fi
printf "* Using: ${DEFAULT_OCPVERSION}\n\n"

# Run Ansible setup-ocp-vsphere playbook:
#ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION}" -e @./vars/vars-pek2lab.yml setup-ocp-vsphere.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml --skip-tags=2

# Copy Ignition file to the Apache's ignition folder under DocumentRoot:
#cp install-dir/bootstrap.ign /var/www/html/ignition
#chmod 644 /var/www/html/ignition/bootstrap.ign

# Run Ansible setup-vcenter-vms playbook:
#ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION} worker_memory=${WORKER_MEMORY} worker_cpu=${WORKER_CPU}"  -e @./vars/vars-pek2lab.yml setup-vcenter-vms.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml -vvv
