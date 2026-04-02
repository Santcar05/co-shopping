allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // 1. Configuración de Directorios
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    project.evaluationDependsOn(":app")

    // 2. Corrección de Namespace para AGP 8+ (Configuración inmediata)
    plugins.withType<com.android.build.gradle.api.AndroidBasePlugin> {
        extensions.configure<com.android.build.gradle.BaseExtension> {
            if (namespace == null) {
                namespace = "co.shopping.${project.name.replace("-", ".")}"
            }
        }
    }

    // 3. Parche para Isar/Manifests (Sin afterEvaluate)
    // Usamos el hook de tareas directamente
    tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
        doFirst {
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val content = manifestFile.readText()
                if (content.contains("package=")) {
                    val updatedContent = content.replace(Regex("package=\"[^\"]*\""), "")
                    manifestFile.writeText(updatedContent)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}