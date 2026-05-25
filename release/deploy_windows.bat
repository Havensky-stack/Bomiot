@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM ============================================================
REM  Bomiot WMS — Windows One-Click Deploy
REM
REM  Double-click to run, or: deploy_windows.bat
REM ============================================================

set REPO_URL=https://github.com/Havensky-stack/Bomiot.git
set PROJECT_DIR=%USERPROFILE%\bomiot-wms

echo.
echo ============================================
echo   Bomiot WMS - Windows One-Click Deploy
echo ============================================
echo.

REM -------------------------------------------------------
REM 1. Check Docker Desktop
REM -------------------------------------------------------
where docker >nul 2>&1
if %errorlevel% equ 0 (
    docker info >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Docker Desktop is running
        goto :detect_cn
    )
    echo [!] Docker Desktop is installed but not running.
    echo     Please start Docker Desktop from the Start Menu, then re-run this script.
    pause
    exit /b 1
)

REM -------------------------------------------------------
REM 2. Docker not installed — check WSL first
REM -------------------------------------------------------
echo [!] Docker Desktop is not installed.
echo.

REM Check WSL
set WSL_OK=0
wsl --status >nul 2>&1
if %errorlevel% equ 0 (
    set WSL_OK=1
    echo [OK] WSL is installed
) else (
    echo [!] WSL is not installed (required by Docker Desktop).
    echo.
    echo     Install WSL now? This requires administrator privileges and a reboot.
    echo     [Y] Yes, install WSL
    echo     [N] No, I'll install it myself
    choice /c YN /n
    if !errorlevel! equ 2 goto :manual_wsl
    if !errorlevel! equ 1 (
        echo.
        echo Installing WSL (this may take several minutes) ...
        wsl --install
        echo.
        echo WSL installation requested. Please REBOOT your computer,
        echo then re-run this script to continue.
        pause
        exit /b 0
    )
)

:manual_wsl
echo.
echo Please install WSL manually:
echo   1. Open PowerShell as Administrator
echo   2. Run: wsl --install
echo   3. Reboot your computer
echo.
echo After rebooting, install Docker Desktop:
echo   https://www.docker.com/products/docker-desktop/
echo.
echo Then re-run this script.
pause
exit /b 1

:docker_missing
echo.
echo Please install Docker Desktop:
echo   https://www.docker.com/products/docker-desktop/
echo.
echo After installation, re-run this script.
pause
exit /b 1

REM -------------------------------------------------------
REM 3. Detect CN vs international
REM -------------------------------------------------------
:detect_cn
echo.
echo Detecting network environment ...
curl.exe -s --connect-timeout 3 https://registry-1.docker.io/v2/ >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker Hub reachable - using international mirrors
    set COMPOSE_FILE=deploy/docker-compose.yml
) else (
    echo [CN] Docker Hub unreachable - using China mirrors
    set COMPOSE_FILE=deploy/docker-compose.cn.yml
)

REM -------------------------------------------------------
REM 4. Clone / update project
REM -------------------------------------------------------
if exist "%PROJECT_DIR%" (
    echo.
    echo Project directory already exists: %PROJECT_DIR%
    echo   [1] Update (git pull^)
    echo   [2] Remove and re-clone
    echo   [3] Skip clone, just start
    choice /c 123 /n /m "Choice [1]: "
    if !errorlevel! equ 3 goto :start_compose
    if !errorlevel! equ 2 (
        rmdir /s /q "%PROJECT_DIR%"
        goto :clone
    )
    cd /d "%PROJECT_DIR%"
    git pull
    goto :start_compose
)

:clone
echo.
echo Cloning project ...
git clone --depth 1 "%REPO_URL%" "%PROJECT_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to clone repository. Check your network connection.
    pause
    exit /b 1
)

REM -------------------------------------------------------
REM 5. Start Docker Compose
REM -------------------------------------------------------
:start_compose
cd /d "%PROJECT_DIR%"

echo.
echo Starting services (compose file: %COMPOSE_FILE%) ...
docker compose -f "%COMPOSE_FILE%" up -d --build
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Deployment failed. Check the error messages above.
    echo Run the following to view logs:
    echo   docker compose -f %COMPOSE_FILE% logs
    pause
    exit /b 1
)

echo.
echo ============================================
echo   Deploy complete!
echo   URL:  http://localhost:8000
echo   Admin login: admin / admin123
echo.
echo   View logs:   docker compose -f %COMPOSE_FILE% logs -f
echo   Stop:        docker compose -f %COMPOSE_FILE% down
echo ============================================
pause
