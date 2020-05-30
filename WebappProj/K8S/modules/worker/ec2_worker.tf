resource "aws_instance" "k8sworkernode" {
  ami           = var.ami
  instance_type = lookup(var.instance_type,terraform.workspace)

  security_groups = ["${var.secgroup}"]
  key_name        = var.seckey

  count = 2

  connection {
    user        = var.ansible_user
    private_key = file(var.private_key)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt install ansible -y"]
  }

  # This is where we configure the instance with ansible-playbook
  # install K8S on worker node
  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >workerhost;
      echo "[k8sworker]" | tee -a workerhost;
      echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a workerhost;
      cat ../masternode/masterhost | tee -a workerhost;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i workerhost worker-node-playbook.yml
    EOT
  }

  tags = {
    Name = "k8sworker-node.${count.index}"
  }

}

output "ec2_workernode_publicip" {
  value = "${aws_instance.k8sworkernode.*.public_ip}"
}
