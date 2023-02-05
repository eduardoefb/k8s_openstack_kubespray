#!/usr/bin/python3

import json

inv = open("../ansible/hosts", "w")
v = open("../ansible/vars.yml", "w")
conf = open("configrc", "w")

o = json.load(open("../terraform/terraform.tfstate", "r"))

for x in o["resources"]:
    if x["type"] == "openstack_dns_zone_v2":
        zone=x["instances"][0]["attributes"]["name"]
        zone=zone[:len(zone)-1]

v.write("c: C=BR\n")         
v.write("domain: " + str(zone) + "\n")
v.write("nodes:\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:            
            if "index_key" in vm:                 
                if "access_ip_v4" in vm["attributes"]:
                    inv.write("[" + str(vm["index_key"]) + "]\n")
                    inv.write(vm["attributes"]["access_ip_v4"] + "\n\n")    
                    #v.write("  - " + str(vm["attributes"]["access_ip_v4"]) + "\n")                 
                    v.write("  - " + vm["index_key"]+ "." + str(zone)  + "\n")                 
                    if "agw" in str(vm["index_key"]):
                        conf.write("alias " + str(vm["index_key"]) + "=\"ssh -o StrictHostKeyChecking=no ubuntu@" + str(vm["attributes"]["access_ip_v4"]) + "\"\n")
                    else:
                        conf.write("alias " + str(vm["index_key"]) + "=\"ssh -o StrictHostKeyChecking=no debian@" + str(vm["attributes"]["access_ip_v4"]) + "\"\n")



v.write("k8s_nodes:\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:
                    if "master"  in str(vm["index_key"])  or "worker" in str(vm["index_key"]):
                        v.write("  - " + str(vm["attributes"]["access_ip_v4"]) + "\n")                 

v.write("k8s_master:\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:
                    if "master"  in str(vm["index_key"]):
                        v.write("  - name: " + str(vm["index_key"]) + "\n")
                        v.write("    ip: " + str(vm["attributes"]["access_ip_v4"]) + "\n")    


v.write("k8s_worker:\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:
                    if "worker"  in str(vm["index_key"]):
                        v.write("  - name: " + str(vm["index_key"]) + "\n")
                        v.write("    ip: " + str(vm["attributes"]["access_ip_v4"]) + "\n")  

for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:   
                    v.write(str(vm["index_key"]) + ": " + str(vm["attributes"]["access_ip_v4"]) + "\n")                 
                    if "agw" in str(vm["index_key"]):
                        conf.write("alias " + str(vm["index_key"]) + "=\"ssh -o StrictHostKeyChecking=no ubuntu@" + str(vm["attributes"]["access_ip_v4"]) + "\"\n")
                    else:
                        conf.write("alias " + str(vm["index_key"]) + "=\"ssh -o StrictHostKeyChecking=no debian@" + str(vm["attributes"]["access_ip_v4"]) + "\"\n")


inv.write("[NODES]\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:
                    inv.write(vm["attributes"]["access_ip_v4"] + "\n")    



# MASTER
inv.write("\n[MASTER]\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:                       
                    if "master" in str(vm["index_key"]):
                         inv.write(vm["attributes"]["access_ip_v4"] + "\n")

# WORKER
inv.write("\n[WORKER]\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:                       
                    if "worker" in str(vm["index_key"]):
                         inv.write(vm["attributes"]["access_ip_v4"] + "\n")

# AGW
inv.write("\n[AGW]\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:                       
                    if "agw" in str(vm["index_key"]):
                         inv.write(vm["attributes"]["access_ip_v4"] + "\n")       

# NFS
inv.write("\n[NFS]\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:                       
                    if "nfs" in str(vm["index_key"]):
                         inv.write(vm["attributes"]["access_ip_v4"] + "\n")                                             

# REGISTRY
inv.write("\n[REGISTRY]\n")
for m in o["resources"]:    
    if str(m["name"] == "vms"):
        for vm in m["instances"]:
            if "index_key" in vm:                
                if "access_ip_v4" in vm["attributes"]:                       
                    if "reg" in str(vm["index_key"]):
                         inv.write(vm["attributes"]["access_ip_v4"] + "\n")  

inv.write("\n")
inv.close()
v.close()
conf.close()