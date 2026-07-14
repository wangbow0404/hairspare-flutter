plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "kr.co.hairspare.app"
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
        applicationId = "kr.co.hairspare.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // google_sign_in Android fallback (Dart serverClientId 가 우선).
        val googleStrings = file("src/main/res/values/google_strings.xml")
        if (googleStrings.exists()) {
            val content = googleStrings.readText()
            val match = Regex(
                "<string name=\"google_web_client_id\">([^<]+)</string>"
            ).find(content)
            val webClientId = match?.groupValues?.getOrNull(1)?.trim().orEmpty()
            if (webClientId.isNotEmpty() && !webClientId.startsWith("YOUR_")) {
                resValue("string", "default_web_client_id", webClientId)
            }
        }
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
