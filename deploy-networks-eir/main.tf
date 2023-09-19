terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}


provider "openstack" {
  cloud    = "openstack"
  insecure = true
  #  user_name   = var.openstack_username
  #  tenant_name = var.openstack_project_name
  #  password    = var.openstack_password
  #  auth_url    = var.openstack_auth_url
}


terraform {
  backend "local" {}
}
