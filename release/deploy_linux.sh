#!/usr/bin/env bash
# ============================================================
#  Awesome WMS — Linux 一键部署脚本
#
#  用法: bash deploy_linux.sh
#
#  脚本会自动完成以下操作：
#  1. 检测并安装 Docker
#  2. 检测是否在中国大陆 → 自动切换国内镜像源
#  3. 克隆项目并启动部署
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
# 1. 检测 Linux 发行版
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
# 2. 检测并安装 Docker
# ------------------------------------------------------------------
check_docker() {
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        echo -e "${GREEN}[正常]${NC} Docker 已安装并运行中"
        return 0
    fi

    echo -e "${YELLOW}[提示]${NC} Docker 未安装或未启动。"
    echo ""
    echo "  是否现在安装 Docker？[Y/n]"
    read -r ANSWER
    if [[ "$ANSWER" =~ ^[Nn] ]]; then
        echo "请手动安装 Docker 后重新运行此脚本。"
        exit 1
    fi

    install_docker
}

install_docker() {
    detect_distro
    echo -e "${CYAN}正在为 $DISTRO 安装 Docker ...${NC}"

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
            echo -e "${RED}无法为 '$DISTRO' 自动安装 Docker。${NC}"
            echo "请手动安装: https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac

    sudo usermod -aG docker "$USER" 2>/dev/null || true
    echo -e "${GREEN}[完成]${NC} Docker 安装完成。如提示权限不足，请注销后重新登录。"

    if ! docker info &>/dev/null 2>&1; then
        sudo systemctl start docker 2>/dev/null || true
    fi
}

# ------------------------------------------------------------------
# 3. 选择镜像源
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
# 4. 克隆项目并部署
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
echo -e "${GREEN}  Awesome WMS — Linux 一键部署${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

check_docker
choose_cn
deploy
