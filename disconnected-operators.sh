#!/bin/bash

# Cleanup:
rm -fr redhat-operators-manifests postinstall/catalogsource.yaml

# Exports - required environment variables:
export OCP_RELEASE=4.3.8-x86_64
#export LOCAL_REGISTRY='quay.ocp4.gsslab.brq.redhat.com:443'
export LOCAL_REGISTRY='registry.ocp4.gsslab.brq.redhat.com:443'
export LOCAL_REPOSITORY='openshift/ocp4.3.8-x86_64'
export PRODUCT_REPO='openshift-release-dev'
export LOCAL_SECRET_JSON='/root/.docker/config.json'
export RELEASE_NAME="ocp-release"

# Log in to gsslab's local Quay:
docker login -u="openshift+openshift" -p="xxxx" quay.ocp4.gsslab.brq.redhat.com
docker login -u="openshift+openshift" -p="xxxx" quay.ocp4.gsslab.brq.redhat.com:443

# Log in to gsslab's local Quay:
docker login -u="xxxx" -p="xxxx" registry.ocp4.gsslab.brq.redhat.com
docker login -u="xxxx" -p="xxxx" registry.ocp4.gsslab.brq.redhat.com:443

# Mirror the repository:
# This command pulls the release information as a digest, and its output includes the imageContentSources data that you require when you install your cluster.
oc adm -a ${LOCAL_SECRET_JSON} release mirror \
  --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
  --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
  --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE} \
  --insecure=true

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

mv /tmp/imageContentSourcePolicy-flat.yaml redhat-operators-manifests/
mv /tmp/mapping-skopeo.txt redhat-operators-manifests/
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
