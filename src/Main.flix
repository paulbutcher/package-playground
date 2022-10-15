use Toml.{readConfigFile, getSubConfig, getEntries}

def main(): Unit \ IO =
    let mavenSession = Maven.init();

    println(readConfigFile("FlixProject.toml") |>
        getSubConfig("dependencies") |>
        getEntries);

    Maven.resolveTransitiveDependencies("org.apache.maven.resolver:maven-resolver-impl:1.3.3" :: Nil, mavenSession)
