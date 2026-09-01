@echo off
echo ========================================================
echo        Building Burn Think Windows Release Executable
echo ========================================================
echo.

cd /d "%~dp0"

echo [1/2] Checking Flutter environment...
call flutter doctor

echo.
echo [2/2] Building Windows Release EXE...
call flutter build windows --release

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================================
    echo  BUILD FAILED!
    echo.
    echo  If Visual Studio C++ is missing, please run:
    echo  vs_BuildTools.exe
    echo  and check "Desktop development with C++" workload.
    echo ========================================================
    echo.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================================
echo  BUILD SUCCEEDED!
echo  Executable location:
echo  %~dp0build\windows\x64\runner\Release\burn_think.exe
echo ========================================================
echo.

if exist "%~dp0build\windows\x64\runner\Release" (
    explorer "%~dp0build\windows\x64\runner\Release"
) else if exist "%~dp0build\windows\runner\Release" (
    explorer "%~dp0build\windows\runner\Release"
)

pause
