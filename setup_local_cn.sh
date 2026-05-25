#!/usr/bin/env bash
# =============================================
# WMS China Edition - Local Setup (conda)
#   Uses domestic mirrors for pip and npm
# Usage: bash setup_local_cn.sh
# =============================================

set -e
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$(dirname "$0")"

PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"
NPM_MIRROR="https://registry.npmmirror.com"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  WMS 本地部署 (中国特供版)${NC}"
echo -e "${GREEN}========================================${NC}"

# ---------- Step 1: Configure MariaDB ----------
echo ""
echo -e "${GREEN}[1/6] 配置 MariaDB...${NC}"
sudo /usr/bin/mariadb <<'SQL'
CREATE DATABASE IF NOT EXISTS wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'wms_user'@'localhost' IDENTIFIED BY 'wms_password';
CREATE USER IF NOT EXISTS 'wms_user'@'127.0.0.1' IDENTIFIED BY 'wms_password';
CREATE USER IF NOT EXISTS 'wms_user'@'%' IDENTIFIED BY 'wms_password';
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'localhost';
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'127.0.0.1';
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
SQL
echo -e "${GREEN}  -> 数据库 'wms' 已创建${NC}"

# ---------- Step 2: Write setup.ini ----------
echo ""
echo -e "${GREEN}[2/6] 写入 setup.ini...${NC}"
cat > setup.ini <<'INIEOF'
[project]
name = awesomewms

[database]
engine = mysql
name = wms
user = wms_user
password = wms_password
host = 127.0.0.1
port = 3306

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
echo -e "${GREEN}  -> setup.ini 已写入${NC}"

# ---------- Step 3: Install Python dependencies with Tsinghua mirror ----------
echo ""
echo -e "${GREEN}[3/6] 安装 Python 依赖 (清华源)...${NC}"
pip install -i "$PIP_MIRROR" -r requirements.txt mysqlclient
echo -e "${GREEN}  -> 依赖安装完成${NC}"

# ---------- Step 4: Run migrations ----------
echo ""
echo -e "${GREEN}[4/6] 数据库迁移...${NC}"
python bomiot/server/manage.py migrate
echo -e "${GREEN}  -> 迁移完成${NC}"

# ---------- Step 5: Create superuser ----------
echo ""
echo -e "${GREEN}[5/6] 创建管理员用户...${NC}"
python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(is_superuser=True).exists():
    User.objects.create_superuser('admin', 'admin@wms.com', 'admin123')
    print('Created: admin / admin123')
else:
    print('Superuser already exists')
"
echo -e "${GREEN}  -> 管理员: admin / admin123${NC}"

# ---------- Step 6: Build frontend with npm mirror ----------
echo ""
echo -e "${GREEN}[6/6] 构建前端 (npm 淘宝镜像)...${NC}"
cd awesomewms/templates

# Set npm mirror
npm config set registry "$NPM_MIRROR"

if [ ! -d "node_modules" ]; then
    npm install
fi
npm run build
cd ../..
echo -e "${GREEN}  -> 前端构建完成${NC}"

# ---------- Done ----------
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  部署完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "启动服务:"
echo "  cd $(pwd)"
echo "  python bomiot/server/manage.py runserver"
echo ""
echo "访问地址: http://127.0.0.1:8000"
echo "登录账号: admin / admin123"
echo ""
