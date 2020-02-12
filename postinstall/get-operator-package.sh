#!/bin/bash

mkdir olm-4.3; cd olm-4.3
export CNR_URL='https://quay.io/cnr/api/v1/packages'
export URLS=$(for operator_namespace in redhat-operators community-operators certified-operators; do curl -s ${CNR_URL}?namespace=${operator_namespace} | jq -r ".[] | \"${CNR_URL}/${operator_namespace}/\(.name)/\(.default)\""; done)
for url in $URLS; do 
    URL_PATH=$(echo "$url" | sed "s#${CNR_URL}/\(certified-operators\|community-operators\|redhat-operators\)/##"); 
    DIGEST=$(curl -s ${CNR_URL}/${URL_PATH} | jq -r '.[].content.digest'); 
    NAME_OP=$(echo $URL_PATH | awk -F/ 'sub(FS $NF,x)'); 
    curl -s "${CNR_URL}/${NAME_OP}/blobs/sha256/${DIGEST}" -o "$(echo $NAME_OP | sed "s#/#_#").tar.gz"
    mkdir -p manifests/$NAME_OP
    tar -xvf "$(echo $NAME_OP | sed "s#/#_#").tar.gz" -C manifests/$NAME_OP
done
