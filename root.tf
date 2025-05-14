provider "aws" {
    region = "ap-northeast-2"
}


module "tf-vpc" {
    source = "./vpc"
}


module "tf-cluster" {
    source = "./eks"
    tf-vpc-id = module.tf-vpc.tf-vpc-id
    tf-vpc-prv-sub1-id = module.tf-vpc.tf-vpc-prv-sub1-id
    tf-vpc-prv-sub2-id = module.tf-vpc.tf-vpc-prv-sub2-id
    tf-vpc-pub-sub1-id = module.tf-vpc.tf-vpc-pub-sub1-id
    tf-vpc-pub-sub2-id = module.tf-vpc.tf-vpc-pub-sub2-id
}
