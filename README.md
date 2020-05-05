# OCP4 on VMware vSphere UPI Automation

The goal of this repo is to make deploying and redeploying a new Openshift v4 cluster fully automated. This has been created to avoid any manual operation for a VMware OpenShift User Provisioned Infrastructure (UPI) implementation.

## Prerequisites

With all the details in hand from the prerequisites, populate the **vars/vars-${BUILD_LAB}.yml** in the root folder of this repo and trigger the installation seen in the example runs.

## Requirements

* Ansible `2.X`
* Python module `openshift-0.10.3` or higher (you might have to do `alternatives --install /usr/bin/python python /usr/bin/python3 1 ; pip3 install openshift --user`)
* MacOS `pip install requests` 
* MacOS `pip install PyVmomi`

## Examples Runs

### Automated Build with Prompted options with Vault Encrypted Vars and Version Status Checking

```bash
./cluster-build.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)
pek2lab
* Cluster Name: pek2lab

Enter OpenShift Version: (Press ENTER for default: 4.3.8)
4.3.9
* Using: 4.3.9

Enter OpenShift Cluster Size (small [8gb,2vcpu],medium [32gb,4vcpu],large [64gb,8vcpu]): (Press ENTER for default: small )
medium
* Using: medium Cluster Settings Memory 32768 CPU 4

Enter OpenShift Disconnected setting true/false: (Press ENTER for default: false)
false
* Disconnected Setting: false

Enable OpenShift Container Storage (OCS) true/false: (Press ENTER for default: false)
true
* OpenShift Container Storage (OCS) Setting: true
```
### Automated Build with Prompted options No Vault Encrypted Vars and Version Status Checking

```bash
./cluster-build-novault.sh
```

## Helper Node Deploy and Build

```bash
./helper-deploy.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

## Helper Node Build (Standalone)

```bash
./helpernode-build.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

## Helper Node destroy

```bash
./helper-destroy.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

## Manual install

### Prepare OCP OVA, Ignition and install configuration

```bash
ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION} disconnected_setting=${DISCONNECTED}" -e @./vars/vars-${BUILD_LAB}.yml setup-ocp-vsphere.yml --ask-vault-pass
```
### Transfer Ignition files

```bash
cp install-dir/bootstrap.ign /var/www/html/ignition
```

### Change file permissions

```bash
chmod 644 /var/www/html/ignition/bootstrap.ign
```

### Configure the vSphere cluster with the OpenShift instances

```bash
ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION} worker_memory=${WORKER_MEMORY} worker_cpu=${WORKER_CPU} disconnected_setting=${DISCONNECTED}" -e @./vars/vars-${BUILD_LAB}.yml setup-vcenter-vms.yml --ask-vault-pass
```

### Export the Kubernetes Authentication variable

```bash
export KUBECONFIG=/root/ocp4-vsphere-upi-automation/install-dir/auth/kubeconfig
```

### Review the installation progress

```bash
bin/openshift-install wait-for install-complete --dir=/root/ocp4-vsphere-upi-automation/install-dir
```

### SSH to the Bootstrap node

```bash
ssh core@192.168.0.xxx
```
### Review the Boostrap service

```bash
journalctl -b -f -u bootkube.service
```

## Post Deployment Tasks (Default HTPasswd Auth Provider)

```bash
./postinstall.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab

Confirm OpenShift Disconnected setting true/false: (Press ENTER for default: false)

* Disconnected Setting: false

Confirm OpenShift Container Storage (OCS) true/false: (Press ENTER for default: false)

* OpenShift Container Storage (OCS) Setting: false

Confirm HTPassword Auth true/false: (Press ENTER for default: true)

* HTPassword Auth Setting: true

Confirm LDAP Auth true/false: (Press ENTER for default: false)

* LDAP Auth Setting: false

Confirm NFS Storage true/false: (Press ENTER for default: false)

* NFS Storage Setting: false
```

## Cluster Node Scaling

## Scale Up Worker Nodes (Default 3 nodes)

```bash
./scale-up-nodes.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab

Enter OpenShift Worker Node Size (small [8gb,2vcpu],medium [32gb,4vcpu],large [64gb,8vcpu]): (Press ENTER for default: small )

* Using:  Cluster Settings Memory 8192 CPU 2
```

## Scale Down Worker Nodes (Default 3 nodes)

```bash
./scale-down-nodes.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

## Disconnected Setup

### Repo Sync with versioning

```bash
./disconnected-sync.sh
Enter OpenShift Version: (Press ENTER for default: 4.3.8)
4.3.8
* Using: 4.3.8
info: Mirroring 103 images to registry.ocp4.gsslab.brq.redhat.com:443/openshift/ocp4.3.8-x86_64 ...
```
### OLM Sync

```bash
./disconnected-operators.sh
```
## Destroy Cluster

### Cluster Destroy Vault

```bash
./cluster-destroy.sh
Specify Cluster Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

### Cluster Destroy No Vault

```bash
./cluster-destroy-novault.sh
Specify Cluster Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

# VMware Cloud-Init Image Guide

## RHEL or CentOS Template Node Cloud-Init install

### Creating a Generic Cloud-Init OS Image rhel7/CentOS

```bash
yum -y install cloud-init
```

#### Alernative Pip install

```bash
curl -O https://bootstrap.pypa.io/get-pip.py
```

```bash
python get-pip.py --user
```

#### VMware Custom Cloud-init profile install
```bash
yum install -y https://github.com/vmware/cloud-init-vmware-guestinfo/releases/download/v1.1.0/cloud-init-vmware-guestinfo-1.1.0-1.el7.noarch.rpm
```

```bash
curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -
```

### MetaData and UserData Creation (Currently Automated on Helper Create)

```bash
cat <<EOF > metadata.yaml
instance-id: helper-boot
local-hostname: helper-boot
network:
  version: 2
  ethernets:
    nics:
      match:
        name: ens*
      dhcp4: yes
EOF
```

```bash
cat <<EOF > userdata.yaml
#cloud-config

users:
  - default
  - name: openshift
    primary_group: openshift
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo, wheel
    ssh_import_id: None
    lock_passwd: true
    ssh_authorized_keys:
    - ssh-rsa xxxxxxxxxxxxxxx
EOF
```

```bash
export VM="/VMLAB/vm/rhel7.7-template"
```

```bash
export METADATA=$(gzip -c9 <metadata.yaml | { base64 -w0 2>/dev/null || base64; }) \
       USERDATA=$(gzip -c9 <userdata.yaml | { base64 -w0 2>/dev/null || base64; })
```
#### Update RHEL/CentOS template on VMware service (Ensure GOVC profile has been exported for the relevant Cluster)

```bash
govc vm.change -vm "${VM}" \
  -e guestinfo.metadata="${METADATA}" \
  -e guestinfo.metadata.encoding="gzip+base64" \
  -e guestinfo.userdata="${USERDATA}" \
  -e guestinfo.userdata.encoding="gzip+base64"
```


