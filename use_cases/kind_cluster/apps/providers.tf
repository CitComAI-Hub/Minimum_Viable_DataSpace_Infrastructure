# Esta capa se aplica DESPUÉS de que la capa cluster haya escrito el kubeconfig.
# El fichero ../cluster-config.yaml ya existe cuando se ejecuta este terraform,
# por lo que los providers se inicializan correctamente sin necesidad de -target.

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
