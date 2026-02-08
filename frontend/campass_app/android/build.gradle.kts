allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Ensure library modules (including plugins in the pub cache) have a namespace
// when they don't declare one. Some plugin versions omit the `namespace` and
// newer Android Gradle Plugin (AGP) requires it. This sets a safe default so
// builds succeed without editing files in the pub cache.
subprojects {
    plugins.withId("com.android.library") {
        try {
            val libExt = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (libExt != null) {
                val currentNs = try { libExt.namespace } catch (t: Throwable) { null }
                if (currentNs == null || currentNs.isBlank()) {
                    libExt.namespace = "com.example.campass_app"
                }
            }
        } catch (e: Throwable) {
            // Defensive: don't fail the build configuration step because of reflection issues.
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
