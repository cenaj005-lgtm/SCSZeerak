@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   SCS PUBLISH TOOL
echo ============================================================
echo.

:: ---- Project paths ----
set "REPAIR_PROJECT=D:\Projects\Portable Apps\SCS Server Manager\SCSServerManager\SCS Server Manager\SCSBootRepair.csproj"
set "LAUNCHER_PROJECT=C:\Users\SHALCOMPUTERSYSTEM\source\repos\cenaj005-lgtm\SCSLauncher\SCSLauncher\SCSLauncher.csproj"

:: ---- Find dotnet ----
set "DOTNET_PATH="
where dotnet >nul 2>&1
if %errorlevel%==0 (
    for /f "delims=" %%i in ('where dotnet') do set "DOTNET_PATH=%%i"
)
if not defined DOTNET_PATH if exist "C:\Program Files\dotnet\dotnet.exe" set "DOTNET_PATH=C:\Program Files\dotnet\dotnet.exe"
if not defined DOTNET_PATH if exist "C:\Program Files (x86)\dotnet\dotnet.exe" set "DOTNET_PATH=C:\Program Files (x86)\dotnet\dotnet.exe"
if not defined DOTNET_PATH (
    echo ERROR: dotnet.exe not found
    goto :HOLD
)
echo Using dotnet: %DOTNET_PATH%
echo.

:: ---- Output folder ----
set "OUTPUT_FOLDER=%~dp0Output"
if exist "%OUTPUT_FOLDER%" rmdir /s /q "%OUTPUT_FOLDER%"
mkdir "%OUTPUT_FOLDER%"

:: ---- Menu ----
echo [1] Publish SCS Server Manager (Boot Repair)
echo [2] Publish SCS Launcher
echo [3] Publish BOTH
echo [0] Exit
echo.
set /p choice="Enter choice: "

if "%choice%"=="0" goto :END_OK
if "%choice%"=="1" goto PUBLISH_REPAIR
if "%choice%"=="2" goto PUBLISH_LAUNCHER
if "%choice%"=="3" goto PUBLISH_BOTH
echo Invalid choice. Exiting...
goto :HOLD

:PUBLISH_BOTH
call :PUBLISH_REPAIR
call :PUBLISH_LAUNCHER
goto DONE

:PUBLISH_REPAIR
echo.
echo === Publishing SCS Server Manager (x64 and x86) ===
if not exist "%REPAIR_PROJECT%" (
    echo ERROR: Project file not found at %REPAIR_PROJECT%
    goto :HOLD
)

:: ---- x64 ----
echo   Publishing x64...
"%DOTNET_PATH%" publish "%REPAIR_PROJECT%" -c Release -r win-x64 --self-contained true -o "%OUTPUT_FOLDER%\ServerManager\x64"
if %errorlevel% neq 0 (
    echo ERROR: x64 publish failed.
    goto :HOLD
)
if exist "%OUTPUT_FOLDER%\ServerManager\x64\SCSBootRepair.exe" (
    ren "%OUTPUT_FOLDER%\ServerManager\x64\SCSBootRepair.exe" "SCS Server Manager64.exe"
)

:: ---- x86 ----
echo   Publishing x86...
"%DOTNET_PATH%" publish "%REPAIR_PROJECT%" -c Release -r win-x86 --self-contained true -o "%OUTPUT_FOLDER%\ServerManager\x86"
if %errorlevel% neq 0 (
    echo ERROR: x86 publish failed.
    goto :HOLD
)
if exist "%OUTPUT_FOLDER%\ServerManager\x86\SCSBootRepair.exe" (
    ren "%OUTPUT_FOLDER%\ServerManager\x86\SCSBootRepair.exe" "SCS Server Manager32.exe"
)

echo Done.
goto DONE

:PUBLISH_LAUNCHER
echo.
echo === Publishing SCS Launcher (x64 and x86) ===
if not exist "%LAUNCHER_PROJECT%" (
    echo ERROR: Project file not found at %LAUNCHER_PROJECT%
    goto :HOLD
)

:: ---- x64 ----
echo   Publishing x64...
"%DOTNET_PATH%" publish "%LAUNCHER_PROJECT%" -c Release -r win-x64 --self-contained true -o "%OUTPUT_FOLDER%\Launcher\x64"
if %errorlevel% neq 0 (
    echo ERROR: x64 publish failed.
    goto :HOLD
)
if exist "%OUTPUT_FOLDER%\Launcher\x64\SCSLauncher.exe" (
    ren "%OUTPUT_FOLDER%\Launcher\x64\SCSLauncher.exe" "SCS64.exe"
)

:: ---- x86 ----
echo   Publishing x86...
"%DOTNET_PATH%" publish "%LAUNCHER_PROJECT%" -c Release -r win-x86 --self-contained true -o "%OUTPUT_FOLDER%\Launcher\x86"
if %errorlevel% neq 0 (
    echo ERROR: x86 publish failed.
    goto :HOLD
)
if exist "%OUTPUT_FOLDER%\Launcher\x86\SCSLauncher.exe" (
    ren "%OUTPUT_FOLDER%\Launcher\x86\SCSLauncher.exe" "SCS32.exe"
)

echo Done.
goto DONE

:DONE
echo.
echo ============================================================
echo   PUBLISH COMPLETE
echo ============================================================
echo Output folder: %OUTPUT_FOLDER%
echo.
echo   Server Manager:
echo     - %OUTPUT_FOLDER%\ServerManager\x64\SCS Server Manager64.exe
echo     - %OUTPUT_FOLDER%\ServerManager\x86\SCS Server Manager32.exe
echo.
echo   Launcher:
echo     - %OUTPUT_FOLDER%\Launcher\x64\SCS64.exe
echo     - %OUTPUT_FOLDER%\Launcher\x86\SCS32.exe
echo ============================================================
echo.
echo Copy the EXE files to your USB drive and run them directly.
echo No need to copy to X: - they are self-contained and fast.
echo.
goto :HOLD

:HOLD
echo.
echo Press any key to close this window...
pause < CON

:END_OK
endlocal
exit /b 0