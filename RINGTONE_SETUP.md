# Adding Custom Ringtones to Medicine Reminder

## Quick Setup Guide

### 1. Add Sound Files

**For Android:**
- Place your sound file in: `android/app/src/main/res/raw/medicine_reminder.mp3`
- **Important**: Remove the file extension when placing in the raw folder (just `medicine_reminder`)

**For iOS:**
- Place your sound file in: `assets/sounds/medicine_reminder.mp3`

### 2. File Requirements

- **Duration**: Under 30 seconds (iOS requirement)
- **Format**: MP3, WAV, or CAF for iOS; MP3, WAV, or OGG for Android
- **Size**: Under 1MB for better performance
- **Quality**: 16-bit, mono or stereo, up to 48kHz sample rate

### 3. Available Sound Options

The app now includes a sound selector with these options:
- Default (medicine_reminder.mp3)
- Gentle Bell (gentle_bell.mp3)
- Alarm Clock (alarm_clock.mp3)
- Chime (chime.mp3)
- Notification (notification.mp3)

### 4. Implementation Details

The notification service has been updated to support custom sounds:

```dart
// The repository now automatically schedules notifications with custom sounds
await medicineNotifier.addMedicine(medicine, customSound: 'gentle_bell.mp3');
```

### 5. File Structure

```
your_project/
├── assets/sounds/
│   ├── medicine_reminder.mp3
│   ├── gentle_bell.mp3
│   ├── alarm_clock.mp3
│   ├── chime.mp3
│   └── notification.mp3
└── android/app/src/main/res/raw/
    ├── medicine_reminder (no extension)
    ├── gentle_bell (no extension)
    ├── alarm_clock (no extension)
    ├── chime (no extension)
    └── notification (no extension)
```

### 6. Testing Steps

1. Add your sound files to both directories
2. Run `flutter clean && flutter pub get`
3. Rebuild your app: `flutter run`
4. Create a new medicine reminder
5. Select a custom sound from the dropdown
6. Save the reminder and wait for the notification

### 7. Troubleshooting

**Sound doesn't play on Android:**
- Verify the file is in `android/app/src/main/res/raw/` without extension
- Check file format (MP3, WAV, OGG supported)
- Ensure file size is under 1MB

**Sound doesn't play on iOS:**
- Verify the file is listed in `pubspec.yaml` under assets
- Check file format (MP3, WAV, CAF supported)
- Ensure duration is under 30 seconds

**App crashes when scheduling notification:**
- Check that the sound file exists in the correct location
- Verify file format compatibility
- Check app permissions for notifications

### 8. Finding Sound Files

You can find free notification sounds at:
- Freesound.org
- Zapsplat.com (free with registration)
- YouTube Audio Library
- Or record your own using any audio recording app

Remember to respect copyright and licensing when using sound files.