#!/bin/bash

# Cleanup:
rm -fr redhat-operators-manifests postinstall/catalogsource.yaml

# Exports - required environment variables:
LOCAL_REGISTRY='registry.ocp4.gsslab.brq.redhat.com:443'
PRODUCT_REPO='openshift-release-dev'
LOCAL_SECRET_JSON='/root/.docker/config.json'
RELEASE_NAME='ocp-release'

# Log in to gsslab's local Quay:
#docker login -u="openshift+openshift" -p="xxxx" quay.ocp4.gsslab.brq.redhat.com
#docker login -u="openshift+openshift" -p="xxxx" quay.ocp4.gsslab.brq.redhat.com:443

# Log in to gsslab's local Quay:
#docker login -u="xxxx" -p="xxxx" registry.ocp4.gsslab.brq.redhat.com
#docker login -u="xxxx" -p="xxxx" registry.ocp4.gsslab.brq.redhat.com:443

# Create Operator Lifecycle Manager (OLM):
oc adm catalog build \
  --appregistry-endpoint https://quay.io/cnr \
  --appregistry-org redhat-operators \
  --to=${LOCAL_REGISTRY}/openshift/redhat-operators:v1

oc patch OperatorHub cluster --type json \
  -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

oc adm catalog mirror --manifests-only \
  ${LOCAL_REGISTRY}/openshift/redhat-operators:v1 \
  ${LOCAL_REGISTRY}/openshift

./flattern.pl redhat-operators-manifests/mapping.txt

mv -f /tmp/imageContentSourcePolicy-flat.yaml redhat-operators-manifests/
mv -f /tmp/mapping-skopeo.txt redhat-operators-manifests/
rm -fr redhat-operators-manifests/mapping.txt redhat-operators-manifests/imageContentSourcePolicy.yaml

echo yes | cp temp/skopeo /usr/local/bin

while read line; do echo $line && skopeo copy --all $line; done < redhat-operators-manifests/mapping-skopeo.txt
oc apply -f redhat-operators-manifests/imageContentSourcePolicy-flat.yaml

# All nodes reboot

cat << EOF >postinstall/catalogsource.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: my-redhat-operators-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: ${LOCAL_REGISTRY}/openshift/redhat-operators:v1
  displayName: My Red Hat Operator Catalog
  publisher: grpc
EOF

oc create -f postinstall/catalogsource.yaml
