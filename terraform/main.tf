resource "null_resource" "vagrant_vm" {
  # Trigger rebuild si Vagrantfile change
  triggers = {
    vagrantfile_hash = filesha256("../vagrant/Vagrantfile")
  }

  # Provision VM
  provisioner "local-exec" {
    command = "cd ../vagrant && vagrant up"
  }

  # Cleanup VM
  provisioner "local-exec" {
    when    = destroy
    command = "cd ../vagrant && vagrant destroy -f"
  }
}
