resource "aws_instance" "nexus" {
  ami           = "${data.aws_ami.ec2_instance.id}"
  instance_type = var.instance_type

  security_groups = ["${var.secgroup}"]
  key_name        = var.seckey

  connection {
    user        = var.ansible_user
    private_key = file(var.private_key)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt install ansible -y && sudo hostnamectl set-hostname nexus"]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
          >nexus;
          echo "[nexus]" | tee -a nexus;
          echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3" | tee -a nexus;
          ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i nexus nexus-repo.yml
    EOT
  }

  root_block_device {
    volume_size = "10"
  }

  tags = {
    Name = "nexus-instance"
  }
}


output "nexus-repo" {
  value = "http://${aws_instance.nexus.public_ip}:8081"
}
