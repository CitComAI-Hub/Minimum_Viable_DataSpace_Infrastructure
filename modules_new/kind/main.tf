locals {
  # Reparte los workers entre var.zones, round-robin
  workers = [
    for i in range(var.worker_count) : {
      index = i
      zone  = var.zones[i % length(var.zones)]
    }
  ]
}

resource "kind_cluster" "default" {
  name            = var.cluster_name
  node_image      = var.node_image
  kubeconfig_path = pathexpand(var.kubeconfig_path)
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # Control-plane: preparado para un Ingress Controller (nginx) y
    # con los puertos 80/443 del contenedor mapeados al host.
    node {
      role = "control-plane"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      dynamic "extra_port_mappings" {
        for_each = var.add_extra_ports
        content {
          container_port = extra_port_mappings.value.container_port
          host_port      = extra_port_mappings.value.host_port
          protocol       = extra_port_mappings.value.protocol
        }
      }
    }

    # Workers, cada uno etiquetado con una "zona" simulada
    dynamic "node" {
      for_each = local.workers
      content {
        role = "worker"

        kubeadm_config_patches = [
          "kind: JoinConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"topology.kubernetes.io/zone=${node.value.zone}\"\n"
        ]
      }
    }
  }
}
