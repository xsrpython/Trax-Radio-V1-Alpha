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
        versionCode = 1
        versionName = "1.0.0"
        
        // Enable multidex for larger apps
        multiDexEnabled = true
        
        // App metadata
        manifestPlaceholders["appName"] = "Trax Radio UK"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug") // Change to "release" for Play Store
        }
        debug {
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Ensure APK is properly signed for distribution
    signingConfigs {
        create("release") {
            // For Play Store, you need to create a proper release keystore
            // TODO: Create release keystore when ready for Play Store
            // storeFile = file("release-keystore.jks")
            // storePassword = "your-store-password"
            // keyAlias = "your-key-alias"
            // keyPassword = "your-key-password"
            
            // For now, using debug signing (change this for Play Store)
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
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
