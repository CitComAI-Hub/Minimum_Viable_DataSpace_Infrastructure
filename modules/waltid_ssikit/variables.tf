variable "namespace" {
  type    = string
  default = "did-server"
}

variable "ca_clusterissuer_name" {
  type        = string
  description = "The name of the clusterissuer"
  default     = "ca-certificates"
}

variable "nginx_version" {
  type        = string
  description = "The version of the web server"
  default     = "1.25.4"
}

variable "nginx_data_path" {
  type        = string
  description = "The path of the nginx data"
  default     = "data/nginx"
}

variable "nginx_conf_path" {
  type        = string
  description = "The path of the nginx configuration"
  default     = "config/nginx"
}

variable "nginx_port" {
  type = list(
    object(
      {
        container_port = number
      }
    )
  )
  description = "The port of the web server"
  default = [
    {
      container_port = 80
    }
  ]
}

variable "nginx_volume_mount" {
  type = list(
    object(
      {
        name       = string
        mount_path = string
      }
    )
  )
  description = "The volume of the web server"
  default     = []

}

variable "nginx_volume_path" {
  type        = string
  description = "The path of the nginx volume"
  default     = "/etc/kubernetes/data/nginx"
}

#! Incomatible when is using as a module
# variable "host" {
#   type = string
# }
# variable "client_certificate" {
#   type = string
# }
# variable "client_key" {
#   type = string
# }
# variable "cluster_ca_certificate" {
#   type = string
# }
