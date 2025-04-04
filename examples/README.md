# Examples

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
        <a href="#infrastructure">Infrastructure</a>
    </li>
    <li>
        <a href="#example-of-use">Example of use</a>
    </li>
  </ol>
</details>

## Infrastructure

| Example | Link | Description | 
| ------- | ---- | ----------- |
| Minimal DS Local | [kind_minimal_ds_local](kind_minimal_ds_local/) | Minimal Data Space (FIWARE) deployment in a local Kind cluster. |
| Minimal DS Local + Raw Consumer | [raw_fiware_components-ds_local](raw_fiware_components-ds_local/) | Minimal Data Space (FIWARE) deployment in a local Kind cluster and a raw consumer. |
| Raw Consumer | [raw_fiware_consumer](raw_fiware_consumer/) | Raw Fiware consumer deployment (also with Trust Anchor). |
| Kind Cluster | [kind_cluster](kind_cluster/) | Kind cluster deployment. |
| K3s Cluster | [k3s_cluster](k3s_cluster/) | K3s cluster deployment. |

## Example of use

Remember move to the example folder you want to use.

```bash
cd ./examples/<example_folder>
```

In the example folder, **deploy** the infrastructure using: `make init_apply`. Or **destroy** the infrastructure using: `make destroy`.
