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
// Google platformalarni endi kichik versiya bilan chiqaradi: `android-37`
// degan paket yo'q, faqat `android-37.0`. flutter_secure_storage esa butun
// son so'raydi (compileSdk = 37) va build "Failed to find target with hash
// string 'android-37'" deb to'xtaydi. Plaginga kichik versiyani o'zimiz
// aytamiz — plagin yangilanguncha shu yerda turadi.
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android") ?: return@afterEvaluate
        android.withGroovyBuilder {
            if (getProperty("compileSdk") == 37 && getProperty("compileSdkMinor") == null) {
                setProperty("compileSdkMinor", 0)
            }
        }

        // MapKit'ning AAR'i Java 21 bilan qurilgan; plaginlar esa hamon
        // Java 11/17 ni ko'rsatadi va "class file has wrong version 65.0"
        // deb to'xtaydi. Hammasini bir darajaga keltiramiz — Java ham,
        // Kotlin ham, aks holda AGP ikkalasi mos emasligidan shikoyat qiladi.
        android.withGroovyBuilder {
            getProperty("compileOptions").withGroovyBuilder {
                setProperty("sourceCompatibility", JavaVersion.VERSION_21)
                setProperty("targetCompatibility", JavaVersion.VERSION_21)
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
