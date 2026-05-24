@echo off
chcp 65001 >nul
REM =============================================
REM Bomiot WMS - Windows Production Deploy
REM =============================================

cd /d "%~dp0"

if "%1"=="" goto :up
if "%1"=="up" goto :up
if "%1"=="down" goto :down
if "%1"=="logs" goto :logs
if "%1"=="restart" goto :restart
goto :help

:up
echo === Bomiot WMS Deploy ===
echo Starting: MySQL + App (gunicorn) + Nginx
echo.
docker compose -f deploy/docker-compose.yml up -d --build
echo.
echo === Deploy Complete ===
echo URL:  http://localhost
echo User: admin / admin123
goto :eof

:down
docker compose -f deploy/docker-compose.yml down
echo All services stopped.
goto :eof

:logs
docker compose -f deploy/docker-compose.yml logs -f
goto :eof

:restart
docker compose -f deploy/docker-compose.yml restart web
goto :eof

:help
echo Usage: deploy.bat [up^|down^|logs^|restart]
echo.
echo   up       Build and start all services (default)
echo   down     Stop and remove all services
echo   logs     View logs from all services
echo   restart  Restart the web application
goto :eof
