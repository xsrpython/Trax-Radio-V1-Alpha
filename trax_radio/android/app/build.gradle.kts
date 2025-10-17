plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.alphatest.trax_radio"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.alphatest.trax_radio"
        minSdk = 21 // Android 5.0 (API level 21)
        targetSdk = 34 // Android 14
        versionCode = 5
        versionName = "1.0.5"
        
        // Enable multidex for larger apps
        multiDexEnabled = true
        
        // App metadata
        manifestPlaceholders["appName"] = "Trax Radio UK"
    }

    // Ensure APK is properly signed for distribution
    signingConfigs {
        create("release") {
            // Release keystore for Play Store
            storeFile = file("trax-radio-release.jks")
            storePassword = "TraxRadio2025"
            keyAlias = "trax-radio-key"
            keyPassword = "TraxRadio2025"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release") // Using release keystore for Play Store
        }
        debug {
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}
