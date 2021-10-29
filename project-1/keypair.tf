# # use this if you want to give your key
# resource "aws_key_pair" "deployer" {
#   key_name   = "terraform_deployer"
#   public_key = file(var.public_key_path)
# }

# Generates a new key pair
resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# copy geberated key file to local
resource "aws_key_pair" "testkeypair" {
  key_name   = var.key_name
  public_key = tls_private_key.private-key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.private-key.private_key_pem}' > ./generatedKey.pem"
  }
}
