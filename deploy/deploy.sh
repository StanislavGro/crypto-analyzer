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
        if [ -z "$IP_ADDRESS" ] || [ -z "$USERNAME" ]; then
            log "[ERROR] Parameters 'IP_ADDRESS' and/or 'USERNAME' not found in '.env'"
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
        ubuntu|debian)
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl software-properties-common
            curl -fsSL https://download.docker.com/linux/$DISTRIBUTION/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRIBUTION $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        centos|rhel|fedora)
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
    systemctl enable docker
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
#    install_docker_compose
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

# Checking SHH connection
function check_ssh() {
    ssh -o ConnectTimeout=10 "$USERNAME@$IP_ADDRESS" "echo 'SSH connection successful'" || {
        log "[ERROR] Failed to connect to '$USERNAME@$IP_ADDRESS' by SSH"
        exit 1;
    }
}

# Uploading files via ssh and scp
upload_files() {
    log "[INFO] Uploading files to '$USERNAME@$IP_ADDRESS'"
    ssh "$USERNAME@$IP_ADDRESS" "mkdir -p $PROJECT_NAME_DIR/$COMPOSE_DIRECTORY" || {
        log "[ERROR] Failed to create directory '$PROJECT_NAME_DIR/$COMPOSE_DIRECTORY'"
        exit 1
    }
    scp "$CURR_DIRECTORY/$COMPOSE_DIRECTORY/$LOCAL_COMPOSE" "$USERNAME@$IP_ADDRESS:$PROJECT_NAME_DIR/$COMPOSE_DIRECTORY/$LOCAL_COMPOSE" || {
        log "[ERROR] Failed to upload '$LOCAL_COMPOSE'"
        exit 1
    }
    scp "$CURR_DIRECTORY/$COMPOSE_DIRECTORY/.env" "$USERNAME@$IP_ADDRESS:$PROJECT_NAME_DIR/$COMPOSE_DIRECTORY/.env" || {
        log "[ERROR] Failed to upload .env"
        exit 1
    }
    log "[INFO] Files uploaded successfully"
}

# Deploying project in remote machine by .env
function deploy_remote() {
    echo "[INFO] Deploying '$PROJECT_NAME' on '$USERNAME@$IP_ADDRESS'"
    load_env
    check_ssh
    upload_files
    ssh "$USERNAME@$IP_ADDRESS" << EOF
        cd $PROJECT_NAME_DIR/$COMPOSE_DIRECTORY
        docker-compose -f $LOCAL_COMPOSE up -d || exit 1
        docker-compose -f $LOCAL_COMPOSE ps
EOF
    [ $? -eq 0 ] || { log "[ERROR] Failed to deploy project '$PROJECT_NAME' on '$USERNAME@$IP_ADDRESS'"; exit 1; }
    echo "[OK] '$PROJECT_NAME' successfully deployed on '$USERNAME@$IP_ADDRESS'!"
}

# Cleaning project on remote server
function remote_clean() {
    log "[INFO] Cleaning project '$PROJECT_NAME' on '$USERNAME@$IP_ADDRESS'"
    load_env
    check_ssh
    upload_files
    ssh "$USERNAME@$IP_ADDRESS" << EOF
        cd $PROJECT_NAME_DIR/$COMPOSE_DIRECTORY
        docker-compose -f $LOCAL_COMPOSE down -v --remove-orphans || exit 1
EOF
    [ $? -eq 0 ] || { log "[ERROR] Failed to clean '$PROJECT_NAME' on '$USERNAME@$IP_ADDRESS'"; exit 1;}
    log "[OK] '$PROJECT_NAME' successfully cleaned on $USERNAME@$IP_ADDRESS"
}

# Stopping project on remote server
function remote_stop() {
    log "[INFO] Stopping project '$PROJECT_NAME' on '$USERNAME@$IP_ADDRESS'"
    load_env
    check_ssh
    upload_files
    ssh "$USERNAME@$IP_ADDRESS" << EOF
        cd $PROJECT_NAME_DIR/$COMPOSE_DIRECTORY
        docker-compose -f $LOCAL_COMPOSE stop || exit 1
EOF
    [ $? -eq 0 ] || { log "[ERROR] Failed to stop '$PROJECT_NAME' on '$USERNAME@$IP_ADDRESS'"; exit 1; }
    log "[OK] Project '$PROJECT_NAME' stopped on $USERNAME@$IP_ADDRESS"
}

# Remote installing docker
function remote_install_docker() {
log "[INFO] Checking and installing Docker on '$USERNAME@$IP_ADDRESS'"
    ssh "$USERNAME@$IP_ADDRESS" << EOF >> "$LOG_FILE" 2>&1
        if ! command -v docker >/dev/null 2>&1; then
            echo "[WARNING] Docker not found, installing"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO=\$ID
            else
                echo "[ERROR] Failed to determine Linux distribution"
                exit 1
            fi
            case \$DISTRO in
                ubuntu|debian)
                    sudo apt-get update
                    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                    curl -fsSL https://download.docker.com/linux/\$DISTRO/gpg | sudo apt-key add -
                    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/\$DISTRO \$(lsb_release -cs) stable"
                    sudo apt-get update
                    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                    ;;
                centos|rhel|fedora)
                    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
                    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                    sudo yum install -y docker-ce docker-ce-cli containerd.io
                    ;;
                *)
                    echo "[ERROR] Distribution \$DISTRO is not supported"
                    exit 1
                    ;;
            esac
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker \$USER
        else
            echo "[INFO] Docker already installed"
        fi
        docker --version || exit 1
EOF
    [ $? -eq 0 ] || { log "[ERROR] Failed to install Docker remotely"; exit 1; }
    log "[OK] Docker installed on '$USERNAME@$IP_ADDRESS'"
}

# Remote installing docker compose
function remote_install_docker_compose() {
    log "[INFO] Checking and installing Docker Compose on '$USERNAME@$IP_ADDRESS'"
    ssh "$USERNAME@$IP_ADDRESS" << EOF >> "$LOG_FILE" 2>&1
        if ! command -v docker-compose >/dev/null 2>&1; then
            echo "[WARNING] Docker Compose not found, installing"
            COMPOSE_VERSION=\$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
            sudo curl -L "https://github.com/docker/compose/releases/download/\${COMPOSE_VERSION}/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        else
            echo "[INFO] Docker Compose already installed"
        fi
        docker-compose --version || exit 1
EOF
    [ $? -eq 0 ] || { log "[ERROR] Failed to install Docker Compose remotely"; exit 1; }
    log "[OK] Docker Compose installed on '$USERNAME@$IP_ADDRESS'"
}

# Remote pull libraries and dependencies
function remote_pull() {
    log "[INFO] Pulling updates on '$USERNAME@$IP_ADDRESS'"
    load_env
    check_ssh
    remote_install_docker
    remote_install_docker_compose
    ssh "$USERNAME@$IP_ADDRESS" << EOF >> "$LOG_FILE" 2>&1
      cd $PROJECT_NAME_DIR/$COMPOSE_DIRECTORY
      docker-compose -f $LOCAL_COMPOSE pull || exit 1
      docker-compose -f $LOCAL_COMPOSE up -d --force-recreate || exit 1
      docker-compose -f $LOCAL_COMPOSE ps
EOF
    [ $? -eq 0 ] || { log "[ERROR] Failed to pull updates on '$USERNAME@$IP_ADDRESS'"; exit 1; }
    log "[OK] Updates pulled and applied on '$USERNAME@$IP_ADDRESS'"
}

# Stopping project
function stop() {
    log "[INFO] Stopping '$PROJECT_NAME' locally"
    validate_compose_file
    docker-compose $BASE_DOCKER_COMPOSE_CONFIG stop || { log "[ERROR] Failed to stop locally"; exit 1; }
    log "[OK] Project '$PROJECT_NAME' stopped locally"
}

# Cleaning project
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
    log "   --remote-pull           Pull and update project dependencies on remote server"
    log "   -r, --deploy-remote     Deploy project on remote server"
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
            if [ $# -eq 0 ]; then
                exit 0
            fi
            ;;
        --stop)
            if [ "$is_local" = true ]; then
                stop
            else
                remote_stop
            fi
            shift
            if [ $# -eq 0 ]; then
                exit 0
            fi
            ;;
        --clean)
            if [ "$is_local" = true ]; then
                clean
            else
                remote_clean
            fi
            shift
            if [ $# -eq 0 ]; then
                exit 0
            fi
            ;;
        -l | --deploy-local)
            deploy_local
            is_local=true
            shift
            if [ $# -eq 0 ]; then
                exit 0
            fi
            ;;
        --remote-pull)
            remote_pull
            is_local=false
            shift
            if [ $# -eq 0 ]; then
                exit 0
            fi
            ;;
        -r | --deploy-remote)
            deploy_remote
            is_local=false
            shift
            if [ $# -eq 0 ]; then
                exit 0
            fi
            ;;
        --remote-stop)
            remote_stop
            is_local=false
            shift
            if [ $# -eq 0 ]; then
                exit 0
            fi
            ;;
        --remote-clean)
            remote_clean
            is_local=false
            shift
            if [ $# -eq 0 ]; then
                exit 0
            fi
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

# Without args returns error
if [ $# -eq 0 ]; then
    show_help
fi
