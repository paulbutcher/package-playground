def main(): Unit \ IO =
    let mavenSession = Maven.init();
    let config = Config.init();

    let classpath = Config.getDependencies(config) |>
        Config.getMavenDependencies |>
        Maven.resolveTransitiveDependencies(mavenSession);
    println(classpath)