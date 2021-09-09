###############################################################
#                   PARTIE POUR LES CLES                      #
###############################################################

variable KEY_LIST {
  type        = list
  default     = ["instance1Ext", "instance2Ext"]
}

resource "tls_private_key" "ssh_key" {
    for_each    = toset(var.KEY_LIST)
    algorithm   = "RSA"
}

resource "aws_key_pair" "my_key_pair" {
    for_each    = toset(var.KEY_LIST)
    key_name    = "${var.NAME}-${each.value}"
    public_key  = tls_private_key.ssh_key[each.key].public_key_openssh
}

###############################################################
#                   STOKAGE DANS UN S3                        #
###############################################################
terraform {
  backend "s3" {
    bucket  = "terraformutopios"
    key     = "${var.S3_NAME}/terraform.tfstate"
    region  = "eu-west-3"
  }
  
}

############################################################### 
#                   CREATION DES INSTANCE                     #
###############################################################

resource "aws_instance" "ec2_myinstance_gr"{
    ami                     = var.AWS_REGION_AMIS[var.AWS_REGION]
    instance_type           = "t2.micro"
    tags = {
        Name = "${var.NAME}-ansible_exo_ec22"
    }
    key_name                = aws_key_pair.my_key_pair["instance2Ext"].key_name
    vpc_security_group_ids  = [aws_security_group.ec2_security_group_ansible_exo.id]
    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = tls_private_key.ssh_key["instance2Ext"].private_key_pem
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        scripts = ["scripts/script-init-intance2.sh"]
    } 
}

resource "aws_instance" "ec2_ansible_exo" {
    instance_type               = var.AWS_INSTANCE_TYPE
    ami                         = var.AWS_REGION_AMIS[var.AWS_REGION]
    vpc_security_group_ids      = [aws_security_group.ec2_security_group_ansible_exo.id]
    tags = {
        Name = "${var.NAME}-ansible_exo_ec21"
    }
    key_name                    = aws_key_pair.my_key_pair["instance1Ext"].key_name

    #on indique la configuration de connexion (ssh ou autre)
    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = tls_private_key.ssh_key["instance1Ext"].private_key_pem
        host        = self.public_ip
    }

    #un provisioner qui permet d'executer des scripts ou des commandes en ssh
    provisioner "remote-exec" {
        scripts = ["scripts/script-install-i1.sh"]
    }   
    # provisioner "remote-exec" {
    #     inline = ["echo ${tls_private_key.ssh_key["link-i1-to-i2"].private_key_pem} >> /home/ubuntu/.ssh/authorized_keys"]
    # }
    provisioner "file" {
        content     = tls_private_key.ssh_key["instance2Ext"].private_key_pem
        destination = "~/.ssh/id_rsa"
    }
    provisioner "remote-exec" {
        inline = ["sudo chmod 400 /home/ubuntu/.ssh/id_rsa"]
    }

    provisioner "remote-exec" {
        inline = [
            "cd FormationAnsible/Exo2/",
            "sudo bash -c 'echo -e \"\nhost_key_checking = False\" >> ansible.cfg' ",
            "sudo bash -c 'echo \"${aws_instance.ec2_myinstance_gr.public_ip} ansible_user=ubuntu\" > hosts'",
            "ansible-playbook playbook_docker.yml"
        ]
    }      
}



resource "aws_security_group" "ec2_security_group_ansible_exo" {
    name = "ec2_security_group_ansible_exo_${var.NAME}"
    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        protocol    = "tcp"
        from_port   = 10
        to_port     = 10000
        cidr_blocks = ["0.0.0.0/0"]
    }
}

