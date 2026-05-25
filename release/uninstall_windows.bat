@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

set PROJECT_DIR=%USERPROFILE%\bomiot-wms

echo.
echo   Awesome WMS - Windows 一键卸载
echo.

REM --- 停止 Docker 容器 ---
if not exist "%PROJECT_DIR%" goto :no_project

cd /d "%PROJECT_DIR%"
for %%F in ("deploy\docker-compose.cn.yml" "deploy\docker-compose.yml") do (
    if exist %%F (
        echo 正在停止 Docker 容器...
        docker compose -f %%F down -v 2>nul
        goto :remove_files
    )
)

:no_project
echo [提示] 项目目录不存在: %PROJECT_DIR%
goto :ask_docker

REM --- 删除项目文件 ---
:remove_files
echo.
echo 即将删除: %PROJECT_DIR%
choice /c YN /n /m "确认删除？[Y/N]: "
if !errorlevel! equ 2 (
    echo 已跳过删除项目文件
) else (
    rmdir /s /q "%PROJECT_DIR%"
    echo [完成] 项目文件已删除
)

REM --- Docker Desktop ---
:ask_docker
echo.
echo 是否卸载 Docker Desktop？
echo   需要从 Windows 设置中手动卸载。
echo   Docker 数据不会自动删除。
echo.
choice /c YN /n /m "准备卸载？[Y/N]: "
if !errorlevel! equ 2 goto :check_wsl

echo.
echo 手动卸载 Docker Desktop 步骤：
echo   1. 打开 Windows 设置 - 应用 - 已安装的应用
echo   2. 搜索 Docker Desktop 并点击卸载
echo.
echo 同时建议删除以下目录（如存在）：
echo   %%USERPROFILE%%\.docker
echo   %%APPDATA%%\Docker
echo   %%LOCALAPPDATA%%\Docker
echo.

REM --- WSL ---
:check_wsl
wsl --status >nul 2>&1
if %errorlevel% neq 0 goto :done

echo 是否卸载 WSL - Windows Subsystem for Linux？
echo   此操作会删除所有 WSL 发行版和数据。
echo   [Y] 是，卸载 WSL
echo   [N] 否，保留 WSL - 其他应用可能依赖它
choice /c YN /n
if !errorlevel! equ 2 (
    echo 已跳过卸载 WSL
    goto :done
)

echo.
echo 正在删除 WSL 发行版...
wsl --unregister docker-desktop-data 2>nul
wsl --unregister docker-desktop 2>nul
echo [完成] WSL 发行版已删除
echo.
echo 如需完全移除 WSL，请在 PowerShell 中以管理员身份运行：
echo   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

:done
echo.
echo   卸载完成。
echo.
pause
