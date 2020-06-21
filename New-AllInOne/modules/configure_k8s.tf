resource "aws_instance" "k8smaster" {
  ami           = data.aws_ami.ec2_type.id
  instance_type = var.instance_type["master"]

  security_groups = ["${aws_security_group.sec_grp.name}"]
  key_name        = aws_key_pair.new_key.key_name

  tags = {
    Name = "k8smaster-node"
  }

  connection {
    user        = var.ansible_user
    private_key = tls_private_key.access_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt install ansible -y"]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >k8s/masterhost;
      echo "[k8smaster]" | tee -a k8s/masterhost;
      echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a k8s/masterhost;
      ansible-playbook -u ${var.ansible_user} --private-key ${local_file.key_file.filename} -i k8s/masterhost k8s/master-node-playbook.yml
    EOT
  }

  depends_on = [
    tls_private_key.access_key,
    aws_key_pair.new_key,
    aws_security_group.sec_grp
  ]
}

resource "aws_instance" "k8sworker" {
  ami           = data.aws_ami.ec2_type.id
  instance_type = var.instance_type["worker"]

  security_groups = ["${aws_security_group.sec_grp.name}"]
  key_name        = aws_key_pair.new_key.key_name

  count = 1

  connection {
    user        = var.ansible_user
    private_key = tls_private_key.access_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt install ansible -y"]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >k8s/workerhost;
      echo "[k8sworker]" | tee -a k8s/workerhost;
      echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a k8s/workerhost;
      cat k8s/masterhost | tee -a k8s/workerhost;
      ansible-playbook -u ${var.ansible_user} --private-key ${local_file.key_file.filename} -i k8s/workerhost k8s/worker-node-playbook.yml
    EOT
  }

  tags = {
    Name = "k8sworker-node.${count.index}"
  }
  depends_on = [aws_instance.k8smaster]
}

output "k8smaster_ip" {
  value = aws_instance.k8smaster.public_ip
}

output "k8sworker_ip" {
  value = aws_instance.k8sworker.*.public_ip
}
