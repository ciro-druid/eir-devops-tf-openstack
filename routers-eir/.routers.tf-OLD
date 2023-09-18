
# Creating the router
resource "openstack_networking_router_v2" "router01" {
  name = "router01"
}

# Listing the public networks (assuming the public network name is 'public')
#data "openstack_networking_network_v2" "public_network" {
#  name = "public"
#}

# Fetch the subnet ID of the public network
data "openstack_networking_subnet_v2" "public_subnet" {
  network_id = data.openstack_networking_network_v2.public_network.id
}

# Linking the router to the public network
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id      = openstack_networking_router_v2.router01.id
  subnet_id      = data.openstack_networking_network_v2.public_network.subnet_ids[0]
}

# Creating an interface between the private network and the router
# Assuming you have the ID of the subnet of the private network
resource "openstack_networking_router_interface_v2" "private_interface" {
  router_id = openstack_networking_router_v2.router01.id
  subnet_id = "YOUR_PRIVATE_SUBNET_ID"
}

# Listing routers
data "openstack_networking_router_v2" "all_routers" {}

# Showing details of a specific router (assuming ROUTER1 is the name)
data "openstack_networking_router_v2" "router_details" {
  name = "ROUTER1"
}

