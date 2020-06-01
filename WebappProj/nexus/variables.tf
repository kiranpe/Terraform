variable "private_key" {
  default = "/sites/keyfile.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "secgroup" {
  default = "k8scluster"
}

variable "seckey" {
  default = "k8skey"
}

variable "instance_type" {
  default = "t2.medium"
}
