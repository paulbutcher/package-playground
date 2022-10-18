def main(): Unit \ IO =
    let mavenSession = Maven.init();
    let config = Config.init();

    let _classpath = Config.getDependencies(config) |>
        Config.getMavenDependencies |>
        Maven.resolveTransitiveDependencies(mavenSession);

    let flixVersion = Config.getFlixVersion(config);
    let flixJar = Maven.resolveArtifact(mavenSession,
        "com.paulbutcher:flix:${flixVersion}");

    Compiler.run(flixJar)
