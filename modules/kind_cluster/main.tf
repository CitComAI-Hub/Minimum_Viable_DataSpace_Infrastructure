resource "kind_cluster" "k8s_cluster" {
  name            = var.cluster_name
  kubeconfig_path = pathexpand(var.kubernetes_local_path)
  node_image      = var.kindest_version
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
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

      dynamic "extra_mounts" {
        for_each = var.add_extra_mounts
        content {
          host_path      = extra_mounts.value.host_path
          container_path = extra_mounts.value.container_path
        }
      }
    }
    node {
      role = "worker"
      dynamic "extra_mounts" {
        for_each = var.add_extra_mounts
        content {
          host_path      = extra_mounts.value.host_path
          container_path = extra_mounts.value.container_path
        }
      }
    }
    node {
      role = "worker"
      dynamic "extra_mounts" {
        for_each = var.add_extra_mounts
        content {
          host_path      = extra_mounts.value.host_path
          container_path = extra_mounts.value.container_path
        }
      }
    }
  }
}

resource "null_resource" "ingress_installation" {
  depends_on = [kind_cluster.k8s_cluster]

  provisioner "local-exec" {
    command = <<-EOF
        until kind get clusters | grep -q ${var.cluster_name}; do
          echo "Waiting for Kubernetes components to be ready..."
          sleep 5
        done
        kubectl apply -f ${var.ingress_config_file}
        kubectl wait --namespace ingress-nginx \
            --for=condition=ready pod \
            --selector=app.kubernetes.io/component=controller \
            --timeout=90s
    EOF
  }
}

resource "null_resource" "loadBalancer_installation" {
  depends_on = [null_resource.ingress_installation]

  provisioner "local-exec" {
    command = <<-EOF
        kubectl apply -f ${var.loadbalancer_config_file}
        kubectl wait --namespace metallb-system \
            --for=condition=ready pod \
            --selector=app=metallb \
            --timeout=90s
    EOF
  }

  # metallb-config.yaml download from https://kind.sigs.k8s.io/examples/loadbalancer/metallb-config.yaml
  provisioner "local-exec" {
    command = <<-EOF
        TEMPFILE=$(mktemp)
        cp ${var.path_module}/files/metallb-config.yaml $TEMPFILE
        VALUE=$(${var.path_module}/scripts/ips_for_loadBalancer.sh)
        sed -i "s|172.19.255.200-172.19.255.250|$VALUE|" $TEMPFILE
        kubectl apply -f $TEMPFILE
        rm $TEMPFILE
    EOF
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
