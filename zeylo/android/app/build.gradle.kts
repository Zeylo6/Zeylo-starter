plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.zeylo.zeylo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zeylo.zeylo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// #region agent log
afterEvaluate {
    val logFile = rootProject.file("../../debug-348ac8.log")
    logFile.parentFile.mkdirs()
    logFile.appendText(
        """{"sessionId":"348ac8","runId":"pre-fix","hypothesisId":"H1","location":"zeylo/android/app/build.gradle.kts","message":"compileOptions","data":{"coreLibraryDesugaringEnabled":"${android.compileOptions.isCoreLibraryDesugaringEnabled}","minSdk":"${android.defaultConfig.minSdk}"},"timestamp":${System.currentTimeMillis()}}""" + "\n"
    )
}
// #endregion

// #region agent log
tasks.matching { it.name == "checkDebugAarMetadata" }.configureEach {
    doFirst {
        val logFile = rootProject.file("../../debug-348ac8.log")
        logFile.parentFile.mkdirs()
        logFile.appendText(
            """{"sessionId":"348ac8","runId":"pre-fix","hypothesisId":"H2","location":"zeylo/android/app/build.gradle.kts","message":"checkDebugAarMetadataTask","data":{"taskClass":"${this::class.qualifiedName}","coreLibraryDesugaringEnabled":"${android.compileOptions.isCoreLibraryDesugaringEnabled}","minSdk":"${android.defaultConfig.minSdk}"},"timestamp":${System.currentTimeMillis()}}""" + "\n"
        )
    }
}
// #endregion
