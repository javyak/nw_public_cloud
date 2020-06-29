# Output values, get with terraform output <name>
# Use the user secret key to modify AWS credentials and config files

output "alb_fqdn" {
  value = aws_lb.iot-web-alb.dns_name
}

output "web1_fqdn" {
  value = aws_instance.web_server1.public_dns
}

output "web2_fqdn" {
  value = aws_instance.web_server2.public_dns
}

output "jump_ip" {
  value = aws_instance.jump_station.public_ip
}

output "database_ip" {
  value = aws_instance.database_sever.private_ip
}

output "web_server1_ip" {
  value = aws_instance.web_server1.private_ip
}

output "web_server2_ip" {
  value = aws_instance.web_server2.private_ip
}

output "pepito_key_id" {
  value = aws_iam_access_key.pepito_key.id
}

# Warning: the secret key will be visible in the TF state file. Use the encrypted option.
output "pepito_secret" {
  value = aws_iam_access_key.pepito_key.secret
}
# Use the following output to get an encrypted key, PGP configuration required.
# output "pepito_encrypted_secret" {
#  value = aws_iam_access_key.pepito.encrypted_secret 
#}