
# Creating a router
resource "openstack_networking_router_v2" "router01" {
  name = "router01"
}

# Fetching the subnet ID of the public network
data "openstack_networking_subnet_v2" "Internet" {
  name = "Internet"
  #network_id = "Internet"
}

# Creating a router interface linking the router to the public subnet
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router01.id
  subnet_id = data.openstack_networking_subnet_v2.Internet.id
}

