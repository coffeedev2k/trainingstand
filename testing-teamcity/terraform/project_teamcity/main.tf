provider "aws" { region = "eu-central-1" }



terraform {
  backend "s3" {
    bucket = "tarasov-a-adm-terraform-state"
    key    = "treaineeship_tarasov-a-adm/testing-teamcity/terraform/project_teamcity/terraform.tfstate"
    region = "eu-central-1"

    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
}



module "vpc-staging" {
  source = "../modules/aws_network"

  env = "staging"
  # size instances
  web_cluster_instance    = "t2.small"
  manage_cluster_instance = "t2.micro"
  datacluster_instance    = "t2.micro"

  # ami instances
  manage_cluster_ami_id  = "ami-06ee2f5c03014b8e1" 
  web_cluster_ami_id  = "ami-0cd3340aa1c8e5609" 
  datacluster_ami_id  = "ami-073d58fdef9abe5f3" 
  # network
  /*
  cidr_block_natted       = ["172.16.0.0/24", "172.16.10.0/24"]
  cidr_block_routed       = ["172.16.1.0/24", "172.16.11.0/24"]
  cidr_block_stuff-routed = ["172.16.2.0/24", "172.16.12.0/24"]
  cidr_block_stuff        = ["172.16.3.0/24", "172.16.13.0/24"]
  */
  cidr_block_natted       = ["172.16.0.0/24"]
  cidr_block_routed       = ["172.16.1.0/24"]
  cidr_block_stuff-routed = ["172.16.2.0/24"]
  cidr_block_stuff        = ["172.16.3.0/24"]


}
