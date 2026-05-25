#!/usr/bin/env bash
# ============================================================
#  Awesome WMS — Linux 一键卸载脚本
#
#  用法: bash uninstall_linux.sh
# ============================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="$HOME/bomiot-wms"

echo ""
echo -e "${RED}============================================${NC}"
echo -e "${RED}  Awesome WMS — Linux 一键卸载${NC}"
echo -e "${RED}============================================${NC}"
echo ""

# ------------------------------------------------------------------
# 1. 停止并删除 Docker 容器
# ------------------------------------------------------------------
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"

    for COMPOSE_FILE in "deploy/docker-compose.cn.yml" "deploy/docker-compose.yml"; do
        if [ -f "$COMPOSE_FILE" ]; then
            echo -e "${CYAN}正在停止 Docker 容器 ...${NC}"
            docker compose -f "$COMPOSE_FILE" down -v 2>/dev/null || true
            break
        fi
    done

    echo ""

    # ------------------------------------------------------------------
    # 2. 删除项目文件
    # ------------------------------------------------------------------
    echo -e "${YELLOW}即将删除项目目录: $PROJECT_DIR${NC}"
    read -r -p "确认删除？[Y/n]: " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Nn] ]]; then
        rm -rf "$PROJECT_DIR"
        echo -e "${GREEN}[完成]${NC} 项目文件已删除"
    else
        echo "已跳过删除项目文件"
    fi
else
    echo -e "${YELLOW}[提示]${NC} 项目目录不存在: $PROJECT_DIR"
fi

echo ""

# ------------------------------------------------------------------
# 3. 询问是否卸载 Docker
# ------------------------------------------------------------------
echo -e "${YELLOW}是否卸载 Docker？${NC}"
echo "  此操作会删除 Docker Engine 及所有镜像、容器和数据卷。"
read -r -p "卸载 Docker？[y/N]: " REMOVE_DOCKER
if [[ "$REMOVE_DOCKER" =~ ^[Yy] ]]; then
    echo ""
    echo -e "${CYAN}正在卸载 Docker ...${NC}"

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
                sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker /etc/apt/keyrings/docker.asc /etc/apt/sources.list.d/docker.list
                ;;
            centos|rhel|fedora)
                sudo yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
                sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker
                ;;
            arch|manjaro)
                sudo pacman -Rns --noconfirm docker docker-compose docker-buildx 2>/dev/null || true
                sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker
                ;;
            *)
                echo -e "${YELLOW}请手动卸载 Docker。${NC}"
                ;;
        esac
    fi

    echo -e "${GREEN}[完成]${NC} Docker 已卸载"
else
    echo "已跳过卸载 Docker"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  卸载完成${NC}"
echo -e "${GREEN}============================================${NC}"
