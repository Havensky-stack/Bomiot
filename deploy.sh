#!/usr/bin/env bash
# =============================================
# Bomiot WMS - One-Click Production Deploy
# =============================================
set -e
cd "$(dirname "$0")"

case "${1:-up}" in
    up)
        echo "=== Bomiot WMS Deploy ==="
        echo "Starting: MySQL + App (gunicorn) + Nginx"
        echo ""
        docker compose -f deploy/docker-compose.yml up -d --build
        echo ""
        echo "=== Deploy Complete ==="
        echo "URL:  http://localhost:${PORT:-80}"
        echo "User: admin / ${ADMIN_PASSWORD:-admin123}"
        ;;
    down)
        docker compose -f deploy/docker-compose.yml down
        echo "Stopped."
        ;;
    logs)
        docker compose -f deploy/docker-compose.yml logs -f
        ;;
    restart)
        docker compose -f deploy/docker-compose.yml restart web
        ;;
    *)
        echo "Usage: bash deploy.sh [up|down|logs|restart]"
        echo ""
        echo "  up       Build and start all services (default)"
        echo "  down     Stop and remove all services"
        echo "  logs     View logs from all services"
        echo "  restart  Restart the web application"
        ;;
esac
