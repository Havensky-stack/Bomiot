#!/usr/bin/env bash
# ============================================================
#  Bomiot WMS — macOS One-Click Deploy
#
#  Usage: bash deploy_mac.sh
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
# 1. Check Docker
# ------------------------------------------------------------------
check_docker() {
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} Docker Desktop is running"
        return 0
    fi

    if [ -d "/Applications/Docker.app" ] || command -v docker &>/dev/null; then
        echo -e "${YELLOW}[!]${NC} Docker Desktop is installed but not running."
        echo "  Please start Docker Desktop from Applications, then re-run this script."
    else
        echo -e "${YELLOW}[!]${NC} Docker Desktop is not installed."
        echo ""
        # Detect Apple Silicon vs Intel
        if [ "$(uname -m)" = "arm64" ]; then
            DOCKER_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
        else
            DOCKER_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
        fi
        echo "  Download: $DOCKER_URL"
        echo ""
        read -r -p "  Open download page in browser? [Y/n]: " OPEN_BROWSER
        if [[ ! "$OPEN_BROWSER" =~ ^[Nn] ]]; then
            open "$DOCKER_URL"
        fi
        echo ""
        echo "  After installing Docker Desktop, re-run this script."
    fi
    exit 1
}

# ------------------------------------------------------------------
# 2. Detect if in China
# ------------------------------------------------------------------
detect_cn() {
    echo -e "${CYAN}Detecting network environment ...${NC}"
    if curl -s --connect-timeout 3 https://registry-1.docker.io/v2/ > /dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} Docker Hub reachable → using international mirrors"
        USE_CN=false
    else
        echo -e "${YELLOW}[CN]${NC} Docker Hub unreachable → using China mirrors"
        USE_CN=true
    fi
}

# ------------------------------------------------------------------
# 3. Clone and deploy
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
echo -e "${GREEN}  Bomiot WMS — macOS One-Click Deploy${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

check_docker
detect_cn
deploy
