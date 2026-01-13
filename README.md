# Medicine Reminder App 💊

A comprehensive Flutter-based medicine reminder application that helps users manage their medication schedules with smart notifications, intuitive timeline interface, and robust local storage.

## 📱 Features

### Core Functionality
- **Smart Medicine Scheduling**: Add medicines with custom names, dosages, and precise timing
- **Interactive Timeline View**: Visual timeline showing all scheduled medicines sorted by time
- **Next Dose Highlighting**: Automatically highlights the next medicine due with distinctive orange styling
- **Overdue Detection**: Visual indicators for missed medicines with red accent colors
- **Medicine Status Tracking**: Mark medicines as taken, skipped, or missed with visual feedback

### Advanced Features
- **Snooze Functionality**: Temporarily delay medicine reminders with custom durations
- **Permission Management**: Smart permission handling for notifications with user-friendly prompts
- **Persistent Notifications**: High-priority notifications that work even when app is closed
- **Local Data Storage**: Offline-first approach using Hive database for reliable data persistence
- **State Management**: Robust state management using Riverpod for reactive UI updates

### User Experience
- **Custom App Icon**: Professionally designed app icon included in assets
- **Material Design 3**: Modern UI following Material Design 3 principles
- **Responsive Design**: Optimized for various screen sizes and orientations
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Loading States**: Smooth loading indicators for better user experience

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── theme/           # App theming and colors
│   └── utils/           # Utility classes and constants
├── features/
│   └── medicine/
│       ├── data/
│       │   ├── models/      # Data models with Hive annotations
│       │   └── repositories/ # Data access layer
│       └── presentation/
│           ├── providers/   # Riverpod state management
│           ├── screens/     # UI screens
│           └── widgets/     # Reusable UI components
└── services/            # Platform services (notifications, permissions)
```

## 🛠️ Tech Stack

### Framework & Language
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language (SDK >=3.0.0)

### State Management
- **Riverpod**: Modern state management solution for reactive programming

### Local Storage
- **Hive**: Fast, lightweight NoSQL database for Flutter
- **Hive Generator**: Code generation for type-safe data models

### Notifications & Permissions
- **Flutter Local Notifications**: High-priority local notifications
- **Permission Handler**: Runtime permission management
- **Timezone**: Accurate timezone handling for scheduled notifications

### UI & Utilities
- **Material Design 3**: Modern UI components
- **Intl**: Internationalization and date formatting
- **UUID**: Unique identifier generation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd medicine_reminder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code for Hive models**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Generate app icons**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Key Components

### Models
- **MedicineModel**: Core data model with Hive annotations for local storage
  - Unique ID generation using UUID
  - Medicine name, dosage, and scheduled time
  - Status tracking (taken, skipped, snoozed)
  - Timestamp tracking for taken/snoozed medicines

### Screens
- **HomeScreen**: Main dashboard with timeline view and permission management
- **AddMedicineScreen**: Form for adding new medicine reminders with time picker

### Widgets
- **MedicineTimelineTile**: Interactive timeline item with status management
- **TimeSliderPicker**: Custom time selection widget
- **MedicineDetailsPopup**: Detailed view popup for medicine information

### Services
- **NotificationService**: High-priority notification scheduling and management
- **PermissionService**: User-friendly permission request handling
- **AlarmManagerService**: Wrapper service for notification-based alarms

## 🎨 Design System

### Color Palette
- **Primary Teal**: `#008080` - Main brand color
- **Accent Orange**: `#FF8C00` - Action buttons and highlights
- **Surface Grey**: `#F5F5F5` - Background surfaces

### Typography
- Material Design 3 typography scale
- Custom font weights for hierarchy
- Consistent sizing across components

## 🔧 Configuration

### App Icon
The app includes a custom icon located at `assets/icon/app_icon.png` with:
- Adaptive icon support for Android
- iOS icon generation
- Consistent branding across platforms

### Notifications
- High-priority notification channel for Android
- Full-screen intent support for critical reminders
- iOS notification permissions with sound and badge support

## 📱 Platform Support

- **Android**: Full support with adaptive icons and high-priority notifications
- **iOS**: Complete iOS integration with native notification handling
- **Cross-platform**: Shared codebase with platform-specific optimizations

## 🧪 Testing

The app includes comprehensive testing setup:
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for complete user flows

Run tests with:
```bash
flutter test
```

## 📦 Build & Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Hive for fast local storage
- Material Design team for design guidelines

---

**Built with ❤️ using Flutter**