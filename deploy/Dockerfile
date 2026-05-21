# =============================================
# Stage 1: Build frontend
# =============================================
FROM node:20-alpine AS frontend-builder

WORKDIR /frontend
COPY awesomewms/templates/package.json awesomewms/templates/yarn.lock ./
RUN yarn install --frozen-lockfile

COPY awesomewms/templates/ .
RUN yarn build

# =============================================
# Stage 2: Build backend
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
RUN pip install --no-cache-dir -r requirements.txt mysqlclient

COPY . .

# copy frontend build from stage 1
COPY --from=frontend-builder /frontend/dist/spa awesomewms/templates/dist/spa

RUN mkdir -p dbs logs

EXPOSE 8000

COPY deploy/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
