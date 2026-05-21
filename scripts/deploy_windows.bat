@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
REM =============================================
REM WMS System - Windows One-Click Deploy Script
REM Usage: scripts\deploy_windows.bat
REM =============================================

cd /d "%~dp0.."

echo ============================================
echo  WMS System - Windows Deployment Script
echo ============================================
echo.

REM ---------- 1) check python ----------
echo [INFO] Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Please install Python 3.9+
    pause
    exit /b 1
)
python --version
echo.

REM ---------- 2) check node ----------
echo [INFO] Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js not found. Please install Node.js 18+
    pause
    exit /b 1
)
node --version
echo.

REM ---------- 3) configure database ----------
echo [INFO] Database Configuration
echo    [1] SQLite (default, no setup needed)
echo    [2] MySQL
set /p DB_CHOICE="Select database [1/2]: "
if "%DB_CHOICE%"=="2" (
    set DB_ENGINE=mysql
    set /p MYSQL_HOST="MySQL host [127.0.0.1]: "
    if "!MYSQL_HOST!"=="" set MYSQL_HOST=127.0.0.1
    set /p MYSQL_PORT="MySQL port [3306]: "
    if "!MYSQL_PORT!"=="" set MYSQL_PORT=3306
    set /p MYSQL_DB="Database name [wms]: "
    if "!MYSQL_DB!"=="" set MYSQL_DB=wms
    set /p MYSQL_USER="MySQL user [root]: "
    if "!MYSQL_USER!"=="" set MYSQL_USER=root
    set /p MYSQL_PASS="MySQL password: "

    REM write setup.ini
    (
        echo [project]
        echo name = awesomewms
        echo.
        echo [database]
        echo engine = !DB_ENGINE!
        echo name = !MYSQL_DB!
        echo user = !MYSQL_USER!
        echo password = !MYSQL_PASS!
        echo host = !MYSQL_HOST!
        echo port = !MYSQL_PORT!
        echo.
        echo [templates]
        echo name = templates/dist/spa/index.html
        echo.
        echo [locale]
        echo time_zone = 'Asia/Shanghai'
        echo.
        echo [throttle]
        echo allocation_seconds = 1
        echo throttle_seconds = 10
        echo.
        echo [request]
        echo limit = 100
        echo.
        echo [jwt]
        echo user_jwt_time = 86400
        echo.
        echo [file]
        echo file_size = 104857600
        echo file_extension = py,png,jpg,jpeg,gif,bmp,webp,txt,md,html,htm,js,css,json,xml,csv,xlsx,xls,ppt,pptx,doc,docx,pdf
        echo.
        echo [mail]
        echo email_host = email_host
        echo email_port = 465
        echo email_host_user = email_host_user
        echo email_host_password = email_host_password
        echo default_from_email = default_from_email
        echo email_from = email_from
        echo email_use_ssl = True
    ) > setup.ini

    echo [INFO] Installing mysqlclient...
    pip install mysqlclient
) else (
    echo [INFO] Using SQLite.
)

REM ---------- 4) install python dependencies ----------
echo.
echo [INFO] Installing Python dependencies...
pip install -r requirements.txt
echo.

REM ---------- 5) database migration ----------
echo [INFO] Running database migrations...
python bomiot\server\manage.py migrate
echo.

REM ---------- 6) create superuser ----------
echo [INFO] Creating admin user...
python bomiot\server\manage.py createsuperuser
echo.

REM ---------- 7) build frontend ----------
echo [INFO] Building frontend...
cd awesomewms\templates

if not exist "node_modules\" (
    echo [INFO] Installing npm packages...
    call npm install
)

call npm run build
cd ..\..
echo.

REM ---------- 8) Done ----------
echo ============================================
echo  Deployment completed successfully!
echo ============================================
echo.
echo Start the server:
echo   cd %cd%
echo   python bomiot\server\manage.py runserver
echo.
echo Then open: http://127.0.0.1:8000
echo.

set /p START_NOW="Start the server now? [Y/n]: "
if /i not "%START_NOW%"=="n" (
    echo [INFO] Starting development server...
    python bomiot\server\manage.py runserver
)

pause
