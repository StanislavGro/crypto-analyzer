#!/bin/bash

set -e

# Name constants
PROJECT_NAME="Crypto Analyzer"
PROJECT_NAME_DIR="crypto-analyzer"

# File and dir names
COMPOSE_DIRECTORY="docker"
LOCAL_COMPOSE="docker-compose.local.yaml"
CURR_DIRECTORY="$PWD"
LOG_FILE="$CURR_DIRECTORY/deploy.log"
BASE_DOCKER_COMPOSE_CONFIG="-f $CURR_DIRECTORY/$COMPOSE_DIRECTORY/$LOCAL_COMPOSE"

is_local=true

# Define system distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRIBUTION=$ID
else
    echo "[ERROR] Failed to define Linux distribution" | tee -a "$LOG_FILE"
    exit 1
fi

# Logging function
function log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Loading environments from .env file
function load_env() {
    log "[INFO] Loading environment variables..."
    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | xargs) > /dev/null 2>&1
        if [ -z "$IP_ADDRES" ] || [ -z "$USERNAME" ]; then
            log "[ERROR] Parameters 'IP_ADDRES' and/or 'USERNAME' not found in '.env'"
            exit 1
        fi
    else
        log "[ERROR] File '.env' not found"
        exit 1
    fi
    log "[INFO] Variables successfully loaded!"
}

# Check is docker-compose file valid
function validate_compose_file() {
    if [ ! -f "$CURR_DIRECTORY/$COMPOSE_DIRECTORY/$LOCAL_COMPOSE" ]; then
      log "[ERROR] File '$LOCAL_COMPOSE' is absent"
      exit 1
    fi
    if ! docker-compose $BASE_DOCKER_COMPOSE_CONFIG config >/dev/null; then
      log "[ERROR] File '$LOCAL_COMPOSE' contains errors"
      exit 1
    fi
}

# Installing docker
function install_docker() {
    log "[INFO] Trying to install docker on $DISTRIBUTION"
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
          log "[ERROR] Sorry! Distribution $DISTRIBUTION is not supported"
          exit 1
          ;;
    esac
    systemctl start docker
    systemclt enable docker
    docker --version || { log "[ERROR] Failed to install Docker"; exit 1; }
    log "[OK] Docker successfully installed on $DISTRIBUTION"
}

# Installing docker-compose
function install_docker_compose() {
    log "[INFO] Trying to install Docker Compose"
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    docker-compose --version || { log "[ERROR] Failed to install Docker Compose"; exit 1; }
    log "[OK] Docker Compose successfully installed"
}

# Pulling dependencies necessary for project
function pull_dependencies() {
    if [ "$EUID" -ne 0 ]; then
        log "[ERROR] Failed to pull dependencies, please run with root (sudo) privileges"
        exit 1
    fi
    install_docker
    install_docker_compose
    usermod -aG docker $SUDO_USER || log "[WARNING] Failed to add user to docker group"
    log "[OK] All dependencies successfully installed!"
}

# Deploying project in local machine
function deploy_local() {
    log "[INFO] Deploying '$PROJECT_NAME' locally"
    validate_compose_file
    docker-compose $BASE_DOCKER_COMPOSE_CONFIG up -d || { log "[ERROR] Failed to deploy locally"; exit 1; }
    log "[OK] Project successfully deployed locally!"
}

# Deploying docker by ssh
function ssh_docker_deploy() {
    echo "[INFO] Trying to connect to '$USERNAME@$IP_ADDRES'..."

    ssh "$USERNAME@$IP_ADDRES" << 'EOF'
    mkdir -p crypto-analyzer
EOF

    if [ $? -eq 0 ]; then
        echo "[INFO] Successfully created 'crypto-analyzer' directory on '$IP_ADDRES'!"
    else
        echo "[ERROR] Failed to create 'crypto-analyzer' on '$IP_ADDRES'"
        exit 1
    fi

    scp "$CURR_DIRECTORY/$COMPOSE_DIRECTORY/$LOCAL_COMPOSE" "$USERNAME@$IP_ADDRES:$PROJECT_NAME_DIR/$LOCAL_COMPOSE"

    if [ $? -eq 0 ]; then
        echo "[INFO] File '$LOCAL_COMPOSE' successfully uploaded on '$IP_ADDRES'!"
    else
        echo "[ERROR] Failed to upload '$LOCAL_COMPOSE' on server by scp"
        exit 1
    fi

    scp "$CURR_DIRECTORY/$COMPOSE_DIRECTORY/.env" "$USERNAME@$IP_ADDRES:$PROJECT_NAME_DIR/.env"

    if [ $? -eq 0 ]; then
        echo "[INFO] File '.env' successfully uploaded on '$IP_ADDRES'!"
    else
        echo "[ERROR] Failed to upload '.env' on server by scp"
        exit 1
    fi

    ssh "$USERNAME@$IP_ADDRES" << 'EOF'
        cd crypto-analyzer
        docker-compose -f docker-compose.local.yaml up -d
EOF

    if [ $? -eq 0 ]; then
        echo "[INFO] Project '$PROJECT_NAME' successfully deployed on '$IP_ADDRES'!"
    else
        echo "[ERROR] Failed to deploy '$PROJECT_NAME' by ssh"
        exit 1
    fi
}

# Deploying project in remote machine by .env
function deploy_remote() {
    echo "[INFO] Deploying '$PROJECT_NAME' in remote machine"
    load_env
    ssh_docker_deploy
    echo "[OK] Project successfully deployed remote!"
}


function stop() {
    log "[INFO] Stopping '$PROJECT_NAME' locally"
    validate_compose_file
    docker-compose $BASE_DOCKER_COMPOSE_CONFIG stop || { log "[ERROR] Failed to stop locally"; exit 1; }
    log "[OK] Project '$PROJECT_NAME' stopped locally"
}

function clean() {
    log "[INFO] Cleaning '$PROJECT_NAME' locally"
    validate_compose_file
    docker-compose $BASE_DOCKER_COMPOSE_CONFIG down -v --remove-orphans || { log "[ERROR] Failed to clean locally"; exit 1; }
    log "[OK] Project '$PROJECT_NAME' clean locally"
}

# Showing main script opportunities
function show_help() {
    log "Usage script '$0'\n"
    log "Options:"
    log "   -p, --pull              Pull and update project dependencies on locally server"
    log "   --stop                  Stop project locally"
    log "   --clean                 Clean project locally (remove containers, volumes, orphans)"
    log "   -l, --deploy-local      Deploy project locally"
    log "   -r, --deploy-remote     Deploy project on remote server"
    log "   --remote-pull           Pull and update project dependencies on remote server"
    log "   --remote-stop           Stop project on remote server"
    log "   --remote-clean          Clean project on remote server"
    log "   -h, --help              Show help message"
    exit 1
}

# Creating or cleaning log file
> "$LOG_FILE"

while [ $# -gt 0 ];  do
    case "$1" in
        -p | --pull)
            pull_dependencies
            shift
            ;;
        --stop)
            if [ "$is_local" = true ]; then
                stop
            else
                remote_stop
            fi
            shift
            ;;
        --clean)
            if [ "$is_local" = true ]; then
                clean
            else
                remote_clean
            fi
            shift
            ;;
        -l | --deploy-local)
            deploy_local
            is_local=true
            shift
            ;;
        -r | --deploy-remote)
            deploy_remote
            is_local=false
            shift
            ;;
        --remote-pull)
            is_local=false
            remote_pull
            shift
            ;;
        --remote-stop)
            is_local=false
            remote_stop
            shift
            ;;
        --remote-clean)
            is_local=false
            remote_clean
            shift
            ;;
        -h | --help)
            show_help
            ;;
        *)
          log "[ERROR] Unknown parameter '$1'"
          show_help
          ;;
    esac
done

if [ $# -eq 0 ]; then
    show_help
fi
