#! /bin/bash

sudo apt update && sudo apt upgrade -y
sudo useradd userAnsible
sudo userAnsible:123456 | sudo chpasswd -e

sudo bash -c 'echo "userAnsible(ALL:ALL) NOPASSWS:ALL" >> /etc/sudoers.d'
# etc/ssh/sshd_config.d
sudo bash -c 'echo "PasswordAuthentication yes" > etc/ssh/sshd_config.d/ansibleconf'
sudo bash -c 'echo "PubKeyAuthentication yes" >> etc/ssh/sshd_config.d/ansibleconf'
sudo bash -c 'echo "PermitEmptyPasswords yes" >> etc/ssh/sshd_config.d/ansibleconf'
sudo systemctl restart sshd