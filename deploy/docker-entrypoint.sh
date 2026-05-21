#!/bin/bash
set -e

echo "=== WMS Docker Entrypoint ==="
echo "Database: ${DB_ENGINE:-mysql} @ ${DB_HOST:-db}:${DB_PORT:-3306}"

# generate setup.ini from env vars
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

# wait for MySQL
if [ "$DB_ENGINE" = "mysql" ]; then
    echo "Waiting for MySQL at $DB_HOST:$DB_PORT..."
    for i in $(seq 1 30); do
        if mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; then
            echo "MySQL is ready."
            break
        fi
        echo "  attempt $i/30 ..."
        sleep 2
    done
fi

echo "Running database migrations..."
python bomiot/server/manage.py migrate --noinput

# create default superuser if none exists
python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(is_superuser=True).exists():
    User.objects.create_superuser('admin', 'admin@wms.com', 'admin123')
    print('Superuser created: admin / admin123')
else:
    print('Superuser already exists')
"

echo "=== Starting WMS Server ==="
exec python bomiot/server/manage.py runserver 0.0.0.0:8000
