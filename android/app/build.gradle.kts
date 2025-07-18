/*
 * android/app/build.gradle.kts
 * Kotlin-DSL version of the Gradle script for your Flutter module.
 * This file configures the Android specific settings for your Flutter application.
 */

plugins {
    // Apply the Android Application plugin for building Android apps.
    id("com.android.application")
    // Apply the Google Services plugin for Firebase integration (e.g., FCM, Analytics).
    id("com.google.gms.google-services")
    // Apply the Kotlin Android plugin for Kotlin language support.
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied last to correctly configure Flutter-specific tasks.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Defines the unique application ID for your Android app.
    namespace = "com.mediora.doctor"

    // Specifies the Android API level to compile against, pulled from Flutter configuration.
    compileSdk = flutter.compileSdkVersion
    // Specifies the NDK (Native Development Kit) version to use for native code compilation.
    ndkVersion = "27.0.12077973"

    // Configures Java compiler options.
    compileOptions {
        // Sets the source and target compatibility to Java 11.
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // Enables Java 8+ APIs (like java.time) on older Android versions (API < 26)
        // by desugaring them at compile time. This requires the desugar_jdk_libs dependency.
        isCoreLibraryDesugaringEnabled = true
    }

    // Configures Kotlin compiler options.
    kotlinOptions {
        // Sets the JVM target version for Kotlin compilation to Java 11.
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Configures default settings for all build variants.
    defaultConfig {
        // The unique application ID, which should match the namespace.
        applicationId = "com.mediora.doctor"
        // Specifies the minimum Android API level required to run the app, pulled from Flutter config.
        minSdk = flutter.minSdkVersion
        // Specifies the target Android API level, pulled from Flutter config.
        targetSdk = flutter.targetSdkVersion
        // Defines the version code for the app, used for internal versioning, pulled from Flutter config.
        versionCode = flutter.versionCode
        // Defines the user-visible version name for the app, pulled from Flutter config.
        versionName = flutter.versionName
        // Enables multidex support, allowing your app to exceed the 65k method limit.
        multiDexEnabled = true
    }

    // Configures different build types (e.g., debug, release).
    buildTypes {
        release {
            // For development purposes, using the debug signing config allows `flutter run --release` to work.
            // In a production setup, you would replace this with your actual release signing config.
            signingConfig = signingConfigs.getByName("debug")
            // Enables R8/ProGuard for code shrinking and optimization in release builds.
            isMinifyEnabled = true
            // Enables resource shrinking, removing unused resources.
            isShrinkResources = true
            // Specifies ProGuard rules files for code obfuscation and shrinking.
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

// Defines project dependencies.
dependencies {
    // Required for core library desugaring (enables Java 8+ APIs on older Android versions).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Imports the Firebase Bill of Materials (BOM) to manage Firebase library versions.
    // This ensures all Firebase libraries use compatible versions.
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    // Add specific Firebase SDKs here as needed, e.g.:
    // implementation("com.google.firebase:firebase-analytics-ktx")
    // implementation("com.google.firebase:firebase-messaging-ktx")

    // IMPORTANT: Adds the Google Play Core Library, which contains classes for dynamic features,
    // in-app updates, and other Play Store related functionalities.
    // This resolves the "Missing class com.google.android.play.core.splitcompat.SplitCompatApplication"
    // and other related R8 errors.
    implementation("com.google.android.play:core:1.10.3")
}

// Configures the Flutter module within the Android project.
flutter {
    // Specifies the path to the root of your Flutter project.
    source = "../.."
}
