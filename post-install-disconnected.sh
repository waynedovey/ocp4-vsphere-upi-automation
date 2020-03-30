#!/bin/bash

export KUBECONFIG=/root/ocp4-vsphere-upi-automation/install-dir/auth/kubeconfig

# Get Cluster Status
for i in {1..10}
do
  clusterstatus=$(oc get co | awk '{print $3}' | grep -v AVAILABLE | grep True| wc -l);
  if (($clusterstatus == 27)); then
    echo "Cluster build completed";
    break;
  else
    echo "Cluster still configuring";
    sleep 30;
  fi
done

# Create local user authentication (htpasswd from httpd-tools YUM package):
rm -fr postinstall/users.htpasswd
htpasswd -c -B -b postinstall/users.htpasswd admin redhat
htpasswd -B -b postinstall/users.htpasswd wdovey redhat
htpasswd -B -b postinstall/users.htpasswd lmaly redhat
oc create secret generic htpass-secret --from-file=htpasswd=./postinstall/users.htpasswd -n openshift-config
oc apply -f ./postinstall/HTPasswd.yml
oc adm policy add-cluster-role-to-user cluster-admin admin

# LDAP Auth
#oc create secret generic ldap-secret --from-literal=bindPassword=testuser3 -n openshift-config
#oc apply -f ./postinstall/ldap-auth.yml
#oc adm policy add-cluster-role-to-user cluster-admin testuser3

# Secrets Cleanup kubeadmin
oc delete secrets kubeadmin -n kube-system

for i in {1..10}
do
  authentication=$(oc describe co authentication | grep  -i PROGRESSING  -b1 | grep Status | awk '{print $3}');
  if (($authentication == False )); then
    echo "Authentication completed";
    break;
  else
    echo "Authentication still configuring";
    sleep 30;
  fi
done

# Chrony NTPD master
oc apply -f postinstall/99_masters-chrony-configuration.yml

sleep 20;
for i in {1..50}
do
  number=$(oc describe machineconfigpool master | tail -n7 | grep Ready | awk '{print $4}');
  if (($number == 3)); then
    echo "machineconfigpool Configuration completed";
    break;
  else
    echo "cluster still configuring";
    sleep 30;
  fi
done

# Chrony NTPD Worker
oc apply -f postinstall/99_workers-chrony-configuration.yml

sleep 20;
for i in {1..50}
do
  number=$(oc describe machineconfigpool worker | tail -n7 | grep Ready | awk '{print $4}');
  if (($number == 6)); then
    echo "machineconfigpool Configuration completed";
    break;
  else
    echo "cluster still configuring";
    sleep 30;
  fi
done

# Enable OCS Service
# Label Storage Nodes
for I in `oc get nodes | grep storage | awk '{print $1}'`;
  do oc label nodes $I cluster.ocs.openshift.io/openshift-storage='' --overwrite;
done
# Dedicated Storage Nodes
for I in `oc get nodes | grep storage | awk '{print $1}'`;
  do oc adm taint nodes $I node.ocs.openshift.io/storage=true:NoSchedule --overwrite;
done

# OCS Storage

# Purge Storage nodes
for I in `oc get node | grep storage | awk '{print $1}'`;
 do
   oc adm drain $I --ignore-daemonsets --delete-local-data;
   oc adm uncordon $I;
done

oc create -f postinstall/rhocs-namespace.yml
oc create -f postinstall/rhocs-operatorgroup.yml
oc project openshift-storage

# Create Storage Operator
oc apply -f postinstall/ocs-olm.yml
for i in {1..50}
do
  operator=$(oc get csv | grep ocs-operator | awk '{print $6}');
  if (($operator == Succeeded )); then
    echo "Operator completed";
    break;
  else
    echo "Operator still configuring";
    sleep 30;
  fi
done

# Create Cluster Storage
oc apply -f postinstall/ocs-StorageCluster.yml
for i in {1..50}
do
  clusterstorage=$(oc get csv | grep ocs-operator | awk '{print $6}');
  if (($clusterstorage = Succeeded )); then
    echo "Storage Operator completed";
    break;
  else
    echo "Storage Operator still configuring";
    sleep 30;
  fi
done
# TBD automate cluster storage
oc patch storageclass thin -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "false"}}}'
oc patch storageclass ocs-storagecluster-cephfs -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'

# Registry Storage OCS
oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"managementState": "Managed"}}' -n openshift-image-registry
#oc create -f postinstall/ocs4registry-pvc.yml -n openshift-image-registry
#Thin PVC
oc create -f postinstall/ocs4registry-thin-pvc.yml -n openshift-image-registry
oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"storage": {"pvc": {"claim": "image-registry-storage"}}}}' -n openshift-image-registry

# Install APP wildcard Cert
oc create configmap custom-ca \
     --from-file=ca-bundle.crt=certs/apps.ocp4.lab.gsslab.pek2.redhat.com.pem \
     -n openshift-config

oc patch proxy/cluster \
     --type=merge \
     --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'

oc create secret tls apps.ocp4.lab.gsslab.pek2.redhat.com \
     --cert=certs/apps.ocp4.lab.gsslab.pek2.redhat.com.pem  \
     --key=certs/apps.ocp4.lab.gsslab.pek2.redhat.com.key \
     -n openshift-ingress

oc patch ingresscontroller.operator default \
     --type=merge -p \
     '{"spec":{"defaultCertificate": {"name": "apps.ocp4.lab.gsslab.pek2.redhat.com"}}}' \
     -n openshift-ingress-operator

# Install API Cert
oc create secret tls api.ocp4.lab.gsslab.pek2.redhat.com \
     --cert=certs/api.ocp4.lab.gsslab.pek2.redhat.com.pem \
     --key=certs/api.ocp4.lab.gsslab.pek2.redhat.com.key \
     -n openshift-config

oc patch apiserver cluster \
     --type=merge -p \
     '{"spec":{"servingCerts": {"namedCertificates":
     [{"names": ["api.ocp4.lab.gsslab.pek2.redhat.com"],
     "servingCertificate": {"name": "api.ocp4.lab.gsslab.pek2.redhat.com"}}]}}}'


# Monitoring Install
oc create -f postinstall/cluster-monitoring-config.yml

# Logging Install
oc create -f postinstall/logging/eo-namespace.yml
oc create -f postinstall/logging/clo-namespace.yml
oc create -f postinstall/logging/eo-og.yml
oc create -f postinstall/logging/disconnected-eo-sub.yml
oc project openshift-operators-redhat
oc create -f postinstall/logging/eo-rbac.yml
oc project openshift-logging
oc create -f postinstall/logging/cluster-logging-og.yml
oc create -f postinstall/logging/cluster-logging-olm.yml
sleep 30
oc create -f postinstall/logging/cluster-logging-crd.yml
