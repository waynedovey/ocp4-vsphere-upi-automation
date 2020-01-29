#!/bin/bash
rm -fr install-dir
rm -fr bin
rm -fr downloads
mkdir -p install-dir
mkdir -p bin
mkdir -p downloads
ansible-playbook -e @vars-gsslab.yml setup-ocp-vsphere.yml --vault-password-file=../ocp4-vsphere-upi-automation-vault.yml

cp install-dir/bootstrap.ign /var/www/html/ignition
chmod 644 /var/www/html/ignition/bootstrap.ign

ansible-playbook -e @vars-gsslab.yml setup-vcenter-vms.yml --vault-password-file=../ocp4-vsphere-upi-automation-vault.yml
