#!/bin/bash

PROJECT_NAME="Crypto Analyzer"

CURR_DIRECTORY="$PWD"
COMPOSE_DIRECTORY="docker"
LOCAL_COMPOSE="docker-compose.local.yaml"
REMOTE_COMPOSE="docker-compose.remote.yaml"

BASE_DOCKER_COMPOSE_CONFIG="-f $CURR_DIRECTORY/$COMPOSE_DIRECTORY/$LOCAL_COMPOSE"

is_local=true

# Define system distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRIBUTION=$ID
else
    echo "[ERROR] Failed to define Linux distributive"
    exit 1
fi

# Loading environments from .env file
function load_env() {
    echo "[INFO] Loading environment variables..."

    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | xargs) > /dev/null 2>&1

        if [ -z "$IP_ADDRES" ] || [ -z "$USERNAME" ]; then
            echo "[ERROR] Parameters 'IP_ADDRES' and/or 'USERNAME' not found in '.env'"
            exit 1
        fi

    else
        echo "[ERROR] File '.env' not found"
        exit 1
    fi

    echo "[INFO] Variables successfully loaded!"
}

# Deploying project in local machine
function deploy_local() {
    echo "[INFO] Deploying '$PROJECT_NAME' in local machine"
    docker-compose $BASE_DOCKER_COMPOSE_CONFIG up -d
}

# Deploying project in remote machine by .env
function deploy_remote() {
    echo "[INFO] Deploying '$PROJECT_NAME' in remote machine"
    load_env
    ssh_docker_deploy
}

# Deploying docker by ssh
function ssh_docker_deploy() {
    echo "[INFO] Trying to connect to '$USERNAME@$IP_ADDRES'..."



#   Подкачать все файлы на сервер, проверить что они там есть
#     запустить команду по разворачиванию проекта
    ssh "$USERNAME@$IP_ADDRES" << 'EOF'
        echo "На удалённом сервере: $(hostname)"

EOF

    if [ $? -eq 0 ]; then
        echo "[INFO] Project '$PROJECT_NAME' successfully deployed on '$USERNAME@$IP_ADDRES'!"
    else
        echo "[INFO] Failed to deploy '$PROJECT_NAME' by ssh"
        exit 1
    fi
}

# Installing docker
function install_docker() {
    echo "[INFO] Trying to install docker on $DISTRIBUTION"

    case $DISTRIBUTION in
        ubuntu | debian)
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl software-properties-common

            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | apt-key add -
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable"

            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
            ;;
        centos | rhel | fedora)
            yum install -y yum-utils device-mapper-persistent-data lvm2
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            yum install -y docker-ce docker-ce-cli containerd.io
            ;;
        *)
          echo "[ERROR] Sorry! Distribution $DISTRIBUTION is not supported"
          exit 1
          ;;
    esac

    systemctl start docker
    systemclt enable docker

    docker --version

    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to install docker on $DISTRIBUTION"
        exit 1
    else
        echo "[OK] Docker successfully installed/updated on $DISTRIBUTION"
    fi
}

# Installing docker-compose
function install_docker_compose() {
    echo "[INFO] Trying to install docker-compose"

    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    chmod +x /usr/local/bin/docker-compose

    docker-compose --version

    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to install docker-compose"
        exit 1
    else
        echo "[OK] Docker-compose successfully installed/updated on $DISTRIBUTION"
    fi
}

# Pulling dependencies necessary for project
function pull_dependencies() {
    install_docker
    install_docker_compose

    usermod -aG docker $SUDO_USER
}

function stop() {
    echo "[INFO] Trying to stop '$PROJECT_NAME'"
    docker-compose $BASE_DOCKER_COMPOSE_CONFIG stop

    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to stop project '$PROJECT_NAME'"
        exit 1
    else
        echo "[OK] '$PROJECT_NAME' project is stopped"
    fi
}

function clean() {
    echo "[INFO] Trying to fully clean '$PROJECT_NAME'"

    docker-compose $BASE_DOCKER_COMPOSE_CONFIG down -v --remove-orphans

    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to fully clean project '$PROJECT_NAME'"
        exit 1
    else
        echo "[OK] '$PROJECT_NAME' project is fully cleaned"
    fi
}

case "$1" in
    --clean)
        clean
        echo "[OK] Project successfully cleaned!"
        ;;
    --pull-dependensies | --pull | -p)
        if [ "$EUID" -ne 0 ]; then
            echo "[ERROR] Failed to pull dependencies, please run with root (sudo) privileges"
            exit 1
        fi
        pull_dependencies
        echo "[OK] All dependencies successfully installed!"
        ;;
    --deploy-local | --local | -l)
        deploy_local
        echo "[OK] Project successfully deployed local!"
        ;;
    --deploy-remote | --remote | -r)
        deploy_remote
        is_local=falsew
        echo "[OK] Project successfully deployed remote!"
        ;;
    --stop)
        stop
        echo "[OK] Project successfully stopped!"
        ;;
#   Добавить следующие функциональности:
#       обновление библиотек или подкачка докера (локально и удаленно)
#       остановка контейнеров (локально и удаленно)
#       удаление контейнеров (локально и удаленно)
#       полная очистка от проекта (локально и удаленно)
    --help | -h)
#       Добавить вывод всех доступных команд для пользователя
        exit 1
        ;;
    *)
      exit 1
      ;;
esac