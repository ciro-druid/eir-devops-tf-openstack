
data "openstack_images_image_ids_v2" "custom_image" {
  name = "Centos79"
}




resource "openstack_compute_instance_v2" "example_vm" {
  name      = "eir-vm"
  count    = 20
#  image_id  = "8d4dbaa2-ff12-4e9a-849b-06f0cf6d9535"
#  image_id  = "data.openstack_images_image_ids_v2.custom_image.ids[0]"
# image_id    = data.openstack_images_image_ids_v2.custom_image.id
  image_name    = data.openstack_images_image_ids_v2.custom_image.name
  flavor_id = "gen.nano"
  network {
    uuid = "c705fd99-bc0f-460f-940f-6bdb9fd54e84"
  }
}



#data "openstack_images_image_ids_v2" "images" {
#  name_regex = "^Centos79"
#  sort       = "updated_at"
#}
