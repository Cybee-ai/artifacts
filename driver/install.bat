@echo off 
echo ================================================ 
echo Installing Cybee EDR Driver - Phase 4 
echo Improved Error Handling and Cleanup 
echo ================================================ 
 
REM Install the certificate
echo Installing certificate...
if not exist "cybeerd.cer" (
    echo Error: Certificate file not found
    exit /b 1
)
certutil -addstore root "cybeerd.cer"
if errorlevel 1 (
    echo Failed to install certificate
    exit /b 1
)

REM Stop and remove existing service if it exists
sc query cybeerd >nul 2>&1
if not errorlevel 1 (
    echo Stopping existing service...
    sc stop cybeerd >nul 2>&1
    timeout /t 2 /nobreak >nul
    sc delete cybeerd >nul 2>&1
    timeout /t 2 /nobreak >nul
)

REM Copy driver files
echo Copying driver files...
if not exist "cybeerd.sys" (
    echo Error: Driver file not found
    exit /b 1
)
copy "cybeerd.sys" "%windir%\System32\drivers\" /y
if errorlevel 1 (
    echo Failed to copy driver file
    exit /b 1
)

REM Create registry entries for minifilter
echo Creating registry entries...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\cybeerd\Instances" /v "DefaultInstance" /t REG_SZ /d "cybeerd Instance" /f >nul
if errorlevel 1 (
    echo Failed to create registry entry for DefaultInstance
    exit /b 1
)

reg add "HKLM\SYSTEM\CurrentControlSet\Services\cybeerd\Instances\cybeerd Instance" /v "Altitude" /t REG_SZ /d "371000" /f >nul
if errorlevel 1 (
    echo Failed to create registry entry for Altitude
    exit /b 1
)

reg add "HKLM\SYSTEM\CurrentControlSet\Services\cybeerd\Instances\cybeerd Instance" /v "Flags" /t REG_DWORD /d "0" /f >nul
if errorlevel 1 (
    echo Failed to create registry entry for Flags
    exit /b 1
)

REM Create the service with proper group and dependencies
echo Creating service...
sc create cybeerd type= kernel binPath= System32\drivers\cybeerd.sys start= demand group= "FSFilter Activity Monitor" depend= FltMgr
if errorlevel 1 (
    echo Failed to create service
    exit /b 1
)

REM Start the service
echo Starting service...
sc start cybeerd
if errorlevel 1 (
    echo Failed to start service
    sc query cybeerd
    exit /b 1
)

echo.
echo Installation complete. Check service status:
sc query cybeerd

REM Wait a moment to ensure driver is fully initialized
timeout /t 2 /nobreak >nul
