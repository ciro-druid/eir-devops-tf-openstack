
resource "openstack_compute_flavor_v2" "rdbms_flavor" {
  name     = "rdbms_flavor"
#  ram      = 32768
  ram      = 4096
  disk     = 20
  vcpus    = 4
  ephemeral = 50
  is_public = true
}

resource "openstack_compute_flavor_v2" "mgms_flavor" {
  name     = "mgms_flavor"
#  ram      = 32768
  ram      = 4096
  disk     = 20
  vcpus    = 4
  ephemeral = 20
  is_public = true
}

resource "openstack_compute_flavor_v2" "cdr_flavor" {
  name     = "cdr_flavor"
#  ram      = 16384
  ram     =  2048
  disk     = 20
  vcpus    = 4
  ephemeral = 10
  is_public = true
}

resource "openstack_compute_flavor_v2" "tslee_flavor" {
  name     = "tslee_flavor"
#  ram      = 16384
  ram     =  2048
  disk     = 20
  vcpus    = 4
  ephemeral = 20
  is_public = true
}

resource "openstack_compute_flavor_v2" "imdb_flavor" {
  name     = "imdb_flavor"
  ram     =  2048
#  ram      = 16384
  disk     = 20
  vcpus    = 4
  ephemeral = 20
  is_public = true
}

resource "openstack_compute_flavor_v2" "eir_be_flavor" {
  name     = "eir_be_flavor"
  ram     =  4096
#  ram      = 16384
  disk     = 20
  vcpus    = 4
  ephemeral = 20
  is_public = true
}

