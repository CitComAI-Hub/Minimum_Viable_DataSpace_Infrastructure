resource "docker_volume" "portainer_data" {
  name = "portainer_data"
}

resource "docker_container" "portainer_ce" {
  image        = "portainer/portainer-ce:${var.img_version}"
  name         = "portainer"
  restart      = "always"
  network_mode = "host" # This is required to access to kind cluster
  # ports {
  #   internal = 8000
  #   external = 8000
  # }
  # ports {
  #   internal = 9443
  #   external = 9443
  # }
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    container_path = "/data"
    volume_name    = docker_volume.portainer_data.name
  }
}

resource "null_resource" "portainerAgent_cluster" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${var.portainer_k8s_file_config}"
  }
}
