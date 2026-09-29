variable "namespace" {
  description = "Namespace of the CloudNativePG operator"
  type        = string
  default     = "cnpg-system"
}

variable "chart_version" {
  description = "cloudnative-pg chart version (https://github.com/cloudnative-pg/charts)"
  type        = string
  default     = "0.29.1"
}
