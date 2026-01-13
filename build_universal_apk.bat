@echo off
echo Building universal APK for medicine reminder app...

echo Cleaning previous builds...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo Building universal APK (larger but works on all devices)...
call flutter build apk

echo Build complete! Universal APK is in build\app\outputs\flutter-apk\app-release.apk
echo.
echo This APK will work on all Android devices but will be larger in size.
pause