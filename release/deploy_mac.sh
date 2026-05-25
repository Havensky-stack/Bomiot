#!/usr/bin/env bash
# ============================================================
#  Awesome WMS — macOS 一键部署脚本
#
#  用法: bash deploy_mac.sh
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
# 1. 检测 Docker
# ------------------------------------------------------------------
check_docker() {
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        echo -e "${GREEN}[正常]${NC} Docker Desktop 已安装并运行中"
        return 0
    fi

    if [ -d "/Applications/Docker.app" ] || command -v docker &>/dev/null; then
        echo -e "${YELLOW}[提示]${NC} Docker Desktop 已安装但未启动。"
        echo "  请从应用程序文件夹启动 Docker Desktop，然后重新运行此脚本。"
    else
        echo -e "${YELLOW}[提示]${NC} Docker Desktop 未安装。"
        echo ""
        if [ "$(uname -m)" = "arm64" ]; then
            DOCKER_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
        else
            DOCKER_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
        fi
        echo "  下载地址: $DOCKER_URL"
        echo ""
        read -r -p "  是否打开浏览器下载？[Y/n]: " OPEN_BROWSER
        if [[ ! "$OPEN_BROWSER" =~ ^[Nn] ]]; then
            open "$DOCKER_URL"
        fi
        echo ""
        echo "  安装完成后重新运行此脚本即可。"
    fi
    exit 1
}

# ------------------------------------------------------------------
# 2. 选择镜像源
# ------------------------------------------------------------------
choose_cn() {
    echo -e "${YELLOW}是否在中国大陆使用国内镜像源？${NC}"
    echo "  [Y] 是，使用国内镜像（阿里云）"
    echo "  [N] 否，使用国际镜像（Docker Hub）"
    read -r -p "请选择 [Y]: " CN_CHOICE
    if [[ "$CN_CHOICE" =~ ^[Nn] ]]; then
        echo -e "${GREEN}[OK]${NC} 使用国际镜像源"
        USE_CN=false
    else
        echo -e "${GREEN}[OK]${NC} 使用国内镜像源（阿里云）"
        USE_CN=true
    fi
}

# ------------------------------------------------------------------
# 3. 克隆项目并部署
# ------------------------------------------------------------------
deploy() {
    if [ -d "$PROJECT_DIR" ]; then
        echo -e "${YELLOW}项目目录 $PROJECT_DIR 已存在。${NC}"
        echo "  [1] 更新 (git pull)"
        echo "  [2] 删除并重新克隆"
        echo "  [3] 跳过克隆，直接启动"
        read -r -p "请选择 [1]: " CHOICE
        case "${CHOICE:-1}" in
            2) rm -rf "$PROJECT_DIR"
               git clone --depth 1 "$REPO_URL" "$PROJECT_DIR" ;;
            3) ;;
            *) cd "$PROJECT_DIR" && git pull ;;
        esac
    else
        echo -e "${CYAN}正在克隆项目 ...${NC}"
        git clone --depth 1 "$REPO_URL" "$PROJECT_DIR"
    fi

    cd "$PROJECT_DIR"

    if [ "$USE_CN" = true ]; then
        COMPOSE_FILE="deploy/docker-compose.cn.yml"
    else
        COMPOSE_FILE="deploy/docker-compose.yml"
    fi

    echo ""
    echo -e "${CYAN}正在启动服务（配置文件: $COMPOSE_FILE）...${NC}"
    docker compose -f "$COMPOSE_FILE" up -d --build

    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  部署完成！${NC}"
    echo -e "  访问地址:  ${CYAN}http://localhost:8000${NC}"
    echo -e "  管理员账号: ${CYAN}admin${NC} / ${CYAN}admin123${NC}"
    echo ""
    echo -e "  查看日志:   docker compose -f $COMPOSE_FILE logs -f"
    echo -e "  停止服务:   docker compose -f $COMPOSE_FILE down"
    echo -e "${GREEN}============================================${NC}"
}

# ------------------------------------------------------------------
# 主流程
# ------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Awesome WMS — macOS 一键部署${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

check_docker
choose_cn
deploy
