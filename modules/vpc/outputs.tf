##########################################
# VPC Outputs
##########################################

output "vpc_id" {
  value = aws_vpc.this.id
}

##########################################
# Public Subnet Outputs
##########################################

output "public_subnet_ids" {
  value = [
    for subnet in aws_subnet.public :
    subnet.id
  ]
}

##########################################
# Private Subnet Outputs
##########################################

output "private_subnet_ids" {
  description = "IDs of the private subnets"

  value = [
    for subnet in aws_subnet.private :
    subnet.id
  ]
}

output "database_subnet_ids" {
  description = "IDs of the isolated database subnets"

  value = [
    for subnet in aws_subnet.database :
    subnet.id
  ]
}

