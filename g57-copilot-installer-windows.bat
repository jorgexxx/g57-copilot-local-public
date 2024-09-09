@echo off
setlocal enabledelayedexpansion

:: Get the directory of the script
set "SCRIPT_DIR=%~dp0"

:: Define the installation directory
set "INSTALL_DIR=%USERPROFILE%\g57-local-assistant-be"

:: Define the program folder
set "PROGRAM_FOLDER=%SCRIPT_DIR%g57-program-files"
set "FILE_EXECUTE_PROGRAM=g57-copilot-local.bat"

:: Define the ZIP file
set "ZIP_FILE=g57-local-assistant-be-release.zip"

# Define the URL
set "URL_TO_DOWNLOAD_APP=https://github.com/jorgexxx/g57-copilot-local-public/raw/master/g57-local-assistant-be-release.zip"

:: Delete previous files
echo Deleting previous files...
if exist "%INSTALL_DIR%" (
    rmdir /S /Q "%INSTALL_DIR%"
)
if exist "%ZIP_FILE%" (
    del "%ZIP_FILE%"
)

:: Stop current processes on port 30101
echo "Stopping current processes on port 30101..." 
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :30101') do taskkill /PID %%a /F

:: Dowload ZIP file 
powershell -Command "Invoke-WebRequest -Uri '%URL_TO_DOWNLOAD_APP%' -OutFile '%ZIP_FILE%'"
echo Download completed.

::Unzip the ZIP
echo Decompressing the ZIP file...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%USERPROFILE%' -Force"
echo Decompression completed.

:: Check if the program folder exists
if not exist "%PROGRAM_FOLDER%" (
    echo Error: The folder "%PROGRAM_FOLDER%" does not exist.
    echo Please make sure the "g57-program-files" folder is in the same directory as this script.
    goto :error
)

:: Create the installation directory (if it doesn't exist)
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Copy files to the installation directory
echo Copying files to %INSTALL_DIR%...
xcopy /E /I /Y "%PROGRAM_FOLDER%\*" "%INSTALL_DIR%" 2>nul
if errorlevel 1 (
    echo Warning: Some files could not be copied. The source folder might be empty.
)

:: Copy .env.pro file separately
if exist "%PROGRAM_FOLDER%\.env.pro" (
    copy /Y "%PROGRAM_FOLDER%\.env.pro" "%INSTALL_DIR%" >nul
    echo Copied .env.pro file.
) else (
    echo Warning: .env.pro file not found in the source folder.
)

:: Get the correct path to the Desktop folder using PowerShell
for /f "usebackq delims=" %%a in (`powershell -command "[Environment]::GetFolderPath('Desktop')"`) do set "DESKTOP_PATH=%%a"

:: Create the desktop shortcut script
set "DESKTOP_SCRIPT=%DESKTOP_PATH%\%FILE_EXECUTE_PROGRAM%"
(
echo @echo off
echo.
echo :: Get the directory of this script
echo set "SCRIPT_DIR=%%~dp0"
echo.
echo :: Load nvm
echo call %%USERPROFILE%%\AppData\Roaming\nvm\nvm.exe

echo.
echo :: Run the backend
echo cd /d "!INSTALL_DIR!" ^&^& npm run pro
echo.
echo :: Keep the command prompt window open
echo pause
) > "!DESKTOP_SCRIPT!"

:: Copy "DESKTOP_SCRIPT" file to the same location as "install.bat" as well.
copy /Y "!DESKTOP_SCRIPT!" "%SCRIPT_DIR%%FILE_EXECUTE_PROGRAM%" >nul

echo Installation completed. You can run the backend by double-clicking the '%FILE_EXECUTE_PROGRAM%' script on your desktop.
goto :end

:error
echo Installation failed.

:end
:: Keep the command prompt window open
pause