#!/bin/bash

function remove_containers() {
    local file="$1"
    if [[ ! -f $file ]]; then
        echo "Error: File $file not found."
        exit 1
    fi

    while IFS= read -r container_id; do
        if docker ps -a | grep -q "$container_id"; then
            echo "Stopping and removing container: $container_id"
            docker stop "$container_id" && docker rm "$container_id"
        else
            echo "Container ID $container_id not found."
        fi
    done < "$file"
}

function show_older_than() {
    local months="$1"
    local date_threshold=$(date -d "-$months months" '+%Y-%m-%d')

    docker ps -a --format '{{.CreatedAt}}\t{{.ID}}\t{{.Names}}' | while read line; do
        container_date=$(echo $line | awk '{print $1}')
        if [[ "$container_date" < "$date_threshold" ]]; then
            echo "$line"
        fi
    done
}

if [[ "$1" == "--remove-containers" && -n "$2" ]]; then
    remove_containers "$2"
elif [[ "$1" == "--show-older-than" && -n "$2" ]]; then
    show_older_than "$2"
else
    echo "Usage:"
    echo "  bash docker_utils --remove-containers input.txt"
    echo "  bash docker_utils --show-older-than 6"
fi

