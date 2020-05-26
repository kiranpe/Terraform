output "ec2_workernode_publicip" {
  value = "${aws_instance.k8sworker.*.public_ip}"
}

output "ec2_masternode_publicip" {
  value = "${aws_instance.k8smaster.public_ip}"
}
