source "docker" "myimg" {
  image       = "sphinxgaia/ansible:ubuntu14.04"
  export_path = "packer_example"
  run_command = ["-d", "-i", "-t", "--entrypoint=/bin/bash", "{{.Image}}"]
}

build {
  sources = [
    "source.docker.myimg"
  ]

  provisioner "ansible-local" {
    playbook_file   = "./playbook.yml"
    extra_arguments = ["--extra-vars", \"pizza_toppings=${var.topping}\""]
  }
}


