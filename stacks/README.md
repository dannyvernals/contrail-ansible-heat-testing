# Contrail Network Deployed with Canonical Charmed Based Openstack-Acceptance Test Procedure 
Contrail Networking deployed with Canonical Charmed based Openstack   Functional testing via heat
# Exeuction 
This project is created for quick functional verification of Contrail Networking (aka Tungsten Fabric) via heat automation and shell scripting:-  <br/>

contrail-juju-verification.sh scripit will verify:- <br/> 

 *  Login to Contrail VMs/LXD containers <br/> 
 *  Check "Contrail-status" <br/> 
 *  Check "docker images version" <br/>

create-stack.sh script will create multiple stacks which will be used for verification of the Contrail Networking platform <br/>
 
 * Create glance image <br/>

 * Create flavor (for dpdk and kmod) <br/>

 * Create Security Group <br/>

 * Create vDNS <br/>

 * Create IPAM <br/> 
 
 * Create Network Policy <br/> 

 * Create Left_virtual_network <br/>

 * Create Right_virtual_networ <br/> 

 * Create Left_VN_VM1 <br/> 

 * Create Right_VN_VM1 <br/> 
 


delete-stack.sh script will delete the stacks in reverse order once Contrail Networking verification is completed 
