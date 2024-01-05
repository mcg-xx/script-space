#!/bin/bash
###### SCRIPT START ######
#################################
# GENERAL OUTPUT #
echo 
echo "#############################################"
echo "IMPORTANT: The script stops all containers!!!"
echo "Add the IDs (container, image, network) or names (volume) to the corrosponding IGNORED_ variable"
echo
echo "Usage: $0 alldata | onlycontainers | onlynetworks | onlyimages | onlyvolumes"
echo "Parameters can be combined, e.g.: $0 onlynetworks onlyimages"
echo "#############################################"
echo 
echo "To continue type in [yY]. To abort type in [nN]."
echo

# USER INPUT #
while true; do
    read userInput
    case $userInput in
        [Yy])
            echo
            echo "Continue..."
            sleep 1
            echo
            break
            ;;
        [Nn])
            echo
            echo "Cancel script."
            echo
            exit 0
            ;;
        *)
            echo "Unknown input. Please type in 'y' or 'Y' or 'n' or 'N'."
            ;;
    esac
done

# COUNT OF PARAMETERS #
# INFO: -lt 1 = 0 => At least one should be given
# INFO: -gt 3 = More than three is unecessary
if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 alldata | onlycontainers | onlynetworks | onlyimages | onlyvolumes"
    echo "Parameters can be combined, e.g.: $0 onlynetwork onlyimages"
    exit 1
fi

# VALID PARAMETERS #
valid_params="alldata | onlycontainers | onlynetworks | onlyimages | onlyvolumes"
for param in "$@"; do
    if [[ ! " $valid_params " =~ " $param " ]]; then
        echo "Error: Invalid parameter '$param'. Valid parameters are: $valid_params"
        exit 1
    fi
done

###### VARIABLES ###### 
#################################
IGNORED_CONTAINERS_ID=()
IGNORED_IMAGES_ID=()
IGNORED_DOCKER_NETWORKS_NAMES=("bridge" "host" "none")
IGNORED_NETWORKS_ID=()
IGNORED_VOLUMES_NAMES=()

###### STOP ALL CONTAINERS ######
#################################
# INFO: Check if containers running #
if [ "$(docker ps -q)" ]; then
    # stop the running container
    docker stop $(docker ps -q)

    # Wait, to ensure, that container really stopped
    sleep 2
fi

###### FUNCTIONS ######
#################################
# CONTAINERS #
# INFO: Check and delete the not ignored container ids, "IGNORED_CONTAINERS_ID=()" means all
func_only_containers() {

    containers=$(docker ps -aq)

    if [ -z "$containers" ]; then
        echo "Container has no data."
    fi
    
    for container in $containers; do
        # INFO: Check if the container id is part of the IGNORED-CONTAINERS_ID list
        if [[ " ${IGNORED_CONTAINERS_ID[@]} " =~ " $container " ]]; then
            echo "Ignoring container: $container"
        else
            echo "Deleting container: $container"
            docker rm -f "$container"
        fi
    done
    
    echo
    echo "#######################"
    echo "CONTAINER(S) FINISHED!"
    echo "#######################"
    echo
}

# IMAGES #
# INFO: Check and delete the not ignored image ids, "IGNORED_IMAGES_ID=()" means all
func_only_images() {

    images=$(docker images --format '{{.ID}}')

    if [ -z "$images" ]; then
        echo "Image has no data."
    fi

    for image in $images; do
        # INFO: Check if the image id is part of the IGNORED_IMAGES_ID list.
        if [[ " ${IGNORED_IMAGES_ID[@]} " =~ " $image " ]]; then
            echo "Ignoring image: $image"
        else
            echo "Deleting image: $image"
            docker rmi -f "$image"
        fi
    done

    echo
    echo "#######################"
    echo "IMAGE(S) FINISHED!"
    echo "#######################"
    echo
}

# NETWORKS #
# INFO: Check and delete the not ignored network ids, "IGNORED_NETWORKS_ID=()" means all
func_only_networks() {

    networks=$(docker network ls --format '{{.ID}} {{.Name}}')
    networks_docker=false
    networks_docker_counter=0

    while read -r network_id network_name; do
        # INFO: Check if the network id is part of the IGNORED_NETWORKS_ID list.
        if [[ " ${IGNORED_NETWORKS_ID[@]} " =~ " $network_id " ]]; then
            echo "Ignoring network: $network_name "
        elif [[ " ${IGNORED_DOCKER_NETWORKS_NAMES[@]} " =~ " $network_name " ]]; then
            ((networks_docker_counter++))
            if [ $networks_docker_counter -eq 3 ]; then
                networks_docker=true
            fi
        else
            echo "Deleting network: $network_name ($network_id)"
            docker network rm "$network_id"
        fi
    done <<< "$networks"
    
    if [ $networks_docker = true ] && [ "${#IGNORED_NETWORKS_ID[@]}" -eq 0 ]; then
        echo "Networks has no data."
    fi
    
    echo
    echo "#######################"
    echo "NETWORK(S) FINISHED!"
    echo "#######################"
    echo
}

# VOLUMES #
# INFO: Check and delete the not ignored volumes names ,"IGNORED_VOLUMES_NAMES=()" means all
func_only_volumes() {

    volumes=$(docker volume ls --format '{{.Name}}')

    if [ -z "$volumes" ]; then
        echo "Volumes has no data."
    fi

    for volume in $volumes; do
        # INFO: Check if the volume names is part of the IGNORED_VOLUMES_NAMES list.
        if [[ " ${IGNORED_VOLUMES_NAMES[@]} " =~ " $volume " ]]; then
            echo "Ignoring volume: $volume"
        else
            echo "Deleting volume: $volume"
            docker volume rm "$volume"
        fi
    done

    echo
    echo "#######################"
    echo "VOLUME(S) FINISHED!"
    echo "#######################"
    echo
}

###### EXECUTION ######
#################################
# INFO: Go through every parameter
for param in "$@"; do
    if [ "$param" == "alldata" ]; then
        func_only_containers
        func_only_images
        func_only_networks
        func_only_volumes
    else
        case "$param" in
            onlycontainers)
                func_only_containers
                ;;
            onlyimages)
                func_only_images
                ;;
            onlynetworks)
                func_only_networks
                ;;
            onlyvolumes)
                func_only_volumes
                ;;
        esac
    fi
done
