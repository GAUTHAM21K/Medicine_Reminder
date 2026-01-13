@echo off
echo Creating keystore for medicine reminder app...
echo.
echo This will create a keystore file for signing your APK.
echo You'll need to provide a password and some basic information.
echo.

keytool -genkey -v -keystore medicine-reminder-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias medicine-reminder

echo.
echo Keystore created successfully!
echo.
echo Next steps:
echo 1. Create android/key.properties file with your keystore details
echo 2. Update android/app/build.gradle.kts to use the keystore
echo 3. Rebuild your APK with proper signing
echo.
pause