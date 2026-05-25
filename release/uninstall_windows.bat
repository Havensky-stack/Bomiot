@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM ============================================================
REM  Awesome WMS — Windows 一键卸载脚本
REM
REM  双击运行，或在终端中执行: uninstall_windows.bat
REM ============================================================

set PROJECT_DIR=%USERPROFILE%\bomiot-wms

echo.
echo ============================================
echo   Awesome WMS - Windows 一键卸载
echo ============================================
echo.

REM -------------------------------------------------------
REM 1. 停止并删除 Docker 容器
REM -------------------------------------------------------
if exist "%PROJECT_DIR%" (
    cd /d "%PROJECT_DIR%"

    for %%F in ("deploy\docker-compose.cn.yml" "deploy\docker-compose.yml") do (
        if exist %%F (
            echo 正在停止 Docker 容器 ...
            docker compose -f %%F down -v 2>nul
            goto :remove_files
        )
    )
)

:remove_files
echo.

REM -------------------------------------------------------
REM 2. 删除项目文件
REM -------------------------------------------------------
if exist "%PROJECT_DIR%" (
    echo 即将删除项目目录: %PROJECT_DIR%
    choice /c YN /n /m "确认删除？[Y/N]: "
    if !errorlevel! equ 2 (
        echo 已跳过删除项目文件
    ) else (
        rmdir /s /q "%PROJECT_DIR%"
        echo [完成] 项目文件已删除
    )
) else (
    echo [提示] 项目目录不存在: %PROJECT_DIR%
)

echo.

REM -------------------------------------------------------
REM 3. 询问是否卸载 Docker Desktop
REM -------------------------------------------------------
echo 是否卸载 Docker Desktop？
echo   此操作需要从 Windows 设置中卸载 Docker Desktop。
echo   不会自动删除 - 需要手动操作。
echo.
choice /c YN /n /m "准备卸载？[Y/N]: "
if !errorlevel! equ 2 (
    echo 已跳过卸载 Docker Desktop
    goto :check_wsl
)

echo.
echo 请按以下步骤手动卸载 Docker Desktop：
echo   1. 打开 Windows 设置 ^> 应用 ^> 已安装的应用
echo   2. 搜索 "Docker Desktop"
echo   3. 点击卸载
echo.
echo 同时建议删除以下目录（如存在）：
echo   %%USERPROFILE%%\.docker
echo   %%APPDATA%%\Docker
echo   %%LOCALAPPDATA%%\Docker
echo.

REM -------------------------------------------------------
REM 4. 询问是否卸载 WSL
REM -------------------------------------------------------
:check_wsl
wsl --status >nul 2>&1
if %errorlevel% neq 0 goto :done

echo 是否卸载 WSL（Windows Subsystem for Linux）？
echo   此操作会删除所有 WSL 发行版和数据。
echo   [Y] 是，卸载 WSL
echo   [N] 否，保留 WSL（其他应用可能依赖它）
choice /c YN /n
if !errorlevel! equ 2 (
    echo 已跳过卸载 WSL
    goto :done
)

echo.
echo 正在卸载 WSL ...
wsl --unregister docker-desktop-data 2>nul
wsl --unregister docker-desktop 2>nul
wsl --unregister bomiot-wms 2>nul

echo [完成] WSL 发行版已注销
echo.
echo 如需完全移除 WSL，请以管理员身份在 PowerShell 中运行：
echo   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

:done
echo.
echo ============================================
echo   卸载完成
echo ============================================
pause
