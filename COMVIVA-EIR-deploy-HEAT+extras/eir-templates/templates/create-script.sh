openstack flavor create --ram 32768 --disk 20 --ephemeral 50 --vcpus 4 --public rdbms_flavor ;\
openstack flavor create --ram 32768 --disk 20 --ephemeral 20 --vcpus 4 --public mgms_flavor  ;\
openstack flavor create --ram 16384 --disk 20 --ephemeral 10 --vcpus 4 --public cdr_flavor ;\
openstack flavor create --ram 16384 --disk 20 --ephemeral 20 --vcpus 4 --public tslee_flavor ;\
openstack flavor create --ram 16384 --disk 20 --ephemeral 20 --vcpus 4 --public imdb_flavor ;\
openstack flavor create --ram 8192 --disk 20 --ephemeral 10 --vcpus 4 --public gtw_flavor

openstack network create eir-lab-ssh-net;\
openstack network create eir-lab-om-net;\
openstack network create eir-lab-sig-net;\
openstack network create eir-lab-bill-net;\
openstack network create eir-lab-cdr-net;\
openstack network create eir-lab-dbrep-net;\
openstack subnet create eir-lab-ssh-subnet --network eir-lab-ssh-net --subnet-range 192.168.1.0/24 --gateway 192.168.1.1;\
openstack subnet create eir-lab-om-subnet --network eir-lab-om-net --no-dhcp --subnet-range 192.168.2.0/24 --gateway none;\
openstack subnet create eir-lab-sig-subnet --network eir-lab-sig-net --no-dhcp --subnet-range 192.168.3.0/24 --gateway none;\
openstack subnet create eir-lab-bill-subnet --network eir-lab-bill-net --no-dhcp --subnet-range 192.168.4.0/24 --gateway none;\
openstack subnet create eir-lab-cdr-subnet --network eir-lab-cdr-net --subnet-range 192.168.5.0/24 --gateway none;\
openstack subnet create eir-lab-dbrep-subnet --network eir-lab-dbrep-net --no-dhcp --subnet-range 192.168.6.0/24 --gateway none


openstack router create --project tslee-lab eir-lab-router


openstack stack create -t HEAT-Examples/RDBMS.yaml -e ENVIRONMENT-Examples/RDBMS-Environment.yaml eir-lab-rdbms
openstack stack create -t HEAT-Examples/CDR.yaml -e ENVIRONMENT-Examples/CDR-Environment.yaml eir-lab-cdr
openstack stack create -t HEAT-Examples/GTW.yaml -e ENVIRONMENT-Examples/GTW-Environment.yaml eir-lab-gtw
openstack stack create -t HEAT-Examples/IMDB.yaml -e ENVIRONMENT-Examples/IMDB-Environment.yaml eir-lab-imdb
openstack stack create -t HEAT-Examples/TSLEE.yaml -e ENVIRONMENT-Examples/TSLEE-Environment.yaml eir-lab-tslee
openstack stack create -t HEAT-Examples/MGMS.yaml -e ENVIRONMENT-Examples/MGMS-Environment.yaml eir-lab-mgms