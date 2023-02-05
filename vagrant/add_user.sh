#!/bin/bash

useradd -m debian -s /bin/bash
mkdir -p /home/debian/.ssh
cat << EOF > /home/debian/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4tzrayU6ahMhmWuicy+oFfy//9oB+2EdbbmDfA0d+k3SpYjWVqho64/L+sQIAN0RGBJx42GkbKi8B6AriPw8omLOCk2WSYW3ymEC7n3l32M5T4cLr8LIYwoMOBZkMtRc3H62PrHgDoTJLhUOvT2ewj1SLl7iU5gQuInwPE6jWooIb8R6KMUl31qNpkafCVPz5ovw0iYbDamHQF6sq081Xl39px2345T8TofIAocyBUfCOstmAvPaD9lXIV3j9JmPhAy0oweXpxdPiQzBHXepLh/jrvHrV5ggl2iwmLgF3uzwYdFlQN6eCniBtBEcGqEacb6oP2KHfHer04WIbAMHZ
EOF
chown -R debian:debian /home/debian
echo "debian ALL = NOPASSWD: ALL" >> /etc/sudoers

useradd -m ubuntu -s /bin/bash
mkdir -p /home/ubuntu/.ssh
cat << EOF > /home/ubuntu/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4tzrayU6ahMhmWuicy+oFfy//9oB+2EdbbmDfA0d+k3SpYjWVqho64/L+sQIAN0RGBJx42GkbKi8B6AriPw8omLOCk2WSYW3ymEC7n3l32M5T4cLr8LIYwoMOBZkMtRc3H62PrHgDoTJLhUOvT2ewj1SLl7iU5gQuInwPE6jWooIb8R6KMUl31qNpkafCVPz5ovw0iYbDamHQF6sq081Xl39px2345T8TofIAocyBUfCOstmAvPaD9lXIV3j9JmPhAy0oweXpxdPiQzBHXepLh/jrvHrV5ggl2iwmLgF3uzwYdFlQN6eCniBtBEcGqEacb6oP2KHfHer04WIbAMHZ
EOF
chown -R ubuntu:ubuntu /home/ubuntu
echo "ubuntu ALL = NOPASSWD: ALL" >> /etc/sudoers

exit 0
