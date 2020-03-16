# OCP4 on VMware vSphere UPI Automation

The goal of this repo is to make deploying and redeploying a new Openshift v4 cluster a snap. The document looks long but after you have used it till the end once, you will appreciate how quickly VMs come up in vCenter for you to start working with.

## Setup and Installation

With all the details in hand from the prerequisites, populate the **vars.yml** in the root folder of this repo and trigger the installation with the following command

```bash
# Make sure to run this command in the root folder of the repo
ansible-playbook -e @./vars/vars-{CUSTOMER}.yml setup-ocp-vsphere.yml --ask-vault-pass
```

## Requirements

* Ansible `2.X`
* Python module `openshift-0.10.3` or higher (you might have to do `alternatives --install /usr/bin/python python /usr/bin/python3 1 ; pip3 install openshift --user`)

## Copy the bootstrap.ign file to the webserver

```bash
# Running from the root folder of this repo; below is just an example
scp install-dir/bootstrap.ign root@192.168.86.180:/var/www/html/ignition
```

## Examples

### Automated

```bash
./cluser-build.sh
```

### Manual install

```bash
ansible-playbook -e @./vars/vars-{CUSTOMER}.yml setup-vcenter-vms.yml --ask-vault-pass
```

### GSS LaB

```bash
ansible-playbook -e @./vars/vars-{CUSTOMER}.yml setup-vcenter-vms.yml --ask-vault-pass
```

```bash
journalctl -b -f -u bootkube.service
```

```bash
export KUBECONFIG=/root/ocp4-vsphere-upi-automation/install-dir/auth/kubeconfig
```

```bash
bin/openshift-install wait-for install-complete --dir=/root/ocp4-vsphere-upi-automation/install-dir
```

Post Deployment Tasks

```bash
ansible-playbook -e @./vars/vars-{CUSTOMER}.yml post-install.yml --ask-vault-pass
```
