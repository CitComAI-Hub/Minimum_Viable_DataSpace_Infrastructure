# Raw Fiware Components & Fiware Data Space Local Example

This example is a demonstration of how to deploy the Fiware Data Space Connector components without pre-configuration, alongside the pre-configured local data space connector example ([FIWARE's local deployment](https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD)).

The entire deployment is performed on a Kind cluster (with 3 nodes), and Terraform is used to manage all resources. The goal is to show how to deploy the Fiware Data Space Connector components and how to interact with them.

![minimal_ds](./images/minimum_dataspace_arch.svg)

## 1. Deployment ([_back to top_](#raw-fiware-components-fiware-data-space-local-example))

> [!NOTE]
>
> Check the permissions of the scripts:
>
> ```bash
> sudo chmod +x ../../modules/kind/metal_lb/scripts/get_ips.sh
> sudo chmod +x ../../modules/ca_configuration/scripts/generate_ca_certificates.sh
> ```

From `<repo_path>/examples/raw_fiware_components-ds_local` folder, you need to execute the following commands:

To deploy the minimal data space, you need to execute the following command:

```bash
make init_apply
```

> [!WARNING]
>
> The deployment time is around **14 minutes** (depending on the resources of your machine, this time can vary).
