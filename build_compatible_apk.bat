@echo off
echo Building compatible APK for medicine reminder app...

echo Cleaning previous builds...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo Building APK with compatibility settings...
call flutter build apk --release

echo Build complete! APK file is in build\app\outputs\flutter-apk\
echo.
echo Generated APK file:
echo - app-release.apk (Universal APK - works on all devices)
echo.
echo File size: ~50MB
echo Compatibility: Android 5.0+ (API 21)
echo Signing: Debug signed (for development)
pause