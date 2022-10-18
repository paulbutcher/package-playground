def main(): Unit \ IO =
    let mavenSession = Maven.init();
    let config = Config.init();

    let classpath = Config.getDependencies(config) |>
        Config.getMavenDependencies |>
        Maven.resolveTransitiveDependencies(mavenSession);

    let sourceFiles = Source.getSourceFiles(config);

    let flixVersion = Config.getFlixVersion(config);
    let flixJar = Maven.resolveArtifact(mavenSession,
        "com.paulbutcher:flix:${flixVersion}");

    Compiler.run(flixJar, sourceFiles, classpath)
