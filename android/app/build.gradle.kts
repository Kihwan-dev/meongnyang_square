plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.meongnyang_square"

    // ★ 플러그인들이 35 요구 → 35로 고정
    compileSdk = 35

    // ★ 플러그인들이 NDK 27 요구 → 문자열로 명시 고정
    ndkVersion = "27.0.12077973"

    compileOptions {
        // 라이브러리 디저가 사용
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.meongnyang_square"
        minSdk = 23

        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ★ flutter_local_notifications가 2.1.4+ 요구 → 2.1.5로
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    implementation("androidx.window:window:1.2.0")
    implementation("androidx.window:window-java:1.2.0")
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}

kotlin {
    jvmToolchain(17)
}
