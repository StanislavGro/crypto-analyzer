#!/bin/bash

PROJECT_NAME="Crypto Analyzer"
LOCAL_COMPOSE="docker-compose.local.yaml"
REMOTE_COMPOSE="docker-compose.remote.yaml"
LOCAL_DEPLOY=true

cd docker

function start-local() {
    echo "Starting '$PROJECT_NAME' in local machine"
    docker-compose up
}

function clean-containers() {
    docker-compose down
}

function stop-containers() {
    docker-compose stop
}

case "$1" in
    --start-local)
        start-local
        ;;
    --clean-containers)
        clean-containers
        ;;
    --stop-containers)
        stop-containers
        ;;
    --remote|-r)
        LOCAL_DEPLOY=false
        echo "OK"
        ;;
esac