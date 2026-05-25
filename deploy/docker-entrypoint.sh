#!/bin/bash
set -e

echo "=== Bomiot WMS ==="

# build setup.ini from env vars
cat > /app/setup.ini << INIEOF
[project]
name = awesomewms

[database]
engine = ${DB_ENGINE:-mysql}
name = ${DB_NAME:-wms}
user = ${DB_USER:-root}
password = ${DB_PASSWORD:-root123}
host = ${DB_HOST:-db}
port = ${DB_PORT:-3306}

[templates]
name = templates/dist/spa/index.html

[locale]
time_zone = ${TIME_ZONE:-Asia/Shanghai}

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
email_host = ${EMAIL_HOST:-}
email_port = ${EMAIL_PORT:-465}
email_host_user = ${EMAIL_HOST_USER:-}
email_host_password = ${EMAIL_HOST_PASSWORD:-}
default_from_email = ${DEFAULT_FROM_EMAIL:-}
email_from = ${EMAIL_FROM:-}
email_use_ssl = True
INIEOF

# wait for MySQL
if [ "${DB_ENGINE:-mysql}" = "mysql" ]; then
    echo "Waiting for MySQL at ${DB_HOST:-db}:${DB_PORT:-3306}..."
    for i in $(seq 1 30); do
        if python -c "
import MySQLdb
try:
    c = MySQLdb.connect(host='${DB_HOST:-db}', port=${DB_PORT:-3306}, user='${DB_USER:-root}', passwd='${DB_PASSWORD:-root123}')
    c.close()
    exit(0)
except:
    exit(1)
" 2>/dev/null; then
            echo "MySQL ready."
            break
        fi
        echo "  try $i/30 ..."
        sleep 2
    done
fi

echo "Running migrations..."
python bomiot/server/manage.py migrate --noinput

echo "Collecting static files..."
python bomiot/server/manage.py collectstatic --noinput 2>/dev/null || true

# create default admin if none exists
python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(is_superuser=True).exists():
    User.objects.create_superuser('admin', 'admin@wms.com', '${ADMIN_PASSWORD:-admin123}')
    print('Superuser created: admin / ${ADMIN_PASSWORD:-admin123}')
else:
    print('Superuser already exists')
"

echo "=== Starting gunicorn ==="
exec gunicorn bomiot.server.server.wsgi:application \
    -c /app/deploy/gunicorn.conf.py \
    --access-logfile - \
    --error-logfile -
