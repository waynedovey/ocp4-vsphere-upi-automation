#!/bin/bash
oc delete OperatorGroup/openshift-operators-redhat -n openshift-operators-redhat
oc delete project/openshift-operators-redhat
oc delete project/openshift-logging
oc delete CatalogSourceConfig/installed-redhat-openshift-logging -n openshift-marketplace
oc delete CatalogSourceConfig/elasticsearch -n openshift-marketplace
oc delete ClusterServiceVersion/$(oc get ClusterServiceVersion -n openshift-operator-lifecycle-manager | awk '{print $1}' | grep elasticsearch-operator) -n openshift-operator-lifecycle-manager
