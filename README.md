# OCP4 on VMware vSphere UPI Automation

The goal of this repo is to make deploying and redeploying a new Openshift v4 cluster a snap. The document looks long but after you have used it till the end once, you will appreciate how quickly VMs come up in vCenter for you to start working with. 

   
### Setup and Installation

With all the details in hand from the prerequisites, populate the **vars.yml** in the root folder of this repo and trigger the installation with the following command 

```sh 
# Make sure to run this command in the root folder of the repo
ansible-playbook -e @vars.yml setup-ocp-vsphere.yml --ask-vault-pass
```
## Copy the bootstrap.ign file to the webserver 

```sh 
# Running from the root folder of this repo; below is just an example
scp install-dir/bootstrap.ign root@192.168.86.180:/var/www/html/ignition
```

### Setup and Installation

# Automated 

```sh
./cluser-build.sh
```

# Manual install 

```sh 
ansible-playbook -e @vars.yml setup-vcenter-vms.yml --ask-vault-pass
```
# GSS LaB 
```sh 
ansible-playbook -e @vars-gsslab.yml setup-vcenter-vms.yml --ask-vault-pass
```

```sh
journalctl -b -f -u bootkube.service
```

```sh
export KUBECONFIG=/root/ocp4-vsphere-upi-automation/install-dir/auth/kubeconfig
```

```sh
bin/openshift-install wait-for install-complete --dir=/root/ocp4-vsphere-upi-automation/install-dir
```

Post Deployment Tasks 
```sh
ansible-playbook -e @vars-gsslab.yml post-install.yml --ask-vault-pass
```
