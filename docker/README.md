# List of files

## docker_cleanup.sh
- Make it executeable `chmod +x docker_cleanup.sh`
- Execute it: `./docker_cleanup.sh`
- Deletes all images, volumes, networks and containers
- INFO: Ignores the default docker networks "bridge", "host" and "none" (Variable: IGNORED_DOCKER_NETWORKS)
