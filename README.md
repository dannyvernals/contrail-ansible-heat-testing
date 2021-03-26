# Contrail Ansible + HEAT Testing

This repo is inspired by:  
https://github.com/kashif-nawaz/Contrail_Networking_Canonical_Openstack_Functionality_Test  
It reuses many of the heat templates from that repo but adds some ansible glue and extra automated tests

The original README can be found underneath ./stacks

It adds an ansible wrapper to the establishment and teardown of Heat Stacks. To speed up resource establishment,
particularly in large DCs, it also uses jinja2 templates to create one HOT per VM type (DPDK / kernel / SRIOV) rather than
having a HOT per VM.  This means you should be able to test connectivity on all compute hosts in one go.  

It also adds:
1) playbooks to test the state in the Contrail API that describes the newly created stacks.
2) Automated connectivity testing between the instantiated VMs.  It will ping from every VM to every other VM.  This should be sufficient to verify most connectivity paths within the DC.

## Installation
The playbooks require python openstack SDK and ansible openstack collection  
If SDK isn't installed it can be installed in a virtual environment (ansible needs to be pointed at the venv)  
1) Create a venv:  
   `python3 -m venv openstack`  
2) Activate the venv:  
   `source /path/to/above/openstack/bin/activate`  
3) Install SDK (and other dependencies):  
   `pip install wheel lxml openstacksdk`
4) Point ansible to the venv python:  
   `vi group_vars/all`  
   set 'ansible_python_interpreter' to /path/to/above/openstack/bin/python  
5) Install ansible openstack collection:  
   `ansible-galaxy collection install openstack.cloud`  
6) Install ansible netcommon collection (for IP address processing)  
   `ansible-galaxy collection install ansible.netcommon`     
7) On some servers you will need to authorize ansible to SSH to localhost i.e.  
   add contents of `.ssh/id_rsa.pub` to `.ssh/authorized_keys`
8) The server where the playbooks are run from needs to be able to SSH directly onto compute hosts.  
   This could be achieved by adding your users SSH keys to juju


## Configuration
Operation of the playbooks is controlled via standard ansible variables i.e. `group_vars/all`
When running the playbooks in a cluster for the first time, this file needs to be modified.
You can use `group_vars/_gem_all.yml` as an example.    
Typical changes you will need to make are:  
* `ansible_python_interpreter` : Change to the path pointing at python in your venv created in the installation  
* `domain_suffix` : Change to the domain name of the DC    
* `dpdk_nodes` : A list of all the hostnames for compute nodes running DPDK you would like to test a VM on.
* `kernel_nodes` : A list of the hostnames for compute nodes running in kernel vrouter mode you would like to test a VM on.
* `sriov_nodes` : A list of the hostnames for compute nodes  using SRIOV you would like to test a VM on.
*  Note that the 2 above lists could be the same servers.  They are included as separate lists to give you granular control. i.e.   You might want a kernel VM on a given compute node but not an SRIOV VM.  
* `sriov_vlan`
* `sriov_leak_rt` 
* `sriov_start_ip` This is the first IP in the relevant range to use for an SRIOV VM.  It will be specific for each DC (see DDD for relevant range).  The first 3 IPs of the range will always be the QFXs so don't use them.
*  `introspect_cert/key`  X.509 details for introspect API authentication.  If a cert/key pair doesn't already exist they can be generated with  https://github.com/dannyvernals/contrail-gen-introspect-cert.git.

### Optional Configuration
* Sometimes it can be useful to time the execution of the playbooks as certain faults within the cluster could manifest as delayed creation of objects rather than a total failure to create objects.  If you want to time execution, add the following line to `ansible.cfg`.  
* `callback_whitelist = profile_tasks`

## Execution (Automated)
0) Source the relevant RC file you use for Openstack Authentication e.g.  
`source dc_name_rc`
1) Execute the master playbook  
`ansible-playbook natp-master.yml`   
   This will bring up the stacks, test the API and connectivty between all VMs and then teardown the stacks.  
   If you want to run the playbooks individually you can follow the instructions below:

## Execution (Manual)
0) Source the relevant RC file you use for Openstack Authentication e.g.  
`source dc_name_rc`
1)  Bring up the resources defined in the heat stacks (it is easy to customise to use different heat stacks)  
`ansible-playbook instantiate-natp-stacks.yml`  
2) Test the API  
   This playbook performs a series of tests against the Contrail API to make sure it is working and
   the objects that were instantiated earlier (Virtual Networks etc) are returning data.
   It automates the 'curl' testing from the NATP.  
`ansible-playbook test-api.yml`  
3) Test Connectivity between the VMs and from the VMs to the relevant vrouter IP.  
   This will ask every VM launched earlier to ping all the other VMs.  
`ansible-playbook test-connectivity.yml`  
4) Teardown the heat stacks  
`ansible-playbook teardown-natp-stacks.yml`  


## Notes / Design
A rough outline of these playbooks is as follows:
* The tasks are structured around 2 roles: `natp-localhost` & `natp-remote`.
* `natp-localhost` contains all the tasks that are run on the ansible server (i.e. localhost).  These include: establishment & teardown of the OpenStack resrouces using HOTs and testing of the Contrail API.
* `natp-remote` contains all the tasks executed on remote nodes (Compute, Contrail etc) e.g. the VM ping tests.
* The plays use the Openstack collection to instantiate resources within the cluster via Heat Orchestration Templates (HOTs).
* The plays interact with 2 Contrail APIs to obtain state and execute tests.  They use standard ansible URI calls for this:
* Contrail REST API (obtain JSON data that details how objects are configured in Contrail). This is authenticated via keystone.  
* Contrail Introspect API (XML/HTML): obtain low level state from Contrail vrouters. This is authenticated via client X.509 certs.  
* The playbook to ping test VMs uses a dyamically created inventory from the playbook that instantiates the heat stacks.
* Most HOTs can be found in the `./stacks` directory.
* The exception being those used to launch VMs.  These are generated on the fly based on jinja2 templates.
* The jinja2 templates for generating VM HOTs make use of non-standard delimiters (see the start of the templates). This is because standard jinja2 delimiters i.e. `{{ }}` and `{% %}` clash with json so the escaping needed would be a nightmare.
* The ping test playbook connects to the relevant compute node hosting the VM (via dynamic inventory) and ping tests on the VM by connectivity to its' metadata IP address (obtained via introspect API).
* Authentication to the VM is based on an SSH key contained within the repo.  Keys are included in the repo for convienience but of course you should generate your own.  They are only used to authenticate transient VMs typically within an isolated environment so don't require a very strict security posture.



