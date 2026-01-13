# APK Compatibility Guide

## Fixed Compatibility Issues

### 1. **Minimum SDK Version**
- Set explicit `minSdk = 21` (Android 5.0+) for broader device support
- Updated `compileSdk = 36` to support latest plugin requirements

### 2. **Architecture Support**
- Removed conflicting NDK filters when using split APKs
- Built separate APKs for different architectures for optimal compatibility

### 3. **Build Configuration**
- Fixed deprecated Gradle options (`enableR8`, `packagingOptions`)
- Updated to modern Kotlin DSL syntax
- Added proper ProGuard rules to prevent obfuscation issues

### 4. **Permissions**
- Cleaned up Android manifest permissions
- Ensured compatibility with both old and new Android versions

## Available APK Files

### Split APKs (Recommended for specific devices):
1. **app-armeabi-v7a-release.apk** (16.8MB)
   - For older 32-bit ARM devices (Android 5.0+)
   - **Best compatibility for older phones**

2. **app-arm64-v8a-release.apk** (19.2MB)
   - For newer 64-bit ARM devices (Android 7.0+)
   - Most modern smartphones

3. **app-x86_64-release.apk** (20.5MB)
   - For x86 devices and emulators

### Universal APK:
4. **app-release.apk** (49.9MB)
   - Works on ALL Android devices
   - Larger file size but maximum compatibility

## Installation Recommendations

### For Maximum Compatibility:
Use `app-armeabi-v7a-release.apk` - this works on the widest range of devices including older phones.

### For Modern Devices:
Use `app-arm64-v8a-release.apk` - optimized for newer smartphones.

### If Unsure:
Use `app-release.apk` - universal APK that works everywhere but is larger.

## Build Scripts

Two batch files are provided for easy building:

1. **build_compatible_apk.bat** - Builds split APKs for different architectures
2. **build_universal_apk.bat** - Builds universal APK

## Troubleshooting

If you still get "App not compatible" errors:

1. **Check Android Version**: App requires Android 5.0+ (API 21)
2. **Try Different APK**: Use the universal APK if split APKs don't work
3. **Enable Unknown Sources**: Allow installation from unknown sources in device settings
4. **Clear Cache**: Clear Google Play Store cache if installing from there

## Technical Details

- **Minimum Android**: 5.0 (API 21)
- **Target Android**: 14 (API 34)
- **Compile SDK**: 36
- **Architecture Support**: ARM 32-bit, ARM 64-bit, x86_64
- **Signing**: Debug signing (for development)