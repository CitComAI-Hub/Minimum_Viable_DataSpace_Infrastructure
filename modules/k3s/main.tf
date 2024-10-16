resource "docker_container" "k3s_server" {
  image      = "rancher/k3s:${var.docker_version}"
  name       = var.cluster_name
  command    = ["server"]
  privileged = true #! Mandatory for k3s
  restart    = "always"

  dynamic "ports" {
    for_each = var.add_ports
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }

  env = [
    "K3S_KUBECONFIG_OUTPUT=${var.k3s_kubeconfig.output_path}/${var.k3s_kubeconfig.output_file}",
    "K3S_KUBECONFIG_MODE=${var.k3s_kubeconfig.mode}",
    # "K3S_TOKEN=${var.K3S_TOKEN}",
  ]

  volumes {
    host_path      = abspath("./")
    container_path = var.k3s_kubeconfig.output_path
  }
}
