import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// AGP 8+: legacy plugins without `namespace` (e.g. flutter_naver_login 1.x).
subprojects {
    afterEvaluate {
        extensions.findByType(LibraryExtension::class.java)?.let { androidExt ->
            if (androidExt.namespace.isNullOrBlank()) {
                androidExt.namespace = project.group.toString()
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
