plugins {
    kotlin("jvm") version "2.0.0"
    id("com.github.johnrengelman.shadow") version ("8.1.1")
}

group = "ru.leadpogrommer.verilator_component"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    compileOnly(fileTree("libs"))

    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}
kotlin {
    jvmToolchain(22)
}

tasks.withType<Jar> {
    manifest {
        attributes["Library-Class"] = "ru.leadpogrommer.verilator_component.Components"
    }
}