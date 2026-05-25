@echo off
chcp 65001 >nul
REM =============================================
REM WMS System - China Edition Docker Deploy (Windows)
REM Usage: deploy_cn.bat [up|down|logs|restart]
REM =============================================

setlocal enabledelayedexpansion
cd /d "%~dp0"

set COMPOSE_FILE=deploy/docker-compose.cn.yml

if "%~1"=="" (set "CMD=up") else (set "CMD=%~1")

if /I "%CMD%"=="up" (
    echo.
    echo [提示] 请确保已配置 Docker 镜像加速器
    echo   文档: https://help.aliyun.com/document_detail/60750.html
    echo.
    docker compose -f %COMPOSE_FILE% up -d --build
    if errorlevel 1 (
        echo.
        echo 构建失败，请检查上面的错误信息
        exit /b 1
    )
    echo.
    echo 部署完成! 访问 http://localhost
    echo 查看日志: deploy_cn.bat logs
    goto :eof
)

if /I "%CMD%"=="down" (
    docker compose -f %COMPOSE_FILE% down
    echo 服务已停止
    goto :eof
)

if /I "%CMD%"=="logs" (
    docker compose -f %COMPOSE_FILE% logs -f
    goto :eof
)

if /I "%CMD%"=="restart" (
    docker compose -f %COMPOSE_FILE% restart
    echo 服务已重启
    goto :eof
)

echo Usage: deploy_cn.bat [up^|down^|logs^|restart]
exit /b 1
