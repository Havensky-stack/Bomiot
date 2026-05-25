@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set REPO_URL=https://github.com/Havensky-stack/Bomiot.git
set PROJECT_DIR=%USERPROFILE%\bomiot-wms

echo.
echo   Awesome WMS - Windows 一键部署
echo.

REM --- 检查 Docker Desktop ---
where docker >/dev/null 2>&1
if %errorlevel% neq 0 goto :docker_missing

docker info >/dev/null 2>&1
if %errorlevel% neq 0 goto :docker_not_running

echo [正常] Docker Desktop 已安装并运行中
goto :choose_cn

:docker_not_running
echo [提示] Docker Desktop 已安装但未启动。
echo        请从开始菜单启动 Docker Desktop，然后重新运行此脚本。
pause
exit /b 1

:docker_missing
echo [提示] Docker Desktop 未安装。
echo.

REM --- 检查 WSL ---
wsl --status >/dev/null 2>&1
if %errorlevel% equ 0 goto :wsl_ok

echo [提示] WSL 未安装 - Docker Desktop 依赖 WSL2。
echo.
echo         是否现在安装 WSL？需要管理员权限，安装后需重启电脑。
echo         [Y] 是，安装 WSL
echo         [N] 否，我自己安装
choice /c YN /n
if !errorlevel! equ 2 goto :manual_install
echo.
echo 正在安装 WSL - 可能需要几分钟...
wsl --install
echo.
echo WSL 安装已启动。请重启电脑后重新运行此脚本。
pause
exit /b 0

:wsl_ok
echo [正常] WSL 已安装

:manual_install
echo.
echo 请完成以下手动安装步骤：
echo   1. 以管理员身份打开 PowerShell
echo   2. 运行: wsl --install
echo   3. 重启电脑
echo   4. 安装 Docker Desktop: https://www.docker.com/products/docker-desktop/
echo.
echo 完成后重新运行此脚本。
pause
exit /b 1

REM --- 选择镜像源 ---
:choose_cn
echo.
echo 是否在中国大陆使用国内镜像源？
echo   [Y] 是，使用国内镜像 - 阿里云
echo   [N] 否，使用国际镜像 - Docker Hub
choice /c YN /n /m "请选择 [Y]: "
if !errorlevel! equ 2 (
    echo [OK] 使用国际镜像源
    set COMPOSE_FILE=deploy/docker-compose.yml
) else (
    echo [OK] 使用国内镜像源
    set COMPOSE_FILE=deploy/docker-compose.cn.yml
)

REM --- 克隆/更新项目 ---
if not exist "%PROJECT_DIR%" goto :clone

echo.
echo 项目目录已存在: %PROJECT_DIR%
echo   [1] 更新 - git pull
echo   [2] 删除并重新克隆
echo   [3] 跳过克隆，直接启动
choice /c 123 /n /m "请选择 [1]: "
if !errorlevel! equ 3 goto :start_compose
if !errorlevel! equ 2 (
    rmdir /s /q "%PROJECT_DIR%"
    goto :clone
)
cd /d "%PROJECT_DIR%"
git pull
goto :start_compose

:clone
echo.
echo 正在克隆项目...
git clone --depth 1 "%REPO_URL%" "%PROJECT_DIR%"
if %errorlevel% neq 0 (
    echo [错误] 克隆失败，请检查网络连接。
    echo        如果在国内，可能需要配置 Git 代理。
    pause
    exit /b 1
)

REM --- 启动服务 ---
:start_compose
cd /d "%PROJECT_DIR%"

echo.
echo 正在启动服务 - 配置文件: %COMPOSE_FILE%...
docker compose -f "%COMPOSE_FILE%" up -d --build
if %errorlevel% neq 0 (
    echo.
    echo [错误] 部署失败，请检查上面的错误信息。
    echo   查看日志: docker compose -f %COMPOSE_FILE% logs
    pause
    exit /b 1
)

echo.
echo   部署完成！
echo   访问地址:  http://localhost:8000
echo   管理员账号: admin / admin123
echo.
echo   查看日志:  docker compose -f %COMPOSE_FILE% logs -f
echo   停止服务:  docker compose -f %COMPOSE_FILE% down
echo.
pause
