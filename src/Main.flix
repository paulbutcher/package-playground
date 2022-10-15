use Toml.{readConfigFile, getSubConfig, getEntries}

def main(): Unit \ IO =
    let mavenSession = Maven.init();

    println(readConfigFile("FlixProject.toml") |>
        getSubConfig("dependencies") |>
        getEntries);

    let versions = Maven.findAvailableVersions("org.apache.maven.resolver:maven-resolver-util:[0,)", mavenSession);
    println(versions)
