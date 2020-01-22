#!/bin/bash
rm -fr install-dir
mkdir install-dir
ansible-playbook -e @vars.yml setup-ocp-vsphere.yml --vault-password-file=../ocp4-vsphere-upi-automation-vault.yml

scp install-dir/bootstrap.ign root@192.168.0.2:/var/www/html/ignition

ansible-playbook -e @vars.yml setup-vcenter-vms.yml --vault-password-file=../ocp4-vsphere-upi-automation-vault.yml
