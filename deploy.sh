#!/usr/bin/env bash
# =============================================
# WMS Docker One-Click Deploy
# Usage: bash deploy.sh [up|down|build|logs]
# =============================================

set -e

cd "$(dirname "$0")"

case "${1:-up}" in
    up)
        echo "=== WMS Docker Deploy ==="
        echo ""
        echo "Starting services: MySQL + Web"
        echo "Default login: admin / admin123"
        echo ""
        docker compose -f deploy/docker-compose.yml up -d --build
        echo ""
        echo "=== Deploy Complete ==="
        echo "Open: http://localhost:8000"
        echo "Login: admin / admin123"
        echo ""
        echo "View logs:  bash deploy.sh logs"
        echo "Stop:       bash deploy.sh down"
        ;;
    down)
        docker compose -f deploy/docker-compose.yml down
        echo "All services stopped."
        ;;
    build)
        docker compose -f deploy/docker-compose.yml build --no-cache
        echo "Build complete."
        ;;
    logs)
        docker compose -f deploy/docker-compose.yml logs -f
        ;;
    restart)
        docker compose -f deploy/docker-compose.yml restart web
        ;;
    *)
        echo "Usage: bash deploy.sh [up|down|build|logs|restart]"
        ;;
esac
