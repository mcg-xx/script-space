#!/bin/bash

IGNORED_CONTAINERS=()
IGNORED_NETWORKS=()
IGNORED_DOCKER_NETWORKS=("bridge" "host" "none")
IGNORED_IMAGES=()
IGNORED_VOLUMES=()

# Check if container is running
if [ "$(docker ps -q)" ]; then
    # stop the running container
    docker stop $(docker ps -q)

    # Wait, to ensure, that container really stopped
    sleep 2
fi

#####################
##### CONTAINER #####
#####################
# Check and delete the not ignored containers, "=()" means all
containers=$(docker ps -a --format '{{.Names}}')

if [ -z "$containers" ]; then
    echo "No container is running."
fi

for container in $containers; do
    # Check, if the container is in IGNORED_CONTAINERS list
    if [[ " ${IGNORED_CONTAINER[@]} " =~ " $container " ]]; then
        echo "Ignoring container: $container"
    else
        echo "Deleting container: $container"
        docker rm -f "$container"
    fi
done

#####################
###### NETWORK ######
#####################
# Check and delete the not ignored networks, "=()" means all
networks=$(docker network ls --format '{{.Name}}')
networks_docker=false
for network in $networks; do
    # Check, if the network is in IGNORED_NETWORKS list
    if [[ " ${IGNORED_NETWORKS[@]} " =~ " $network " ]]; then
        echo "Ignoring network: $network"
    elif [[ " ${IGNORED_DOCKER_NETWORKS[@]} " =~ " $network " ]]; then
	if [ "$networks_docker" = false ]; then
	    networks_docker=true
	    echo "Network has no data."
	fi
    else
        echo "Deleting network: $network"
        docker network rm "$network"
    fi
done

#####################
####### IMAGE #######
#####################
# Check and delete the not ignored images, "=()" means all
images=$(docker images --format '{{.Repository}}:{{.Tag}}')

if [ -z "$images" ]; then
    echo "Image has no data."
fi

for image in $images; do
    # Überprüfen, ob das Image in der IGNORED_IMAGES-Liste enthalten ist
    # Check, if the image is in IGNORED_IMAGES list
    if [[ " ${IGNORED_IMAGES[@]} " =~ " $image " ]]; then
        echo "Ignoring image: $image"
    else
        echo "Deleting image: $image"
        docker rmi -f "$image"
    fi
done

#####################
####### VOLUME ######
#####################
# Check and delete the not ignored volumes ,"=()" means all
volumes=$(docker volume ls --format '{{.Name}}')

if [ -z "$volumes" ]; then
    echo "Volumes has no data."
fi

for volume in $volumes; do
    # Check, if the volume is in IGNORED_VOLUMES list
    if [[ " ${IGNORED_VOLUMES[@]} " =~ " $volume " ]]; then
        echo "Ignoring volume: $volume"
    else
        echo "Deleting volume: $volume"
        docker volume rm "$volume"
    fi
done
