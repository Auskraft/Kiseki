plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.auskraft.kiseki"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.auskraft.kiseki"
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

    // Вендоренный libsqlite3.so (FTS5) лежит в src/main/jniLibs/<abi>/ — штатный
    // android-бандл нативной либы. Нужно потому, что native-asset из
    // `source: test-sqlite3` в APK НЕ попадает (тот режим для хост-тестов), и без
    // этого `dlopen('libsqlite3.so')` падает на устройстве. pickFirsts — защита от
    // дубля, если native-asset всё же принесёт свой: это тот же релизный бинарь.
    packaging {
        jniLibs {
            pickFirsts.add("**/libsqlite3.so")
        }
    }
}

flutter {
    source = "../.."
}
