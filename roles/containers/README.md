# Containers role

## Variables

| Name | Description |
| ----- | ----- |
| `docker_mirror_proxy` | Configure Docker to use this URL as proxy for DockerHub |
| `docker_mirror_noproxy` | Ignore the Docker proxy for these hosts (e.g., `sapienzaapps.it` ignores all hosts under `sapienzaapps.it` domain) |
| `docker_mirror_cert` | Docker proxy self-signed certificate file (PEM), if any |
| `docker_autoclean` | Add a cronjob for pruning all Docker images at night |
