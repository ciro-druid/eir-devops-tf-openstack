data "openstack_images_image_ids_v2" "eir_be_image" {
  name = "EIR-BE-IMG"
}

resource "openstack_compute_instance_v2" "EIR-BE" {
  name  = "EIR-BE-vm"
  count = 2
  # image_id    = data.openstack_images_image_ids_v2.custom_image.id
  image_name = data.openstack_images_image_ids_v2.eir_be_image.name
  #flavor_id  = "eir_be_flavor"
  flavor_name  = "eir_be_flavor"
  #flavor_id  = "gen.nano"
  network {
    uuid = "c705fd99-bc0f-460f-940f-6bdb9fd54e84"
  }
}



data "openstack_images_image_ids_v2" "imdb_image" {
  name = "IMDB-IMG"
}

resource "openstack_compute_instance_v2" "IMDB" {
  name  = "IMDB-vm"
  count = 2
  # image_id    = data.openstack_images_image_ids_v2.imdb_image.id
  image_name = data.openstack_images_image_ids_v2.imdb_image.name
  #flavor_id  = "imdb_flavor"
  flavor_name  = "imdb_flavor"
  #flavor_id  = "gen.nano"
  network {
    uuid = "c705fd99-bc0f-460f-940f-6bdb9fd54e84"
  }
}

#data "openstack_images_image_ids_v2" "images" {
#  name_regex = "^EIR-BE-IMG"
#  sort       = "updated_at"
#}
