resource "kubernetes_namespace_v1" "trust_anchor" {
  metadata {
    name = var.trust_anchor_namespace
  }
}

# Database of the Trusted Issuers List in the shared PostgreSQL instance
# (deployed by kind_cluster/apps), with its password managed by Vault
module "trust_anchor_database" {
  source = "../../modules/postgres/database"

  name      = "til"
  namespace = kubernetes_namespace_v1.trust_anchor.metadata[0].name
  database  = "tildb"
  username  = "til"
}

module "trust_anchor" {
  source = "../../modules/fiware/trust_anchor"

  namespace           = kubernetes_namespace_v1.trust_anchor.metadata[0].name
  ingress_class_name  = var.ingress_class_name
  ingress_annotations = var.ingress_annotations
  tir_hostname        = var.trust_anchor_tir_hostname
  til_hostname        = var.trust_anchor_til_hostname

  database = {
    host         = module.trust_anchor_database.host
    port         = module.trust_anchor_database.port
    name         = module.trust_anchor_database.database
    username     = module.trust_anchor_database.username
    secret_name  = module.trust_anchor_database.secret_name
    password_key = module.trust_anchor_database.password_key
  }
}
