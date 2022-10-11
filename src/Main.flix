use Toml.{readConfigFile, getSubConfig, getEntries}
use Maven.findAvailableVersions

def main(): Unit \ IO =
    println(readConfigFile("FlixProject.toml") |>
        getSubConfig("dependencies") |>
        getEntries);
    println(findAvailableVersions("org.apache.maven.resolver:maven-resolver-util:[0,)"))