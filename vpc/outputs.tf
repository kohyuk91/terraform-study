output "tf-vpc-id" {
  value = aws_vpc.tf-vpc.id
}

output "tf-vpc-pub-sub1-id" {
  value = aws_subnet.tf-vpc-pub-sub1.id
}
output "tf-vpc-pub-sub2-id" {
  value = aws_subnet.tf-vpc-pub-sub2.id
}

output "tf-vpc-prv-sub1-id" {
  value = aws_subnet.tf-vpc-prv-sub1.id
}
output "tf-vpc-prv-sub2-id" {
  value = aws_subnet.tf-vpc-prv-sub2.id
}
