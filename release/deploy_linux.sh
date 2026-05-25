#!/usr/bin/env bash
# ============================================================
#  Bomiot WMS — Linux One-Click Deploy
#
#  Usage: bash deploy_linux.sh
#
#  What it does:
#  1. Checks for Docker and installs if missing
#  2. Detects whether you are in China → auto-selects mirrors
#  3. Clones the project and starts docker compose
# ============================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_URL="https://github.com/Havensky-stack/Bomiot.git"
PROJECT_DIR="$HOME/bomiot-wms"

# ------------------------------------------------------------------
# 1. Detect distro
# ------------------------------------------------------------------
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO="unknown"
    fi
}

# ------------------------------------------------------------------
# 2. Check Docker
# ------------------------------------------------------------------
check_docker() {
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} Docker is installed and running"
        return 0
    fi

    echo -e "${YELLOW}[!]${NC} Docker is not installed or not running."
    echo ""
    echo "  Install Docker now? [Y/n]"
    read -r ANSWER
    if [[ "$ANSWER" =~ ^[Nn] ]]; then
        echo "Please install Docker manually and re-run this script."
        exit 1
    fi

    install_docker
}

install_docker() {
    detect_distro
    echo -e "${CYAN}Installing Docker for $DISTRO ...${NC}"

    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/$DISTRO/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DISTRO $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        centos|rhel|fedora)
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/$DISTRO/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo systemctl start docker
            sudo systemctl enable docker
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm docker docker-compose docker-buildx
            sudo systemctl start docker
            sudo systemctl enable docker
            ;;
        *)
            echo -e "${RED}Cannot auto-install Docker for '$DISTRO'.${NC}"
            echo "Please install Docker manually: https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac

    # Add user to docker group
    sudo usermod -aG docker "$USER" 2>/dev/null || true

    echo -e "${GREEN}[OK]${NC} Docker installed. You may need to log out and back in for group changes to take effect."
    echo ""

    # If dockerd is not running, start it
    if ! docker info &>/dev/null 2>&1; then
        sudo systemctl start docker 2>/dev/null || true
    fi
}

# ------------------------------------------------------------------
# 3. Detect if in China
# ------------------------------------------------------------------
detect_cn() {
    echo -e "${CYAN}Detecting network environment ...${NC}"
    # Try Docker Hub — if unreachable, assume China
    if curl -s --connect-timeout 3 https://registry-1.docker.io/v2/ > /dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} Docker Hub reachable → using international mirrors"
        USE_CN=false
    else
        echo -e "${YELLOW}[CN]${NC} Docker Hub unreachable → using China mirrors"
        USE_CN=true
    fi
}

# ------------------------------------------------------------------
# 4. Clone and deploy
# ------------------------------------------------------------------
deploy() {
    if [ -d "$PROJECT_DIR" ]; then
        echo -e "${YELLOW}Project directory $PROJECT_DIR already exists.${NC}"
        echo "  [1] Update (git pull)"
        echo "  [2] Remove and re-clone"
        echo "  [3] Skip clone, just start"
        read -r -p "Choice [1]: " CHOICE
        case "${CHOICE:-1}" in
            2) rm -rf "$PROJECT_DIR"
               git clone --depth 1 "$REPO_URL" "$PROJECT_DIR" ;;
            3) ;;
            *) cd "$PROJECT_DIR" && git pull ;;
        esac
    else
        echo -e "${CYAN}Cloning project ...${NC}"
        git clone --depth 1 "$REPO_URL" "$PROJECT_DIR"
    fi

    cd "$PROJECT_DIR"

    if [ "$USE_CN" = true ]; then
        COMPOSE_FILE="deploy/docker-compose.cn.yml"
    else
        COMPOSE_FILE="deploy/docker-compose.yml"
    fi

    echo ""
    echo -e "${CYAN}Starting services (compose file: $COMPOSE_FILE) ...${NC}"
    docker compose -f "$COMPOSE_FILE" up -d --build

    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  Deploy complete!${NC}"
    echo -e "  URL:  ${CYAN}http://localhost:8000${NC}"
    echo -e "  Admin login: ${CYAN}admin${NC} / ${CYAN}admin123${NC}"
    echo ""
    echo -e "  View logs:   docker compose -f $COMPOSE_FILE logs -f"
    echo -e "  Stop:        docker compose -f $COMPOSE_FILE down"
    echo -e "${GREEN}============================================${NC}"
}

# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Bomiot WMS — Linux One-Click Deploy${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

check_docker
detect_cn
deploy
