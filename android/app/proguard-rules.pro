# --- Firebase ---
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# --- Flutter local notifications (optional) ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# --- Prevent removal of required Flutter plugins (optional safety) ---
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }

# --- Kotlin coroutines support ---
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# --- Prevent obfuscation of your model classes if used via reflection ---
-keep class com.mediora.doctor.models.** { *; }

