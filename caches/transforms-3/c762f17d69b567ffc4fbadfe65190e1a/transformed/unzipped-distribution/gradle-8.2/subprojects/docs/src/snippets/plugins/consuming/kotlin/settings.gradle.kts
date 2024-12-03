// tag::custom-plugin-repositories[]
pluginManagement {
    repositories {
        maven(url = "./maven-repo")
        gradlePluginPortal()
        ivy(url = "./ivy-repo")
    }
}
// end::custom-plugin-repositories[]

rootProject.name = "custom-repositories"
