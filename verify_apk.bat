@echo off
echo Verifying APK integrity...
echo.

set APK_PATH=build\app\outputs\flutter-apk\app-release.apk

if not exist "%APK_PATH%" (
    echo APK file not found at %APK_PATH%
    echo Please build the APK first using: flutter build apk
    pause
    exit /b 1
)

echo Checking APK file size...
for %%A in ("%APK_PATH%") do echo File size: %%~zA bytes

echo.
echo Checking APK structure...
aapt dump badging "%APK_PATH%" 2>nul
if %errorlevel% neq 0 (
    echo Warning: aapt not found in PATH. Cannot verify APK structure.
    echo Make sure Android SDK build-tools are in your PATH.
) else (
    echo APK structure looks valid!
)

echo.
echo Checking if APK is signed...
jarsigner -verify -verbose -certs "%APK_PATH%" 2>nul
if %errorlevel% neq 0 (
    echo Warning: Could not verify APK signature.
    echo This might be why the APK appears invalid.
) else (
    echo APK is properly signed!
)

echo.
echo APK verification complete.
pause