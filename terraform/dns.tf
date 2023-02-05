
resource "openstack_dns_zone_v2" "kubespray_zone" {
  name        = var.domain.zone
  email       = var.domain.mail
  description = "An example zone"
  ttl         = 3000
  type        = "PRIMARY"
}


resource "openstack_dns_recordset_v2" "kubespray_recordset" {
  for_each = var.vms
    zone_id     = openstack_dns_zone_v2.kubespray_zone.id
    name        = "${each.value.name}.${var.domain.zone}"
    description = var.domain.description
    ttl         = 3000
    type        = "A"
    records     = [ each.value.ip ]
}

resource "openstack_dns_recordset_v2" "kubespray_recordset_disk" {
  for_each = var.vms_disk
    zone_id     = openstack_dns_zone_v2.kubespray_zone.id
    name        = "${each.value.name}.${var.domain.zone}"
    description = var.domain.description
    ttl         = 3000
    type        = "A"
    records     = [ each.value.ip ]
}