#!/bin/bash
# =============================================
# WMS Local Deployment Script
# Run this in your terminal: bash setup_local.sh
# =============================================

set -e
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

cd "$(dirname "$0")"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  WMS Local Setup${NC}"
echo -e "${GREEN}========================================${NC}"

# ---------- Step 1: Configure MariaDB ----------
echo ""
echo -e "${GREEN}[1/6] Configuring MariaDB...${NC}"
sudo /usr/bin/mariadb <<'SQL'
CREATE DATABASE IF NOT EXISTS wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'wms_user'@'localhost' IDENTIFIED BY 'wms_password';
CREATE USER IF NOT EXISTS 'wms_user'@'127.0.0.1' IDENTIFIED BY 'wms_password';
CREATE USER IF NOT EXISTS 'wms_user'@'%' IDENTIFIED BY 'wms_password';
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'localhost';
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'127.0.0.1';
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'%';
-- ensure root can connect with password too
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
SQL
echo -e "${GREEN}  -> Database 'wms' created.${NC}"

# ---------- Step 2: Write setup.ini ----------
echo ""
echo -e "${GREEN}[2/6] Writing setup.ini...${NC}"
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
echo -e "${GREEN}  -> setup.ini written.${NC}"

# ---------- Step 3: Install Python dependencies ----------
echo ""
echo -e "${GREEN}[3/6] Installing Python dependencies...${NC}"
/home/havensky/.conda/envs/wms/bin/pip install -r requirements.txt mysqlclient
echo -e "${GREEN}  -> Dependencies installed.${NC}"

# ---------- Step 4: Run migrations ----------
echo ""
echo -e "${GREEN}[4/6] Running database migrations...${NC}"
/home/havensky/.conda/envs/wms/bin/python bomiot/server/manage.py migrate
echo -e "${GREEN}  -> Migrations complete.${NC}"

# ---------- Step 5: Create superuser ----------
echo ""
echo -e "${GREEN}[5/6] Creating admin user...${NC}"
/home/havensky/.conda/envs/wms/bin/python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(is_superuser=True).exists():
    User.objects.create_superuser('admin', 'admin@wms.com', 'admin123')
    print('Created: admin / admin123')
else:
    print('Superuser already exists')
"
echo -e "${GREEN}  -> Admin: admin / admin123${NC}"

# ---------- Step 6: Build frontend ----------
echo ""
echo -e "${GREEN}[6/6] Building frontend...${NC}"
cd awesomewms/templates
if [ ! -d "node_modules" ]; then
    npm install
fi
npm run build
cd ../..
echo -e "${GREEN}  -> Frontend built.${NC}"

# ---------- Done ----------
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Start the server:"
echo "  cd $(pwd)"
echo "  /home/havensky/.conda/envs/wms/bin/python bomiot/server/manage.py runserver"
echo ""
echo "Then open: http://127.0.0.1:8000"
echo "Login:     admin / admin123"
echo ""
