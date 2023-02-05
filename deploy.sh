#!/bin/bash

CWD=`pwd`

# Install dependencies:
pip3 install pyhcl

#sudo apt install -y python3-hcloud
cd terraform
terraform destroy --auto-approve
while ! terraform apply --auto-approve; do
    sleep 1
done

# Execute more apply commands:
for i in {0..10}; do terraform apply --auto-approve; done 

# Delete failed volumes:
for v in `openstack volume list | grep available | awk '{print $2}'`; do 
    openstack volume delete ${v}
done

# Start the deployment
cd ${CWD}/scripts
./inventory.py
cd ${CWD}/ansible
sleep 4
bash -x /home/eduardoefb/bin/update_dns.sh
sleep 4
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts registry.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts build.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts istio.yml

