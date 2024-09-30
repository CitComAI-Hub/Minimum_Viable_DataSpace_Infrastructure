variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "namespace" {
  type        = string
  description = "The namespace to deploy the traefik ingress controller"
  default     = "ingress-traefik-proxy"
}