#!/bin/bash

# Cleanup:
rm -fr redhat-operators-manifests postinstall/catalogsource.yaml

# Exports - required environment variables:
LOCAL_REGISTRY='registry.ocp4.gsslab.brq.redhat.com:443'

# Create Operator Lifecycle Manager (OLM):
oc adm catalog build \
    --appregistry-org redhat-operators \
    --from=registry.redhat.io/openshift4/ose-operator-registry:v4.4 \
    --filter-by-os="linux/amd64" \
    --to=${LOCAL_REGISTRY}/olm/redhat-operators:v1

oc patch OperatorHub cluster --type json \
  -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

oc adm catalog mirror \
  ${LOCAL_REGISTRY}/olm/redhat-operators:v1 \
  ${LOCAL_REGISTRY} \
   --filter-by-os="linux/amd64"

oc apply -f ./redhat-operators-manifests

# All nodes reboot

cat << EOF >postinstall/catalogsource.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: my-operator-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: ${LOCAL_REGISTRY}/olm/redhat-operators:v1
  displayName: My Red Hat Operator Catalog
  publisher: grpc
EOF

oc create -f postinstall/catalogsource.yaml
