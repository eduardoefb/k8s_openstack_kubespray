

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = "k8s_security_group"
  description = "My k8s security group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
    for_each = var.sec_group_rules
      direction         = each.value.direction
      ethertype         = each.value.ethertype
      protocol          = each.value.protocol
      port_range_min    = each.value.port_range_min
      port_range_max    = each.value.port_range_max
      remote_ip_prefix  = each.value.remote_ip_prefix
      security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}


data "openstack_networking_network_v2" "oam_net" {  
  name = var.oam_network.name
}
