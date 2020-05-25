variable "private_key" {
  default = "/sites/keyfile.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "ami" {
  default = "ami-05c1fa8df71875112"
}

variable "type" {
  default = "t2.medium"
}

variable "secgroup" {
  default = "k8scluster"
}

variable "seckey" {
  default = "k8skey"
}
