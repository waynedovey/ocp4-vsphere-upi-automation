#!/bin/bash
rm -fr redhat-operators-manifests
export OCP_RELEASE=4.3.5-x86_64
export LOCAL_REGISTRY='quay.ocp4.gsslab.brq.redhat.com:443'
export LOCAL_REPOSITORY='openshift/ocp4.3.5-x86_64'
export PRODUCT_REPO='openshift-release-dev'
export LOCAL_SECRET_JSON='/root/.docker/config.json'
export RELEASE_NAME="ocp-release"

#docker login -u="openshift+openshift" -p="P276A6HFEGCN3D8857C3TSXQQWRI0P047H1TYCY0YJ8HYCDDQJ7LHZYQ57R2C3PY" quay.ocp4.lab.gsslab.pek2.redhat.com
#docker login -u="openshift+openshift" -p="P276A6HFEGCN3D8857C3TSXQQWRI0P047H1TYCY0YJ8HYCDDQJ7LHZYQ57R2C3PY" quay.ocp4.lab.gsslab.pek2.redhat.com:443

#oc adm -a ${LOCAL_SECRET_JSON} release mirror \
#     --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
#     --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
#     --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE} \
#     --insecure=true

#imageContentSources:
#- mirrors:
#  - quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift/ocp4.3.5-x86_64
#  source: quay.io/openshift-release-dev/ocp-release
#- mirrors:
#  - quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift/ocp4.3.5-x86_64
#  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev

### OLM 
#oc adm catalog build \
#    --appregistry-endpoint https://quay.io/cnr \
#    --appregistry-org redhat-operators \
#    --to=${LOCAL_REGISTRY}/openshift/redhat-operators:v1

oc patch OperatorHub cluster --type json \
    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

#oc adm catalog mirror \
#    ${LOCAL_REGISTRY}/openshift/redhat-operators:v1 \
#    ${LOCAL_REGISTRY}/openshift

oc apply -f ./redhat-operators-manifests

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

# Custom RESOURCES 
#rm -fr olm-4.3
#postinstall/get-operator-package.sh
#cd olm-4.3/manifests/redhat-operators/cluster-logging/cluster-logging-*

# replace
#sed -i 's|registry.redhat.io/openshift4|quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift|' */cluster-logging*.clusterserviceversion.yaml
## remove `replaces` line as we only have one version
#sed -i '/replaces/'d */cluster-logging*.clusterserviceversion.yaml
# check
#cat */cluster-logging*.clusterserviceversion.yaml | grep quay.ocp4.lab.gsslab.pek2.redhat.com

#oc image mirror registry.redhat.io/openshift4/ose-cluster-logging-operator quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift/ose-cluster-logging-operator
#oc image mirror registry.redhat.io/openshift4/ose-logging-curator5 quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift/ose-logging-curator5
#oc image mirror registry.redhat.io/openshift4/ose-logging-elasticsearch5 quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift/ose-logging-elasticsearch5
#oc image mirror registry.redhat.io/openshift4/ose-logging-fluentd quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift/ose-logging-fluentd
#oc image mirror registry.redhat.io/openshift4/ose-oauth-proxy quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift/ose-oauth-proxy

#cat <<EOF > Dockerfile.olm
#FROM registry.redhat.io/openshift4/ose-operator-registry:latest as builder
#COPY olm-4.3/manifests/redhat-operators/cluster-logging/cluster-logging-vk69sqz9 manifests
#RUN /bin/initializer -o ./bundles.db
#FROM registry.redhat.io/ubi8/ubi-minimal:latest
#COPY --from=builder /registry/bundles.db /bundles.db
#COPY --from=builder /usr/bin/registry-server /registry-server
#COPY --from=builder /usr/bin/grpc_health_probe /bin/grpc_health_probe

#EXPOSE 50051
#ENTRYPOINT ["/registry-server"]
#CMD ["--database", "bundles.db"]
#EOF

#podman login -u="openshift+openshift" -p="P276A6HFEGCN3D8857C3TSXQQWRI0P047H1TYCY0YJ8HYCDDQJ7LHZYQ57R2C3PY" quay.ocp4.lab.gsslab.pek2.redhat.com
#podman login -u="openshift+openshift" -p="P276A6HFEGCN3D8857C3TSXQQWRI0P047H1TYCY0YJ8HYCDDQJ7LHZYQ57R2C3PY" quay.ocp4.lab.gsslab.pek2.redhat.com:443

#podman build -f Dockerfile.olm -t ${LOCAL_REGISTRY}/openshift/custom-registry .
#podman push ${LOCAL_REGISTRY}/openshift/custom-registry

#cat <<EOF | oc apply -f -
#apiVersion: operators.coreos.com/v1alpha1
#kind: CatalogSource
#metadata:
#  name: my-operator-catalog
#  namespace: openshift-marketplace
#spec:
#  displayName: My Operator Catalog
#  sourceType: grpc
#  image: quay.ocp4.lab.gsslab.pek2.redhat.com:443/openshift/custom-registry:latest
#EOF
