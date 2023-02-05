

resource "openstack_networking_port_v2" "ports" {
  for_each = var.vms
  name           = "k8s_port_${each.value.name}"
  network_id     = "${data.openstack_networking_network_v2.oam_net.id}"
  admin_state_up = "true"

  fixed_ip {
    ip_address = "${ each.value.ip }"
    subnet_id = data.openstack_networking_subnet_v2.k8s_oam_network.id
  }  

  allowed_address_pairs {
    ip_address = var.oam_network.allowed_addresses
  }
}

resource "openstack_networking_port_v2" "ports_disk" {
  for_each = var.vms_disk
  name           = "k8s_port_${each.value.name}"
  network_id     = "${data.openstack_networking_network_v2.oam_net.id}"
  admin_state_up = "true"

  fixed_ip {
    ip_address = "${ each.value.ip }"
    subnet_id = data.openstack_networking_subnet_v2.k8s_oam_network.id
  }  

  allowed_address_pairs {
    ip_address = var.oam_network.allowed_addresses
  }
}

data "openstack_networking_port_v2" "ports" {
  for_each = var.vms 
  name = "k8s_port_${each.value.name}"

  depends_on = [
    openstack_networking_port_v2.ports
  ]
}

data "openstack_networking_port_v2" "ports_disk" {
  for_each = var.vms_disk
  name = "k8s_port_${each.value.name}"

  depends_on = [
    openstack_networking_port_v2.ports_disk
  ]
}

resource "openstack_compute_instance_v2" "vms_disk" {
  for_each = var.vms_disk

  name               = each.value.name
  flavor_name        = each.value.flavor
  security_groups    = [ openstack_networking_secgroup_v2.secgroup_1.name ]  
  key_pair           = openstack_compute_keypair_v2.keypair.name
  
  dynamic network {
    for_each = each.value.networks
    content{  
        port   = data.openstack_networking_port_v2.ports_disk[each.key].id
    }
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.img_disk[each.key].id
    source_type           = "image"
    volume_size           = each.value.volume_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }  

  depends_on = [
    openstack_networking_port_v2.ports,
    openstack_networking_secgroup_v2.secgroup_1
  ]
}

resource "openstack_compute_instance_v2" "vms" {
  for_each = var.vms

  name               = each.value.name
  flavor_name        = each.value.flavor
  security_groups    = [ openstack_networking_secgroup_v2.secgroup_1.name ]  
  key_pair           = openstack_compute_keypair_v2.keypair.name
  image_id           = data.openstack_images_image_v2.img[each.key].id

  dynamic network {
    for_each = each.value.networks
    content{  
        port   = data.openstack_networking_port_v2.ports[each.key].id
    }
  }

  depends_on = [
    openstack_networking_port_v2.ports,
    openstack_networking_secgroup_v2.secgroup_1
  ]
}