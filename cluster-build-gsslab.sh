#!/bin/bash

# Cleanup:
rm -fr install-dir bin downloads
mkdir -p {install-dir,bin,downloads}

# Run Ansible setup-ocp-vsphere playbook:
ansible-playbook -e @./vars/vars-gsslab.yml setup-ocp-vsphere.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml

# Copy Ignition file to the Apache's ignition folder under DocumentRoot:
cp install-dir/bootstrap.ign /var/www/html/ignition
chmod 644 /var/www/html/ignition/bootstrap.ign

# Run Ansible setup-vcenter-vms playbook:
ansible-playbook -e @./vars/vars-gsslab.yml setup-vcenter-vms.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml
