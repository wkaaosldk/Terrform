output "public_subnet_id_1" {
    value = aws_subnet.Public_Subnet_1.id
}

output "public_subnet_id_2" {
    value = aws_subnet.Public_Subnet_2.id
}


output "private_subnet_id" {
    value = aws_subnet.private_Subnet_1.id
}