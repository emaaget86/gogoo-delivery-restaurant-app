pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.1" apply false
    id("org.jetbrains.kotlin.android") version "2.4.10" apply false
    id("com.google.gms.google-services") version "4.4.1" apply false
}

include(":app")

// flutter_inappwebview_android 1.1.3 is the newest stable release and still calls
// getDefaultProguardFile("proguard-android.txt"). AGP 9 rejects that file.
// No stable plugin release has switched to proguard-android-optimize.txt, so each
// Gradle configuration rewrites that one call in the resolved plugin. Custom rules
// in proguard-rules.pro are left unchanged. A clean CI checkout still builds because
// this script is in the repository and runs after `flutter pub get`.
fun patchFlutterInAppWebViewProguard() {
    val pluginsFile = file("../.flutter-plugins-dependencies")
    if (!pluginsFile.isFile) {
        return
    }

    val parsed = groovy.json.JsonSlurper().parse(pluginsFile)
    if (parsed !is Map<*, *>) {
        return
    }
    val androidPlugins = (parsed["plugins"] as? Map<*, *>)?.get("android") as? List<*> ?: return
    val legacyCall = "getDefaultProguardFile('proguard-android.txt')"
    val legacyCallDoubleQuoted = "getDefaultProguardFile(\"proguard-android.txt\")"
    val optimizedCall = "getDefaultProguardFile('proguard-android-optimize.txt')"

    for (entry in androidPlugins) {
        val plugin = entry as? Map<*, *> ?: continue
        if (plugin["name"] != "flutter_inappwebview_android") {
            continue
        }
        val pluginPath = plugin["path"]?.toString() ?: continue
        val buildGradle = file(pluginPath).resolve("android/build.gradle")
        if (!buildGradle.isFile) {
            continue
        }
        val original = buildGradle.readText()
        if (!original.contains(legacyCall) && !original.contains(legacyCallDoubleQuoted)) {
            continue
        }
        buildGradle.writeText(
            original
                .replace(legacyCall, optimizedCall)
                .replace(legacyCallDoubleQuoted, optimizedCall)
        )
    }
}

patchFlutterInAppWebViewProguard()