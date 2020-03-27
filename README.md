# OCP4 on VMware vSphere UPI Automation

The goal of this repo is to make deploying and redeploying a new Openshift v4 cluster fully automated. This has been created to avoid any manual operation for a VMware OpenShift UPO implementation.

## Prerequisites

With all the details in hand from the prerequisites, populate the **vars/vars-${BUILD_LAB}.yml** in the root folder of this repo and trigger the installation seen in the example runs. 

## Requirements

* Ansible `2.X`
* Python module `openshift-0.10.3` or higher (you might have to do `alternatives --install /usr/bin/python python /usr/bin/python3 1 ; pip3 install openshift --user`)

## Examples Runs

### Automated Build Generic

```bash
./cluster-build.sh
```
### Automated Build Lab

```bash
./cluster-build-${BUILD_LAB}.sh
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

## Post Deployment Tasks

```bash
ansible-playbook -e @./vars/vars-{CUSTOMER}.yml post-install.yml --ask-vault-pass
```