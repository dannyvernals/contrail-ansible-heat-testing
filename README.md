# Contrail_Networking_Canonical_Openstack_Functionality_Test

This repo is inspired by:  
https://github.com/kashif-nawaz/Contrail_Networking_Canonical_Openstack_Functionality_Test  
It reuses many of the heat templates from that repo but adds some ansible glue and extra automated tests

The original README can be found underneath ./stacks

It adds an ansible wrapper to the establishment and teardown of Heat Stacks.

It adds: some playbooks to test the state in the Contrail API that describes the newly created stack.  It also adds some automated connectivity testing between the instantiated VMs.

1) Bring up the resources defined in the heat stacks (it is easy to customise to use different heat stacks)  
`ansible-playbook instantiate-stacks.yaml`
2) Test the API  
`ansible-playbook test-api.yaml`
3) Test Connectivity between the VMs and from the VMs to the relevant vrouter IP   
   This can either be via a management network:   
`ansible-playbook test-vm-direct.yml  -i vm-inventory-direct.yaml`  
  Or if one isn't available we can use the VM metadata IPs via SSH onto hosting compute node  
`ansible-playbook test-vm-via-metadata.yaml  -i vm-inventory-metadata.yaml`  
4) Teardown the heat stacks  
`ansible-playbook teardown-stacks.yaml`
