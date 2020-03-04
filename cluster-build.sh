#!/bin/bash

# Cleanup:
rm -fr install-dir bin downloads
mkdir -p {install-dir,bin,downloads}

# Run Ansible setup-ocp-vsphere playbook:
ansible-playbook -e @vars.yml setup-ocp-vsphere.yml --vault-password-file=../ocp4-vsphere-upi-automation-vault.yml

# Copy Ignition file to the Apache's ignition folder under DocumentRoot on the helper node:
scp install-dir/bootstrap.ign root@192.168.0.2:/var/www/html/ignition

# Run Ansible setup-vcenter-vms playbook:
ansible-playbook -e @vars.yml setup-vcenter-vms.yml --vault-password-file=../ocp4-vsphere-upi-automation-vault.yml
