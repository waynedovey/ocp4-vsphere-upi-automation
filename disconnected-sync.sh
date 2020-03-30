#!/bin/bash

# Exports - required environment variables:
DEFAULT_OCPVERSION="4.3.8"
DEFAULT_ARCH="-x86_64"
LOCAL_REGISTRY="registry.ocp4.gsslab.brq.redhat.com:443"
LOCAL_REPOSITORY="openshift/ocp${OCP_RELEASE}"
PRODUCT_REPO="openshift-release-dev"
LOCAL_SECRET_JSON="/root/.docker/config.json"
RELEASE_NAME="ocp-release"

# Set the OCP version
if [ "$1" != "--silent" ]; then
    printf "Enter OpenShift Version: (Press ENTER for default: ${DEFAULT_OCPVERSION})\n"
    read -r OCPVERSION_CHOICE
    if [ "${OCPVERSION_CHOICE}" != "" ]; then
        DEFAULT_OCPVERSION=${OCPVERSION_CHOICE}
    fi
fi
printf "* Using: ${DEFAULT_OCPVERSION}\n\n"

OCP_RELEASE="${DEFAULT_OCPVERSION}${DEFAULT_ARCH}"
LOCAL_REPOSITORY="openshift/ocp${OCP_RELEASE}"

# Log in to gsslab's local Quay:
#docker login -u="openshift+openshift" -p="xxxx" quay.ocp4.gsslab.brq.redhat.com
#docker login -u="openshift+openshift" -p="xxxx" quay.ocp4.gsslab.brq.redhat.com:443

# Log in to gsslab's local Quay:
#docker login -u="xxxx" -p="xxxx" registry.ocp4.gsslab.brq.redhat.com
#docker login -u="xxxx" -p="xxxx" registry.ocp4.gsslab.brq.redhat.com:443

# Mirror the repository:
# This command pulls the release information as a digest, and its output includes the imageContentSources data that you require when you install your cluster.
oc adm -a ${LOCAL_SECRET_JSON} release mirror \
  --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
  --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
  --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE} \
  --insecure=true
