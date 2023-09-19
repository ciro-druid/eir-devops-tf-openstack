# Creating a security group with a description
resource "openstack_networking_secgroup_v2" "SG_RDBMS" {
  name        = "SG_RDBMS"
  description = "sg aberto"
}

# Creating an ingress security group rule to allow all access
resource "openstack_networking_secgroup_rule_v2" "SG_RDBMS_rule" {
  description       = "all access ingress"
  direction         = "ingress"
  remote_ip_prefix  = "0.0.0.0/0"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  security_group_id = openstack_networking_secgroup_v2.SG_RDBMS.id
}
