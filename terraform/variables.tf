
variable sec_group_rules{
    type = map(object({direction = string, ethertype = string, protocol = string, port_range_min = string, port_range_max = string, remote_ip_prefix = string }))
    default = {
        rule1 = {
            direction = "ingress"
            ethertype = "IPv4"
            protocol = "tcp"
            port_range_min = "22"
            port_range_max = "50000"
            remote_ip_prefix = "0.0.0.0/0"
        },
        rule2 = {
            direction = "ingress"
            ethertype = "IPv4"
            protocol = "udp"
            port_range_min = "22"
            port_range_max = "50000"
            remote_ip_prefix = "0.0.0.0/0"
        }                              
    }
}

variable public_key {
    type = object({name = string, file = string})
    default = {
        name = "k8s"
        file = "/home/eduardoefb/.ssh/id_rsa.pub"
    }
}

variable domain {
    type = map(string)    
    default = {
        zone        = "kubespray.int."
        mail        = "foo@k8s.int"
        description = "Kubespray zone"
    }
}

variable oam_network{
    type = object({ name = string, allowed_addresses = string})
    default = {
        name = "kubespray",
        allowed_addresses = "10.5.0.0/24"
    }
}

variable vms {
    type = map(object({name = string, flavor = string, image = string, networks = list(string), ip = string }))
    default = { 
            master01  = { name = "master01",  flavor = "m1.medium", image = "ubuntu_20.04", networks = [ "kubespray"], ip="10.5.0.20" },
            worker01  = { name = "worker01",  flavor = "m1.medium", image = "ubuntu_20.04", networks = [ "kubespray"], ip="10.5.0.30" },
            worker02  = { name = "worker02",  flavor = "m1.medium", image = "ubuntu_20.04", networks = [ "kubespray"], ip="10.5.0.31" },            
            #worker03  = { name = "worker03",  flavor = "m1.xlarge", image = "ubuntu_20.04", networks = [ "kubespray"], ip="10.5.0.32" },
            #worker04  = { name = "worker04",  flavor = "m1.xlarge", image = "ubuntu_20.04", networks = [ "kubespray"], ip="10.5.0.33" },
            #worker05  = { name = "worker05",  flavor = "m1.xlarge", image = "ubuntu_20.04", networks = [ "kubespray"], ip="10.5.0.34" },
            #nfs01  = { name = "worker01",  flavor = "m1.medium", image = "debian_10", networks = [ "kubespray"], ip="10.5.0.40" },
            #reg01  = { name = "worker02",  flavor = "m1.medium", image = "ubuntu_20.04", networks = [ "kubespray"], ip="10.5.0.42" },            
    }
}

variable vms_disk {
    type = map(object({name = string, flavor = string, image = string, volume_size = string, networks = list(string), ip = string }))
    default = { 
            nfs01  = { name = "nfs01",  flavor = "m1.medium", image = "debian_10", volume_size = "40", networks = [ "kubespray"], ip="10.5.0.40" },
            reg01  = { name = "reg01",  flavor = "m1.medium", image = "ubuntu_20.04", volume_size = "40", networks = [ "kubespray"], ip="10.5.0.42" },
    }
}

data "openstack_networking_subnet_v2" "k8s_oam_network" {
  name = "kubespray"
}
