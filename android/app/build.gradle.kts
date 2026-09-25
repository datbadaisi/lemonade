import java.io.File
import java.util.Properties
import com.android.build.api.dsl.ApplicationExtension

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

// Prefer env vars (CI). Fallback: android/key.properties (local; gitignored).
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties().apply {
    if (keyPropertiesFile.exists()) {
        keyPropertiesFile.inputStream().use { load(it) }
    }
}

fun releaseProp(envName: String, propName: String): String? =
    System.getenv(envName)?.takeIf { it.isNotBlank() }
        ?: keyProperties.getProperty(propName)?.takeIf { it.isNotBlank() }

val releaseKeystorePath = releaseProp("BLUERUM_KEYSTORE_PATH", "storeFile")
val releaseKeystorePassword = releaseProp("BLUERUM_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = releaseProp("BLUERUM_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = releaseProp("BLUERUM_KEY_PASSWORD", "keyPassword")
val hasReleaseSigning = listOf(
    releaseKeystorePath,
    releaseKeystorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }
val requestsReleaseBuild = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

extensions.configure<ApplicationExtension> {
    namespace = "com.thezello.lemonade"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.thezello.lemonade"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                // storeFile: absolute path, or relative to android/ (rootProject).
                // Do not use project.file() for the absolute check — Gradle always
                // resolves relative paths against :app, which is wrong here.
                val path = releaseKeystorePath!!
                val asJava = File(path)
                storeFile = if (asJava.isAbsolute) {
                    asJava
                } else {
                    rootProject.file(path)
                }
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (requestsReleaseBuild) {
                check(hasReleaseSigning) {
                    "Release signing requires either env vars " +
                        "BLUERUM_KEYSTORE_PATH, BLUERUM_KEYSTORE_PASSWORD, " +
                        "BLUERUM_KEY_ALIAS, BLUERUM_KEY_PASSWORD — or " +
                        "android/key.properties (see key.properties.example)."
                }
            }
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
