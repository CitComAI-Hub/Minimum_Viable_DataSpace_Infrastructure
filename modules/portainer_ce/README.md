# Portainer CE in Docker

This module deploys [Portainer](https://www.portainer.io/) CE in a Docker container.

Needs a kubernetes cluster to run.

## Other configurations

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

### Admin pass

Example of pass to add to the user admin. 

`LSvJz#5Q$hw!sY`