#!/usr/bin/env bash
# =============================================
# WMS System - China Edition Local Deploy (Linux)
#   Uses domestic mirrors for pip and npm
# Usage: bash scripts/deploy_linux_cn.sh
# =============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# ---------- China mirrors ----------
PIP_MIRROR="https://mirrors.aliyun.com/pypi/simple/"
NPM_MIRROR="https://registry.npmmirror.com"

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ---------- 1) check system dependencies ----------
log_info "检查系统依赖..."

check_cmd() {
    command -v "$1" >/dev/null 2>&1 || { log_error "$1 未安装，请先安装。"; exit 1; }
}

check_cmd python3
check_cmd pip3
check_cmd node
check_cmd npm

PY_VER=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
log_info "Python $PY_VER"

log_info "系统检查通过"

# ---------- 2) configure npm mirror ----------
log_info "配置 npm 淘宝镜像..."
npm config set registry "$NPM_MIRROR"
log_info "npm 镜像已设置为 $NPM_MIRROR"

# ---------- 3) configure database ----------
log_info "配置数据库..."

DB_ENGINE="sqlite"

read -p "使用 MySQL 替代 SQLite? [y/N]: " USE_MYSQL
if [[ "$USE_MYSQL" =~ ^[Yy] ]]; then
    DB_ENGINE="mysql"

    read -p "MySQL 主机地址 [127.0.0.1]: " MYSQL_HOST; MYSQL_HOST=${MYSQL_HOST:-127.0.0.1}
    read -p "MySQL 端口 [3306]: " MYSQL_PORT; MYSQL_PORT=${MYSQL_PORT:-3306}
    read -p "数据库名 [wms]: " MYSQL_DB; MYSQL_DB=${MYSQL_DB:-wms}
    read -p "MySQL 用户名 [root]: " MYSQL_USER; MYSQL_USER=${MYSQL_USER:-root}
    read -sp "MySQL 密码: " MYSQL_PASS; echo

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

    log_info "安装 mysqlclient..."
    pip3 install -i "$PIP_MIRROR" mysqlclient
else
    log_info "使用 SQLite"
fi

# ---------- 4) install python dependencies with Tsinghua mirror ----------
log_info "安装 Python 依赖 (清华源)..."
pip3 install -i "$PIP_MIRROR" -r requirements.txt

# ---------- 5) database migration ----------
log_info "数据库迁移..."
python3 bomiot/server/manage.py migrate

# ---------- 6) create superuser ----------
log_info "创建管理员用户..."
echo "请输入管理员账号信息:"
python3 bomiot/server/manage.py createsuperuser

# ---------- 7) build frontend with npm mirror ----------
log_info "构建前端..."
cd awesomewms/templates

if [[ ! -d "node_modules" ]]; then
    log_info "安装 npm 依赖 (淘宝镜像)..."
    npm install
fi

npm run build
cd "$PROJECT_DIR"

# ---------- 8) Done ----------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  部署完成!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "启动服务:"
echo "  cd $PROJECT_DIR"
echo "  python3 bomiot/server/manage.py runserver"
echo ""
echo "然后访问: http://127.0.0.1:8000"
echo ""

read -p "现在启动服务器? [Y/n]: " START_NOW
if [[ ! "$START_NOW" =~ ^[Nn] ]]; then
    log_info "启动开发服务器..."
    python3 bomiot/server/manage.py runserver
fi
