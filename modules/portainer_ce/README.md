# Portainer CE in Docker

This module deploys [Portainer](https://www.portainer.io/) CE in a Docker container. Portainer is a lightweight management UI which allows you to easily manage your different Docker environments (Docker hosts or Swarm clusters).

Needs a kubernetes cluster to run.

## Other configurations

### Dashboard access

```
https://localhost:9443
```

![config_portainer](./images/portainer_config.png)

### Admin pass

Example of pass to add to the user admin. 

`LSvJz#5Q$hw!sY`

### Volumes

Avoid remove the volumes if you want to keep the data after the container is removed. Add the lifecycle block to the volume resource to prevent the volume from being removed.

```bash
resource "docker_volume" "portainer_data" {
  name = "portainer_data"
  lifecycle {
    prevent_destroy = true
  }
}
```

### Get the IP

Using kubectl get the ip for the portainer service:

```bash
kubectl get services -n portainer
```