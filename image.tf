


# Create an OpenStack image from a local qcow2 file
resource "openstack_images_image_v2" "example_image" {
  name              = "example-image"
  local_file_path  = "/home/Comviva_L2_MGMS_CentOS_7.9.qcow2"
  container_format = "bare"
  disk_format       = "qcow2"
#  min_disk          = 20
#  min_ram           = 4096
}

# Upload the local qcow2 file to the Glance image
resource "openstack_images_image_file_v2" "example_image_file" {
  image_id = openstack_images_image_v2.example_image.id
  file     = "/home/Comviva_L2_MGMS_CentOS_7.9.qcow2"
}
