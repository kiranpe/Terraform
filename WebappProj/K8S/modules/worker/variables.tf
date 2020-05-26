variable "private_key" {
  default = "/sites/keyfile.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "ami" {
  default = "ami-05c1fa8df71875112"
}

variable "instance_type" {
   type = map

   default = {
    master = "t2.medium"
    worker = "t2.micro"
   }
}

variable "secgroup" {
  default = "k8scluster"
}

variable "seckey" {
  default = "k8skey"
}
