#!/usr/bin/env bash
# =============================================
# MySQL/MariaDB Database Setup Script
# Usage: bash scripts/setup_db.sh
# =============================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "============================================"
echo "  WMS Database Setup"
echo "============================================"
echo ""

# detect mysql/mariadb
if command -v mariadb &> /dev/null; then
    DB_CLI="mariadb"
elif command -v mysql &> /dev/null; then
    DB_CLI="mysql"
else
    log_error "MariaDB/MySQL client not found. Please install it first."
    exit 1
fi

log_info "Using database client: $DB_CLI"

# collect connection info
read -p "Database host [127.0.0.1]: " DB_HOST; DB_HOST=${DB_HOST:-127.0.0.1}
read -p "Database port [3306]: " DB_PORT; DB_PORT=${DB_PORT:-3306}
read -p "Admin user [root]: " ADMIN_USER; ADMIN_USER=${ADMIN_USER:-root}
read -sp "Admin password: " ADMIN_PASS; echo ""

read -p "New database name [wms]: " DB_NAME; DB_NAME=${DB_NAME:-wms}
read -p "New app user [wms_user]: " APP_USER; APP_USER=${APP_USER:-wms_user}
read -sp "New app password [wms_password]: " APP_PASS; APP_PASS=${APP_PASS:-wms_password}
echo ""

# run SQL
log_info "Creating database and user..."

$DB_CLI -h "$DB_HOST" -P "$DB_PORT" -u "$ADMIN_USER" -p"$ADMIN_PASS" << SQL
CREATE DATABASE IF NOT EXISTS $DB_NAME
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '$APP_USER'@'localhost' IDENTIFIED BY '$APP_PASS';
CREATE USER IF NOT EXISTS '$APP_USER'@'127.0.0.1' IDENTIFIED BY '$APP_PASS';
CREATE USER IF NOT EXISTS '$APP_USER'@'%' IDENTIFIED BY '$APP_PASS';

GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$APP_USER'@'localhost';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$APP_USER'@'127.0.0.1';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$APP_USER'@'%';

FLUSH PRIVILEGES;
SQL

if [ $? -eq 0 ]; then
    log_info "Database '$DB_NAME' and user '$APP_USER' created successfully."
    echo ""
    echo "Now update your setup.ini:"
    echo "  [database]"
    echo "  engine = mysql"
    echo "  name = $DB_NAME"
    echo "  user = $APP_USER"
    echo "  password = $APP_PASS"
    echo "  host = $DB_HOST"
    echo "  port = $DB_PORT"
else
    log_error "Database setup failed."
    exit 1
fi
