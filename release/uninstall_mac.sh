#!/usr/bin/env bash
# ============================================================
#  Awesome WMS — macOS 一键卸载脚本
#
#  用法: bash uninstall_mac.sh
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
echo -e "${RED}  Awesome WMS — macOS 一键卸载${NC}"
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
# 3. 询问是否卸载 Docker Desktop
# ------------------------------------------------------------------
echo -e "${YELLOW}是否卸载 Docker Desktop？${NC}"
echo "  此操作需要手动将 Docker.app 从应用程序文件夹移到废纸篓。"
echo "  同时会删除所有 Docker 数据（镜像、容器、数据卷）。"
read -r -p "准备卸载？[y/N]: " REMOVE_DOCKER
if [[ "$REMOVE_DOCKER" =~ ^[Yy] ]]; then
    echo ""
    echo -e "${CYAN}正在清理 Docker 数据 ...${NC}"

    # Remove Docker data
    rm -rf ~/Library/Containers/com.docker.docker 2>/dev/null || true
    rm -rf ~/Library/Application\ Support/Docker\ Desktop 2>/dev/null || true
    rm -rf ~/Library/Group\ Containers/group.com.docker 2>/dev/null || true
    rm -rf ~/Library/Logs/Docker\ Desktop 2>/dev/null || true
    rm -rf ~/Library/Saved\ Application\ State/com.docker.docker.savedState 2>/dev/null || true
    rm -rf ~/Library/Preferences/com.docker.docker.plist 2>/dev/null || true
    rm -rf ~/.docker 2>/dev/null || true

    echo -e "${GREEN}[完成]${NC} Docker 数据已清理"
    echo ""
    echo -e "${YELLOW}请手动将 Docker.app 从"应用程序"文件夹移到废纸篓。${NC}"
else
    echo "已跳过卸载 Docker Desktop"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  卸载完成${NC}"
echo -e "${GREEN}============================================${NC}"
