resource "aws_instance" "nexus" {
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
    inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt install ansible -y && sudo hostnamectl set-hostname nexus"]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
          >nexus/nexus;
          echo "[nexus]" | tee -a nexus/nexus;
          echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a nexus/nexus;
          ansible-playbook -u ${var.ansible_user} --private-key ${local_file.key_file.filename} -i nexus/nexus nexus/nexus-repo.yml
    EOT
  }

  root_block_device {
    volume_size = "10"
  }

  tags = {
    Name = "nexus-instance"
  }

  depends_on = [
    tls_private_key.access_key,
    aws_key_pair.new_key,
    aws_security_group.sec_grp
  ]
}


output "nexus-repo" {
  value = "http://${aws_instance.nexus.public_ip}:8081"
}
