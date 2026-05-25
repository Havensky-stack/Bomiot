@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

set REPO_URL=https://github.com/Havensky-stack/Bomiot.git
set PROJECT_DIR=%USERPROFILE%\bomiot-wms

echo.
echo   Awesome WMS - Windows One-Click Deploy
echo.

where docker >nul 2>&1
if %errorlevel% equ 0 (
    docker info >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Docker Desktop is running
        goto :detect_cn
    )
    echo [!] Docker Desktop installed but not running.
    echo     Please start Docker Desktop, then re-run this script.
    pause
    exit /b 1
)

echo [!] Docker Desktop is not installed.
echo.

set WSL_OK=0
wsl --status >nul 2>&1
if %errorlevel% equ 0 (
    set WSL_OK=1
    echo [OK] WSL is installed
) else (
    echo [!] WSL is not installed (required by Docker Desktop).
    echo.
    echo     Install WSL now? Requires admin privileges and a reboot.
    echo     [Y] Yes, install WSL
    echo     [N] No, I will install it myself
    choice /c YN /n
    if !errorlevel! equ 2 goto :manual_install
    if !errorlevel! equ 1 (
        echo.
        echo Installing WSL (may take several minutes)...
        wsl --install
        echo.
        echo WSL installation started. Please REBOOT, then re-run this script.
        pause
        exit /b 0
    )
)

:manual_install
echo.
echo Please complete these manual steps:
echo   1. Open PowerShell as Administrator
echo   2. Run: wsl --install
echo   3. Reboot
echo   4. Install Docker Desktop from https://www.docker.com/products/docker-desktop/
echo.
echo Then re-run this script.
pause
exit /b 1

:detect_cn
echo.
echo Detecting network environment...
curl.exe -s --connect-timeout 3 https://registry-1.docker.io/v2/ >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker Hub reachable - using international mirrors
    set COMPOSE_FILE=deploy/docker-compose.yml
) else (
    echo [CN] Docker Hub unreachable - using China mirrors
    set COMPOSE_FILE=deploy/docker-compose.cn.yml
)

if exist "%PROJECT_DIR%" (
    echo.
    echo Project directory exists: %PROJECT_DIR%
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
echo Cloning project...
git clone --depth 1 "%REPO_URL%" "%PROJECT_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Clone failed. Check network, or configure Git proxy if in China.
    pause
    exit /b 1
)

:start_compose
cd /d "%PROJECT_DIR%"

echo.
echo Starting services (compose: %COMPOSE_FILE%)...
docker compose -f "%COMPOSE_FILE%" up -d --build
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Deploy failed. Check errors above.
    echo   Logs: docker compose -f %COMPOSE_FILE% logs
    pause
    exit /b 1
)

echo.
echo   Deploy complete.
echo   URL:  http://localhost:8000
echo   Admin: admin / admin123
echo.
echo   Logs:  docker compose -f %COMPOSE_FILE% logs -f
echo   Stop:  docker compose -f %COMPOSE_FILE% down
echo.
pause
