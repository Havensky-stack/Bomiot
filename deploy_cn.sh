#!/usr/bin/env bash
# =============================================
# WMS System - China Edition Docker Deploy
# Usage: bash deploy_cn.sh [up|down|logs|restart]
# =============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

COMPOSE_FILE="deploy/docker-compose.cn.yml"

# Check Docker mirror config
check_docker_mirror() {
    if [ -f /etc/docker/daemon.json ]; then
        if grep -q 'registry-mirrors' /etc/docker/daemon.json 2>/dev/null; then
            echo -e "${GREEN}[OK]${NC} Docker registry mirror configured"
            return 0
        fi
    fi
    echo -e "${YELLOW}[提示]${NC} 未检测到 Docker 镜像加速器，拉取镜像可能很慢或失败。"
    echo ""
    echo "  请先配置镜像加速器:"
    echo ""
    echo "  sudo mkdir -p /etc/docker"
    echo "  sudo tee /etc/docker/daemon.json <<'EOF'"
    echo "  {"
    echo '    "registry-mirrors": ['
    echo '      "https://docker.1ms.run",'
    echo '      "https://docker.xuanyuan.me"'
    echo '    ]'
    echo "  }"
    echo "  EOF"
    echo "  sudo systemctl daemon-reload"
    echo "  sudo systemctl restart docker"
    echo ""
    read -p "继续部署? [y/N]: " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy] ]]; then
        exit 1
    fi
}

case "${1:-up}" in
    up)
        check_docker_mirror
        echo -e "${GREEN}启动服务...${NC}"
        docker compose -f "$COMPOSE_FILE" up -d --build || {
            echo -e "${RED}构建失败，请检查上面的错误信息${NC}"
            exit 1
        }
        echo ""
        echo -e "${GREEN}部署完成!${NC}"
        echo "访问地址: http://localhost:${PORT:-80}"
        echo "查看日志: bash deploy_cn.sh logs"
        ;;
    down)
        docker compose -f "$COMPOSE_FILE" down
        echo -e "${GREEN}服务已停止${NC}"
        ;;
    logs)
        docker compose -f "$COMPOSE_FILE" logs -f
        ;;
    restart)
        docker compose -f "$COMPOSE_FILE" restart
        echo -e "${GREEN}服务已重启${NC}"
        ;;
    *)
        echo "Usage: bash deploy_cn.sh [up|down|logs|restart]"
        exit 1
        ;;
esac
