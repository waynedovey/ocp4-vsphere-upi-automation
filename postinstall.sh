#!/bin/bash
export KUBECONFIG=/root/ocp4-vsphere-upi-automation/install-dir/auth/kubeconfig

rm -fr postinstall/users.htpasswd
htpasswd -c -B -b postinstall/users.htpasswd admin redhat 

oc create secret generic htpass-secret --from-file=htpasswd=./postinstall/users.htpasswd -n openshift-config

oc apply -f ./postinstall/HTPasswd.yml
oc adm policy add-cluster-role-to-user cluster-admin admin

# OCS Storage 
##oc patch storageclass thin -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "false"}}}'

for I in `oc get node | grep storage | awk '{print $1}'`;
 do 
   oc label node/$I role=storage-node;
   oc adm drain $I --ignore-daemonsets --delete-local-data;
   oc adm uncordon $I;
done

oc create -f postinstall/rhocs-namespace.yaml
oc create -f postinstall/rhocs-operatorgroup.yaml
oc project openshift-storage
