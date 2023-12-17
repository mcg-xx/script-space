# List of files

## docker_cleanup.sh
- Make it executeable `chmod +x docker_cleanup.sh`
- Add the containers, images, networks and volumes that should be ignored in the corresponding variable
  - E.g. `IGNORED_NETWORKS=("mydocker_network1" "mydocker_network2")`
- Execute it: `./docker_cleanup.sh`
- Deletes all containers, images, networks and volumes
- INFO: Ignores the default docker networks "bridge", "host" and "none" (Variable: `IGNORED_DOCKER_NETWORKS`)
