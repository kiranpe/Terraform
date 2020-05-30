resource "aws_instance" "jenkins" {
  ami           = var.ami
  instance_type = var.instance_type

  security_groups = ["${var.secgroup}"]
  key_name        = var.seckey

  connection {
    user        = var.ansible_user
    private_key = file(var.private_key)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt-get install -f ansible -y && sudo hostnamectl set-hostname jenkins"]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >java;
	  echo "[java]" | tee -a java;
	  echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" | tee -a java;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i java mvn-java.yml
    EOT
  }

  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >jenkins;
      echo "[jenkinsci]" | tee -a jenkins;
      echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a jenkins;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i jenkins jenkins-docker.yml -e "hub_username=DockerUser hub_password=DockerPass"
    EOT
  }

  tags = {
    Name = "jenkins-instance"
  }
}


output "jenkins-url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}
