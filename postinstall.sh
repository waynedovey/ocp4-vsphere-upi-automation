#!/bin/bash
export KUBECONFIG=/root/ocp4-vsphere-upi-automation/install-dir/auth/kubeconfig

# User Auth
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

oc create -f postinstall/rhocs-namespace.yml
oc create -f postinstall/rhocs-operatorgroup.yml
oc project openshift-storage

#oc apply -f postinstall/ocs-olm.yml
# TBD automate cluster storage 
##oc patch storageclass ocs-storagecluster-cephfs -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'

# Chrony NTPD settings - TBD Automate NTP Endpoint
oc apply -f postinstall/99_masters-chrony-configuration.yml  
oc apply -f postinstall/99_workers-chrony-configuration.yml

# Registry Storage OCS
#oc project openshift-image-registry
#oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"managementState": "Managed"}}'
#oc create -f postinstall/ocs4registry-pvc.yml
#oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"storage": {"pvc": {"claim": "image-registry-storage"}}}}'

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
oc create -f postinstall/logging/eo-sub.yml
oc project openshift-operators-redhat
oc create -f postinstall/logging/eo-rbac.yml
oc create -f postinstall/logging/cluster-logging-resourse.yaml
