#!/bin/bash
export KUBECONFIG=/root/ocp4-vsphere-upi-automation/install-dir/auth/kubeconfig

rm -fr postinstall/users.htpasswd
htpasswd -c -B -b postinstall/users.htpasswd admin redhat 

oc create secret generic htpass-secret --from-file=htpasswd=./postinstall/users.htpasswd -n openshift-config

oc apply -f ./postinstall/HTPasswd.yml
oc adm policy add-cluster-role-to-user cluster-admin admin

