resource "aws_instance" "k8smaster" {
  ami           = var.ami
  instance_type = lookup(var.instance_type,terraform.workspace)

  security_groups = ["${var.secgroup}"]
  key_name        = var.seckey
  
  tags = {
    Name = "k8smaster-node"
  }
 
  connection {
    user        = var.ansible_user
    private_key = file(var.private_key)
    host        = self.public_ip
  }
  
  provisioner "remote-exec" {
    inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt install ansible -y"]
  }

  # This is where we configure the instance with ansible-playbook
  # install K8S on master node
  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >masterhost;
      echo "[k8smaster]" | tee -a masterhost;
      echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a masterhost;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i masterhost master-node-playbook.yml
    EOT
  }
}

output "ec2_masternode_publicip" {
  value = "${aws_instance.k8smaster.public_ip}"
}
