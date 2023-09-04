
# Creating a router
resource "openstack_networking_router_v2" "router01" {
  name = "router01"
}

# Fetching the subnet ID of the public network
data "openstack_networking_subnet_v2" "public_subnet" {
  network_id = "<public_network_id>"
}

# Creating a router interface linking the router to the public subnet
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router01.id
  subnet_id = data.openstack_networking_subnet_v2.public_subnet.id
}

# Creating a security group with a description
resource "openstack_networking_secgroup_v2" "SG_RDBMS" {
  name        = "SG_RDBMS"
  description = "sg aberto"
}

# Creating an ingress security group rule to allow all access
resource "openstack_networking_secgroup_rule_v2" "SG_RDBMS_rule" {
  description     = "all access ingress"
  direction       = "ingress"
  remote_ip_prefix = "0.0.0.0/0"
  ethertype       = "IPv4"
  protocol        = "icmp"
  security_group_id = openstack_networking_secgroup_v2.SG_RDBMS.id
}
