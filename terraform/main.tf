resource "null_resource" "vagrant_vm" {
  triggers = {
    vagrantfile_hash = filesha256("../vagrant/Vagrantfile")
  }

  # Provision VM with Ansible
  provisioner "local-exec" {
    command = <<EOT
cd ../vagrant && vagrant up
ansible-playbook -i ../ansible/inventory/hosts.ini ../ansible/playbook.yml --limit vm
EOT
  }

  # Cleanup VM
  provisioner "local-exec" {
    when    = destroy
    command = "cd ../vagrant && vagrant destroy -f"
  }
}
