# Examples developed

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#ds-fully-local">Data Space Fully Local</a>
    </li>
    <li>
        <a href="#kind-cluster">Kind Cluster</a>
        <ul>
            <li><a href="#cheatsheet">Cheatsheet</a></li>
      </ul>
    </li>
    <li><a href="#minimal-ds">Minimal DS</a></li>
  </ol>
</details>

## Data Space Fully Local

Deployment of the Fiware [Demo Setup DSBA-compliant Data Space](https://github.com/FIWARE-Ops/fiware-gitops/tree/master/aws/dsba) in a local environment.

**Source:** [ds_fully_local](ds_fully_local/)

## Kind Cluster

**Source:** [kind_cluster](kind_cluster/)

### Cheatsheet

```
https://localhost:9443
```

Add a pass, for example: `LSvJz#5Q$hw!sY`

Using kubectl get the ip for the portainer service:

```bash
kubectl get services -n portainer
```

![config_portainer](images/portainer_config.png)

## Minimal Data Space

Minimal Data Space deployment.

**Source:** [minimal_ds](minimal_ds/)

![minimal_ds](images/minimum_dataspace_arch.png)