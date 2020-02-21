apiVersion: metering.openshift.io/v1
kind: MeteringConfig
metadata:
  name: "operator-metering"
spec:
  storage:
    type: "hive"
    hive:
      type: "s3Compatible"
      s3Compatible:
        bucket: "hive" 
        endpoint: "https://s3-openshift-storage.apps.ocp4.lab.gsslab.pek2.redhat.com" 
        secretName: "my-nooba-secret" 
        
apiVersion: v1
kind: Secret
metadata:
  name: my-nooba-secret
data:
  aws-access-key-id: ""
  aws-secret-access-key: ""
