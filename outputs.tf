###############################################################
#                   STOCKAGE DE MES VARIABLE                  #
###############################################################

output "ip_address_i2" {
    value = aws_instance.ec2_myinstance_${var.NAME}.public_ip
}
