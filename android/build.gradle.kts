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
    // Windows 크로스 드라이브 문제 방지: 같은 루트(드라이브)인 경우에만 빌드 디렉토리 리다이렉트
    val newRoot = newSubprojectBuildDir.asFile.toPath().root
    val projectRoot = project.projectDir.toPath().root
    if (newRoot == projectRoot) {
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
