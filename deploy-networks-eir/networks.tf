
# Network Creation
resource "openstack_networking_network_v2" "eir_lab_ssh_net" {
  name = "eir-lab-ssh-net"
}

resource "openstack_networking_network_v2" "eir_lab_om_net" {
  name = "eir-lab-om-net"
}

resource "openstack_networking_network_v2" "eir_lab_sig_net" {
  name = "eir-lab-sig-net"
}

resource "openstack_networking_network_v2" "eir_lab_bill_net" {
  name = "eir-lab-bill-net"
}

resource "openstack_networking_network_v2" "eir_lab_cdr_net" {
  name = "eir-lab-cdr-net"
}

resource "openstack_networking_network_v2" "eir_lab_dbrep_net" {
  name = "eir-lab-dbrep-net"
}

# Subnet Creation
resource "openstack_networking_subnet_v2" "eir_lab_ssh_subnet" {
  network_id = openstack_networking_network_v2.eir_lab_ssh_net.id
  cidr       = "192.168.1.0/24"
  gateway_ip = "192.168.1.1"
}

resource "openstack_networking_subnet_v2" "eir_lab_om_subnet" {
  network_id  = openstack_networking_network_v2.eir_lab_om_net.id
  cidr        = "192.168.2.0/24"
  gateway_ip  = null
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "eir_lab_sig_subnet" {
  network_id  = openstack_networking_network_v2.eir_lab_sig_net.id
  cidr        = "192.168.3.0/24"
  gateway_ip  = null
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "eir_lab_bill_subnet" {
  network_id  = openstack_networking_network_v2.eir_lab_bill_net.id
  cidr        = "192.168.4.0/24"
  gateway_ip  = null
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "eir_lab_cdr_subnet" {
  network_id = openstack_networking_network_v2.eir_lab_cdr_net.id
  cidr       = "192.168.5.0/24"
  gateway_ip = null
}

resource "openstack_networking_subnet_v2" "eir_lab_dbrep_subnet" {
  network_id  = openstack_networking_network_v2.eir_lab_dbrep_net.id
  cidr        = "192.168.7.0/24"
  gateway_ip  = null
  enable_dhcp = false
}
