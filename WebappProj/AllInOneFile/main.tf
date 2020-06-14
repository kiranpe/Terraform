module "k8s_instances" {
  source = "./k8s/modules/k8s"
}

module "jenkis_instance" {
   source = "./jenkins/modules/jenkins"
}

#module "nexus" {
#   source = "./nexus/modules/nexus"
#}
