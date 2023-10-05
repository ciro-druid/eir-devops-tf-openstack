# Define the CIDR blocks for the networks
variable "network_cidrs" {
  default = ["172.16.0.0/16", "172.17.0.0/16", "172.18.0.0/16", "172.19.0.0/16", "172.20.0.0/16"]
}

# Create networks and subnets
resource "openstack_networking_network_v2" "networks" {
  count          = length(var.network_cidrs)
  name           = "network-${count.index + 1}"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnets" {
  count           = length(var.network_cidrs)
  network_id      = openstack_networking_network_v2.networks[count.index].id
  cidr            = var.network_cidrs[count.index]
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = ["8.8.8.8"]
}

# Create a router and connect each subnet to it
resource "openstack_networking_router_v2" "router" {
  name           = "router"
  admin_state_up = true
}

resource "openstack_networking_router_interface_v2" "router_interfaces" {
  count     = length(openstack_networking_subnet_v2.subnets)
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnets[count.index].id
}

# Define routes to enable communication between networks
resource "openstack_networking_router_route_v2" "network_routes" {
  count            = length(var.network_cidrs)
  router_id        = openstack_networking_router_v2.router.id
  destination_cidr = var.network_cidrs[count.index]
  next_hop         = openstack_networking_router_interface_v2.router_interfaces[count.index].id
}
