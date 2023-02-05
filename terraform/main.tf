# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.public_key.name
  public_key = file(var.public_key.file)  
}

data "openstack_images_image_v2" "img" {
  for_each = var.vms 
  name = each.value.image
}

data "openstack_images_image_v2" "img_disk" {
  for_each = var.vms_disk
  name = each.value.image
}

output "vm_ip"{  
  value = tomap({
    for k, bd in openstack_compute_instance_v2.vms : k => bd.network
  })  
}

output "vm_ip_disk"{  
  value = tomap({
    for k, bd in openstack_compute_instance_v2.vms_disk : k => bd.network
  })  
}
