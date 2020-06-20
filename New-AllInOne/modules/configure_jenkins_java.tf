resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ec2_type.id
  instance_type = var.instance_type["master"]

  security_groups = ["${aws_security_group.sec_grp.name}"]
  key_name        = aws_key_pair.new_key.key_name

  connection {
    user        = var.ansible_user
    private_key = tls_private_key.access_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt-get install -f ansible -y && sudo hostnamectl set-hostname jenkins"]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >jenkins/java;
	  echo "[java]" | tee -a jenkins/java;
	  echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a jenkins/java;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i jenkins/java jenkins/mvn-java.yml
    EOT
  }

  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >jenkins/jenkins;
      echo "[jenkinsci]" | tee -a jenkins/jenkins;
      echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a jenkins/jenkins;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i jenkins/jenkins jenkins/jenkins-docker.yml -e "hub_username=kiranp23 hub_password=Chinni.23"
    EOT
  }

  tags = {
    Name = "jenkins-instance"
  }

  depends_on = [
    tls_private_key.access_key,
    aws_key_pair.new_key,
    aws_security_group.sec_grp
  ]
}


output "jenkins-url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}
