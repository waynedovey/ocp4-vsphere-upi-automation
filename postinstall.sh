#!/bin/bash

DISCONNECTED=false
OCS_SETTING=false
HTTP_AUTH_SETTING=true
LDAP_AUTH_SETTING=false
NFS_STORAGE_SETTING=false
BUILD_LAB=gsslab

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

# Enable HTPassword Auth
if [ "$1" != "--silent" ]; then
    printf "Confirm HTPassword Auth true/false: (Press ENTER for default: ${HTTP_AUTH_SETTING})\n"
    read -r HTTP_AUTH_CHOICE
    if [ "${HTTP_AUTH_CHOICE}" == "true" ]; then
        HTTP_AUTH_SETTING=true
    elif [ "${HTTP_AUTH_CHOICE}" == "false" ]; then
        HTTP_AUTH_SETTING=false
    elif [ "${HTTP_AUTH_CHOICE}" != "" ]; then
        HTTP_AUTH_SETTING=true
    fi
fi
printf "* HTPassword Auth Setting: ${HTTP_AUTH_SETTING}\n\n"

# Enable LDAP Auth
if [ "$1" != "--silent" ]; then
    printf "Confirm LDAP Auth true/false: (Press ENTER for default: ${LDAP_AUTH_SETTING})\n"
    read -r LDAP_AUTH_CHOICE
    if [ "${LDAP_AUTH_CHOICE}" == "true" ]; then
        LDAP_AUTH_SETTING=true
    elif [ "${LDAP_AUTH_CHOICE}" == "false" ]; then
        LDAP_AUTH_SETTING=false
    elif [ "${LDAP_AUTH_CHOICE}" != "" ]; then
        LDAP_AUTH_SETTING=false
    fi
fi
printf "* LDAP Auth Setting: ${LDAP_AUTH_SETTING}\n\n"

# Enable NFS Storage
if [ "$1" != "--silent" ]; then
    printf "Confirm NFS Storage true/false: (Press ENTER for default: ${NFS_STORAGE_SETTING})\n"
    read -r NFS_STORAGE_CHOICE
    if [ "${NFS_STORAGE_CHOICE}" == "true" ]; then
        NFS_STORAGE_SETTING=true
    elif [ "${NFS_STORAGE_CHOICE}" == "false" ]; then
        NFS_STORAGE_SETTING=false
    elif [ "${NFS_STORAGE_CHOICE}" != "" ]; then
        NFS_STORAGE_SETTING=false
    fi
fi
printf "* NFS Storage Setting: ${NFS_STORAGE_SETTING}\n\n"

# Run Ansible post-install playbook:
ansible-playbook -e "disconnected_setting=${DISCONNECTED} ocs_setting=${OCS_SETTING} enable_htpasswd_auth=${HTTP_AUTH_SETTING} enable_ldap_auth=${LDAP_AUTH_SETTING} enable_nfs_storage=${NFS_STORAGE_SETTING} BUILD_LAB=${BUILD_LAB}" \
-e @./vars/vars-${BUILD_LAB}.yml post-install.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml \
--skip-tag=14,15,16,17,18,19,20,21,22,23,24 \
--skip-tags=6,7
