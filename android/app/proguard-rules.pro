# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive specific rules
-keep class * extends io.flutter.plugins.** { *; }
-keep class com.example.medicine_reminder.** { *; }

# Notification plugin rules
-keep class com.dexterous.** { *; }

# Permission handler rules
-keep class com.baseflow.** { *; }

# General Android rules
-dontwarn java.lang.invoke.**
-dontwarn **$$serializer
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt