cluster_name = "ds-local-cluster"
add_extra_mounts = [
    {
        host_path      = "../../modules/waltid_ssikit/data/did_keys/",
        container_path = "/etc/kubernetes/data/ssikit"
    },
    {
        host_path      = "../../modules/waltid_ssikit/data/nginx/",
        container_path = "/etc/kubernetes/data/nginx"
    }
]