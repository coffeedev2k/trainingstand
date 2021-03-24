variable "region" {
  default = "eu-central-1"
}

variable "cidr_block" {
  default = "172.16.0.0/16"
}

variable "env" {
  default = "staging"
}
# SUBNETS CIDRs ##########################################################################################

variable "cidr_block_routed" {
  default = [
    "172.16.1.0/24",
    "172.16.11.0/24",
    "172.16.21.0/24",
  ]
}

variable "cidr_block_natted" {
  default = [
    "172.16.0.0/24",
    "172.16.10.0/24",
    "172.16.20.0/24",
  ]
}

variable "cidr_block_stuff" {
  default = [
    "172.16.3.0/24",
    "172.16.13.0/24",
    "172.16.23.0/24",
  ]
}

variable "cidr_block_stuff-routed" {
  default = [
    "172.16.2.0/24",
    "172.16.12.0/24",
    "172.16.22.0/24",
  ]
}

# INSTANCES ##########################################################################################
variable "web_cluster_instance" {
  default = "t2.micro"
}

variable "manage_cluster_instance" {
  default = "t2.micro"
}

variable "datacluster_instance" {
  default = "t2.micro"
}

# INSTANCES TAGS ##########################################################################################

variable "web_cluster_instance_name" {
  default = "web_cluster_instance"
}

variable "manage_cluster_instance_name" {
  default = "web_cluster_instance"
}

variable "datacluster_instance_name" {
  default = "web_cluster_instance"
}
# create role ###############################################################################################
variable "create" {
  description = "Create Module, defaults to true."
  default     = true
}

variable "name" {
  description = "Name for resources, defaults to \"consul-auto-join-instance-role-aws\"."
  default     = "consul-auto-join-aws"
}

########## keys #############################################################################################
variable "key_name" {
  description = "ssh key"
  default     = "VM-terraform"
}

########## AMI #################################################################################################
variable "manage_cluster_ami_id" {
  description = "id of ami with consul nomad vault for control_cluster target"
  default     = "ami-08a1a61694dd1c82f"
}
variable "web_cluster_ami_id" {
  description = "id of ami with web_cluster target"
  default     = "ami-08a1a61694dd1c82f"
}
variable "datacluster_ami_id" {
  description = "id of ami data_cluster target"
  default     = "ami-08a1a61694dd1c82f"
}
