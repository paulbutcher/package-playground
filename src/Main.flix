def main(): Unit \ IO =
    let mavenSession = Maven.init();

    Dependencies.getMavenDependencies() |>
        Maven.resolveTransitiveDependencies(mavenSession)
