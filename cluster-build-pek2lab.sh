#!/bin/bash

DEFAULT_OCPVERSION=4.3.8

# Cleanup:
rm -fr install-dir bin downloads
mkdir -p {install-dir,bin,downloads}

# Set the OCP version
if [ "$1" != "--silent" ]; then
    printf "Enter OpenShift Version: (Press ENTER for default: ${DEFAULT_OCPVERSION})\n"
    read -r OCPVERSION_CHOICE
    if [ "${OCPVERSION_CHOICE}" != "" ]; then
        DEFAULT_OCPVERSION=${OCPVERSION_CHOICE}
        printf "${DEFAULT_OCPVERSION}" > ./openshift.ver
    fi
fi
if [ -z "${DEFAULT_OCPVERSION}" ]; then
    echo "Please specify a valid verson to continue."
    exit 2
fi
printf "* Using: ${DEFAULT_OCPVERSION}\n\n"

# Run Ansible setup-ocp-vsphere playbook:
ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION}" -e @./vars/vars-pek2lab.yml setup-ocp-vsphere.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml

# Copy Ignition file to the Apache's ignition folder under DocumentRoot:
cp install-dir/bootstrap.ign /var/www/html/ignition
chmod 644 /var/www/html/ignition/bootstrap.ign

# Run Ansible setup-vcenter-vms playbook:
ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION}" -e @./vars/vars-pek2lab.yml setup-vcenter-vms.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml
