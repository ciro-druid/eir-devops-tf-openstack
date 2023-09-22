####  NETWORKs
data "openstack_networking_network_v2" "eir-lab-cdr-net" {
  name = "eir-lab-cdr-net"
}

data "openstack_networking_network_v2" "eir-lab-ssh-net" {
  name = "eir-lab-ssh-net"
}

data "openstack_networking_network_v2" "eir-lab-sig-net" {
  name = "eir-lab-sig-net"
}


data "openstack_networking_network_v2" "eir-lab-om-net" {
  name = "eir-lab-om-net"
}


data "openstack_networking_network_v2" "eir-lab-bill-net" {
  name = "eir-lab-bill-net"
}

data "openstack_networking_network_v2" "eir-lab-dbrep-net" {
  name = "eir-lab-dbrep-net"
}




#### IMAGEs
data "openstack_images_image_ids_v2" "eir_be_image" {
  name = "EIR-BE-IMG"
}

data "openstack_images_image_ids_v2" "imdb_image" {
  name = "IMDB-IMG"
}
	





##### VMs
resource "openstack_compute_instance_v2" "EIR-BE" {
  name  = "EIR-BE-vm"
  count = 29
  image_name = data.openstack_images_image_ids_v2.eir_be_image.name
  flavor_name  = "eir_be_flavor"
  network {
    #uuid = "c705fd99-bc0f-460f-940f-6bdb9fd54e84"
    name = data.openstack_networking_network_v2.eir-lab-sig-net.name
  }
  network {
    name = data.openstack_networking_network_v2.eir-lab-ssh-net.name
  }
  network {
    name = data.openstack_networking_network_v2.eir-lab-om-net.name
  }
}



resource "openstack_compute_instance_v2" "IMDB" {
  name  = "IMDB-vm"
  count = 2
  image_name = data.openstack_images_image_ids_v2.imdb_image.name
  flavor_name  = "imdb_flavor"
  network {
    #uuid = "c705fd99-bc0f-460f-940f-6bdb9fd54e84"
    name = data.openstack_networking_network_v2.eir-lab-dbrep-net.name
  }
  network {
    name = data.openstack_networking_network_v2.eir-lab-ssh-net.name
  }
  network {
    name = data.openstack_networking_network_v2.eir-lab-om-net.name
  }
}

#data "openstack_images_image_ids_v2" "images" {
#  name_regex = "^EIR-BE-IMG"
#  sort       = "updated_at"
#}
