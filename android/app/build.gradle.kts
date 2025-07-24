import java.util.Properties
import java.io.FileInputStream

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

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.legozia.mediora"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.legozia.mediora"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
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

    // Adds the Google Play Core Library, which contains classes for dynamic features,
    // in-app updates, and other Play Store related functionalities.
    implementation("com.google.android.play:app-update-ktx:2.1.0") // or latest
}

// Configures the Flutter module within the Android project.
flutter {
    // Specifies the path to the root of your Flutter project.
    source = "../.."
}
