resource "openstack_images_image_v2" "centos79" {
  name             = "Centos79"
  local_file_path  = "/home/Comviva_L2_MGMS_CentOS_7.9.qcow2"

  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"

}

#resource "openstack_images_image_access_v2" "centos79_member" {
#  image_id  = openstack_images_image_v2.centos79.id
#  member_id = "bed6b6cbb86a4e2d8dc2735c2f1000e4"
#  status    = "accepted"
#}
resource "openstack_images_image_v2" "EIR-BE-IMG" {
  name             = "EIR-BE-IMG"
  local_file_path  = "/ftp-comviva/IMAGES/Comviva_L2_EIR-BE_CentOS_7.9.qcow2"

  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"

}

resource "openstack_images_image_v2" "IMDB-IMG" {
  name             = "IMDB-IMG"
  local_file_path  = "/ftp-comviva/IMAGES/Comviva_L2_IMDB_CentOS_7.9.qcow2"

  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"

}

