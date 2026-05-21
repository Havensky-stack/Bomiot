#!/usr/bin/env bash
# =============================================
# WMS System - Linux One-Click Deploy Script
# Usage: bash scripts/deploy_linux.sh
# =============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ---------- 1) check system dependencies ----------
log_info "Checking system dependencies..."

check_cmd() {
    command -v "$1" >/dev/null 2>&1 || { log_error "$1 is required but not installed."; exit 1; }
}

check_cmd python3
check_cmd pip3
check_cmd node
check_cmd npm

# check python version (>=3.9)
PY_VER=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
if [[ "$(echo "$PY_VER >= 3.9" | bc 2>/dev/null)" != "1" ]]; then
    log_warn "Python >=3.9 is recommended, current: $PY_VER"
fi

log_info "System check passed."

# ---------- 2) configure database ----------
log_info "Configuring database..."

DB_ENGINE="sqlite"

read -p "Use MySQL instead of SQLite? [y/N]: " USE_MYSQL
if [[ "$USE_MYSQL" =~ ^[Yy] ]]; then
    DB_ENGINE="mysql"

    read -p "MySQL host [127.0.0.1]: " MYSQL_HOST; MYSQL_HOST=${MYSQL_HOST:-127.0.0.1}
    read -p "MySQL port [3306]: " MYSQL_PORT; MYSQL_PORT=${MYSQL_PORT:-3306}
    read -p "Database name [wms]: " MYSQL_DB; MYSQL_DB=${MYSQL_DB:-wms}
    read -p "MySQL user [root]: " MYSQL_USER; MYSQL_USER=${MYSQL_USER:-root}
    read -sp "MySQL password: " MYSQL_PASS; echo

    # write setup.ini
    cat > setup.ini << INIEOF
[project]
name = awesomewms

[database]
engine = $DB_ENGINE
name = $MYSQL_DB
user = $MYSQL_USER
password = $MYSQL_PASS
host = $MYSQL_HOST
port = $MYSQL_PORT

[templates]
name = templates/dist/spa/index.html

[locale]
time_zone = 'Asia/Shanghai'

[throttle]
allocation_seconds = 1
throttle_seconds = 10

[request]
limit = 100

[jwt]
user_jwt_time = 86400

[file]
file_size = 104857600
file_extension = py,png,jpg,jpeg,gif,bmp,webp,txt,md,html,htm,js,css,json,xml,csv,xlsx,xls,ppt,pptx,doc,docx,pdf

[mail]
email_host = email_host
email_port = 465
email_host_user = email_host_user
email_host_password = email_host_password
default_from_email = default_from_email
email_from = email_from
email_use_ssl = True
INIEOF

    # install mysqlclient
    log_info "Installing mysqlclient..."
    pip3 install mysqlclient
else
    log_info "Using SQLite (default)."
fi

# ---------- 3) install python dependencies ----------
log_info "Installing Python dependencies..."
pip3 install -r requirements.txt

# ---------- 4) database migration ----------
log_info "Running database migrations..."
python3 bomiot/server/manage.py migrate

# ---------- 5) create superuser ----------
log_info "Creating admin user..."
echo "Please enter admin credentials:"
python3 bomiot/server/manage.py createsuperuser

# ---------- 6) build frontend ----------
log_info "Building frontend..."
cd awesomewms/templates

if [[ ! -d "node_modules" ]]; then
    log_info "Installing npm packages..."
    npm install
fi

npm run build
cd "$PROJECT_DIR"

# ---------- 7) Done ----------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Deployment completed successfully!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Start the server:"
echo "  cd $PROJECT_DIR"
echo "  python3 bomiot/server/manage.py runserver"
echo ""
echo "Then open: http://127.0.0.1:8000"
echo ""

read -p "Start the server now? [Y/n]: " START_NOW
if [[ ! "$START_NOW" =~ ^[Nn] ]]; then
    log_info "Starting development server..."
    python3 bomiot/server/manage.py runserver
fi
