# =============================================
# Stage 1: Build frontend
# =============================================
FROM node:20-alpine AS frontend-builder

WORKDIR /frontend
COPY awesomewms/templates/package.json awesomewms/templates/yarn.lock ./
RUN yarn install --frozen-lockfile --ignore-scripts

COPY awesomewms/templates/ .
RUN yarn install --frozen-lockfile && yarn build

# =============================================
# Stage 2: Production backend
# =============================================
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=bomiot.server.server.settings

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir mysqlclient gunicorn whitenoise

COPY . .

COPY --from=frontend-builder /frontend/dist/spa awesomewms/templates/dist/spa

RUN mkdir -p dbs logs bomiot_static

RUN python bomiot/server/manage.py collectstatic --noinput 2>/dev/null || true

EXPOSE 8000

COPY deploy/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
