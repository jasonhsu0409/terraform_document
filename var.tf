variable "access_key" {
  type =  string
  default = ""
}
variable "secret_key" {
  type = string
  default = ""
}
# 設定 var AZ資源
variable "azs" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "cidr_all" {
  type = string
  default = "0.0.0.0/0"
}

variable "rds_username" {
  type = string
  default = ""
}
variable "rds_password" {
  type = string
  default = ""
}
variable "project" { 
    type = string
    default ="tfdeploy"
}
variable "state" {
  type = bool
  default = true
}
variable "prefix" {
  type = string
  default = "task-2"
}

variable "key" {
  type = string
  default = "jason-bastion"
}
variable "ami" {
  type = string
  default ="ami-005f9685cb30f234b"
}

variable "type" {
  type = string
  default ="t2.micro"
}