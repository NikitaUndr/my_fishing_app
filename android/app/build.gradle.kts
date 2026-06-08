plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.fishing_app2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // Правильный синтаксис sourceSets в Kotlin DSL
    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/java", "src/main/kotlin")
            kotlin.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.example.fishing_app2"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.yandex.android:maps.mobile:4.6.1-full")  // Зависимость Яндекс.Карт
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}