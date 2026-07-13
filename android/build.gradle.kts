buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 이 부분이 있어야 google-services.json을 읽어올 수 있습니다.
        classpath("com.android.tools.build:gradle:8.2.1") // 사용 중인 버전 확인 필요
        classpath("com.google.gms:google-services:4.4.1") 
    }
}

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
