variable "cluster_name" {
  type        = string
  description = "The name of the kind cluster"
  default     = "kind-cluster"
}

variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "namespace" {
  type        = string
  description = "The namespace to deploy the Ingress Nginx controller into"
  default     = "ingress-nginx-proxy"
}

variable "service_type" {
  type        = string
  description = "The service type of the Ingress Nginx controller"
  default     = "NodePort" # or LoadBalancer
}

variable "add_ports" {
  type = list(
    object(
      {
        app_protocol = string
        name         = string
        port         = number
        protocol     = string
        target_port  = string
      }
    )
  )
  description = "Extra ports to be added to control-plane node"
  default = [
    {
      app_protocol = "http"
      name         = "http-default"
      port         = 80
      protocol     = "TCP"
      target_port  = "http"
    },
    {
      app_protocol = "https"
      name         = "https-dafault"
      port         = 443
      protocol     = "TCP"
      target_port  = "https"
    }
  ]
}
