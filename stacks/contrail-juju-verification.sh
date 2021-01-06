
#!/bin/bash


rm -fr ~/atp
mkdir ~/atp

for host in {0..2}; do juju ssh contrail-controller/${host}  hostname | tee  ~/atp/login-contrail-controller${host}.txt; done;
for host in {0..2}; do juju ssh contrail-analytics/${host} hostname | tee  ~/atp/login-contrail-analytics${host}.txt; done;
for host in {0..2}; do juju ssh contrail-analyticsdb/${host} hostname | tee  ~/atp/login-contrail-analytics-db${host}.txt; done;
for host in {0..2}; do juju ssh contrail-haproxy/${host} hostname | tee ~/atp/login-contrail-haproxy${host}.txt; done;
for host in {0..2}; do juju ssh contrail-keystone-auth/${host} hostname| tee  ~/atp/login-contrail-keystone-auth${host}.txt; done;
for host in {0..2}; do  juju ssh contrail-controller/${host} "sudo contrail-status" | tee ~/atp/contrail-contoller${host}-status.txt; done
for host in {0..2}; do  juju ssh contrail-analytics/${host} "sudo contrail-status" | tee ~/atp/contrail-analytics${host}-status.txt; done
for host in {0..2}; do  juju ssh contrail-analyticsdb/${host} "sudo contrail-status" | tee ~/atp/contrail-analyticsdb${host}-status.txt; done
for host in {1..3}; do juju ssh compute-${host} "sudo contrail-status" | tee  ~/atp/compute-${host}-status.txt; done; #replace x..y with actual compute number
for host in {0..2}; do juju ssh contrail-controller/${host} sudo docker images | egrep -i "contrail|TAG" | tee  ~/atp/contrail-version-contrail-controller${host}.txt; done;
for host in {0..2}; do juju ssh contrail-analytics/${host} sudo docker images | egrep -i "contrail|TAG" | tee  ~/atp/contrail-version-contrail-analytics${host}.txt; done;
for host in {0..2}; do juju ssh contrail-analyticsdb/${host} sudo docker images | egrep -i "contrail|TAG" | tee  ~/atp/contrail-version-contrail-analytics-db${host}.txt; done;
for host in {1..3}; do juju ssh compute-${host} sudo docker images | egrep -i "contrail|TAG" | tee  ~/atp/contrail-version-compute${host}.txt ; done; #replace x--y with actual compute number
