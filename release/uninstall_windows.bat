@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

set PROJECT_DIR=%USERPROFILE%\bomiot-wms

echo.
echo   Awesome WMS - Windows Uninstall
echo.

if exist "%PROJECT_DIR%" (
    cd /d "%PROJECT_DIR%"

    for %%F in ("deploy\docker-compose.cn.yml" "deploy\docker-compose.yml") do (
        if exist %%F (
            echo Stopping Docker containers...
            docker compose -f %%F down -v 2>nul
            goto :remove_files
        )
    )
)

:remove_files
echo.

if exist "%PROJECT_DIR%" (
    echo About to delete: %PROJECT_DIR%
    choice /c YN /n /m "Confirm delete? [Y/N]: "
    if !errorlevel! equ 2 (
        echo Skipped deleting project files
    ) else (
        rmdir /s /q "%PROJECT_DIR%"
        echo [OK] Project files deleted
    )
) else (
    echo [!] Project directory not found: %PROJECT_DIR%
)

echo.

echo Uninstall Docker Desktop?
echo   This requires manual uninstall from Windows Settings.
echo   Docker data will NOT be automatically deleted.
echo.
choice /c YN /n /m "Proceed? [Y/N]: "
if !errorlevel! equ 2 (
    echo Skipped Docker Desktop uninstall
    goto :check_wsl
)

echo.
echo To manually uninstall Docker Desktop:
echo   1. Open Windows Settings - Apps - Installed apps
echo   2. Search "Docker Desktop" and click Uninstall
echo.
echo Also delete these folders if they exist:
echo   %%USERPROFILE%%\.docker
echo   %%APPDATA%%\Docker
echo   %%LOCALAPPDATA%%\Docker
echo.

:check_wsl
wsl --status >nul 2>&1
if %errorlevel% neq 0 goto :done

echo Uninstall WSL (Windows Subsystem for Linux)?
echo   This will remove all WSL distros and data.
echo   [Y] Yes, uninstall WSL
echo   [N] No, keep WSL (other apps may depend on it)
choice /c YN /n
if !errorlevel! equ 2 (
    echo Skipped WSL uninstall
    goto :done
)

echo.
echo Removing WSL distros...
wsl --unregister docker-desktop-data 2>nul
wsl --unregister docker-desktop 2>nul
echo [OK] WSL distros removed
echo.
echo To fully remove WSL, run in PowerShell as Admin:
echo   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

:done
echo.
echo   Uninstall complete.
echo.
pause
